-- Override RecipeBook functions (client side) for give recipes without check Inventory (personal data from server klei)
-- Synchronization (auto-fill) unlocked recipes if file recipebook crashed

if not TheNet:IsDedicated() then
	local recipesdata = require "gorge_recipesdata"

	local function FillTableCoins(coinstable, coins)
		if coins ~= nil then
			local levels = 0
			local max_coin = 1

			for _, v in pairs(coins) do
				levels = levels + 1
				if v > 0 then
					max_coin = levels
				end
			end

			levels = 0
			for _, v in pairs(coins) do
				levels = levels + 1
				if levels <= max_coin then
					coinstable["coin"..levels] = v
				else
					coinstable["coin"..levels] = nil
				end
			end
		end
	end

	local function SyncRecipe(book, name, festival_key, festival_season, session, date)
		local namerecipe = "quagmire_"..name
		if name == "food_syrup" then
			namerecipe = "quagmire_syrup"
		end
		local food_unlocked = EventAchievements:IsAchievementUnlocked(festival_key, festival_season, name)

		if food_unlocked and book.recipes[namerecipe] == nil then
			local data = recipesdata[name]

			if namerecipe == "quagmire_syrup" then
				book.recipes["quagmire_syrup"] = {
					station = data.stations,
					size = data.size,
					new = "new",
					date = date,
					recipes = data.ingredients,
					session = session }
			else
				local base_coins = {}
				local silver_coins = {}

				FillTableCoins(base_coins, data.coins)
				FillTableCoins(silver_coins, data.silver_coins)

				book.recipes[namerecipe] = {
					dish = data.dish,
					base_value = base_coins,
					silver_value = silver_coins,
					tags = data.cravings,
					station = data.stations,
					size = data.size,
					new = "new",
					date = date,
					recipes = data.ingredients,
					session = session}
			end

			print("[TheRecipeBook] Added unlocked recipe:", namerecipe)
			return true
		end

		return false
	end
	
	local RecipeBook = require "quagmire_recipebook"

	RecipeBook.GetValidRecipes = function(self)
		local ret = {}
		local festival_key = FESTIVAL_EVENTS.QUAGMIRE
		local festival_season = GetFestivalEventSeasons(festival_key)

		-- Synchronization
		if festival_season == 1 then
			local count = 0

			for _, _ in pairs(self.recipes) do
				count = count + 1
			end

			if count < 70 then
				print("[TheRecipeBook] Synchronization unlocked recipes", count)
				local save_recipebook = false
				local date = os.date("%d/%m/%Y/%X")
				local session = TheNet:GetSessionIdentifier()
				if session == "" then session = "2CB154A871CA4B25" end -- fake session for menu

				for i = 1 , 69 do
					local food_name = "food_0"..i;
					if i < 10 then 
						food_name = "food_00"..i;
					end
					
					if SyncRecipe(self, food_name, festival_key, festival_season, session, date) then
						save_recipebook = true
					end
				end

				if SyncRecipe(self, "food_syrup", festival_key, festival_season, session, date) then
					save_recipebook = true
				end

				if save_recipebook then
					TheSim:SetPersistentString("recipebook", json.encode(self.recipes), false)
				end
			end
		end

		for k, v in pairs(self.recipes) do
			ret[k] = v
		end

		return ret
	end

	RecipeBook.IsRecipeUnlocked = function(self, product)
		for k, v in pairs(self.recipes) do
			if tostring(k) == tostring(product) then
				return true
			end
		end

		return false
	end
end