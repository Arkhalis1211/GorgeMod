local recipes = require("gorge_preparedfoods")

local ingredients = {}
local stationrecipes = {}
local aliases =
{
	foliage = "quagmire_foliage_cooked",
	quagmire_smallmeat = "quagmire_cookedsmallmeat",
	meat = "cookedmeat",
}

local function AddStationRecipe(station, recipe)
	if not stationrecipes[station] then
		stationrecipes[station] = {}
	end
	stationrecipes[station][recipe.name] = recipe
end

local function AddQuagmireIngredient(name, tags, cookingtime, cancook)
	local cookname = "_cooked"

	ingredients[name] = {precooked = false, cookingtime = cookingtime or 0, tags= {}}

	if cancook then
		cookname = aliases[name] or name.."_cooked"
		ingredients[cookname] = {precooked = true, cookingtime = cookingtime or 0, tags= {}}
	end

	if tags ~= nil then
		for tag, value in pairs(tags) do
			ingredients[name].tags[tag] = value

			if cancook then
				ingredients[cookname].tags[tag] = value
			end
		end
	end
end

--Surg: better not to disturb order, may be need in the future
AddQuagmireIngredient("quagmire_turnip", {veggie = 1, turnip = 1}, 15, true)
AddQuagmireIngredient("quagmire_onion", {veggie = 1, onion = 1}, 15, true)
AddQuagmireIngredient("quagmire_carrot", {veggie = 1, carrot = 1}, 15, true)
AddQuagmireIngredient("quagmire_potato", {veggie = 1, potato = 1}, 15, true)
AddQuagmireIngredient("quagmire_tomato", {veggie = 1, tomato = 1}, 15, true)
AddQuagmireIngredient("quagmire_garlic", {spicy = 1, garlic = 1}, 15, true)
AddQuagmireIngredient("quagmire_spotspice_ground", {spicy = 1}, 0, false)
AddQuagmireIngredient("quagmire_flour", nil, 0, false)
AddQuagmireIngredient("foliage", {veggie = 1, herbal = 1}, 12, true)
AddQuagmireIngredient("quagmire_mushrooms", {veggie = 1, mushroom = 1}, 15, true)
AddQuagmireIngredient("berries", {sweet = 1, berries = 1}, 8, true)
AddQuagmireIngredient("quagmire_smallmeat", {meat = 1, tendermeat = 1}, 16, true)
AddQuagmireIngredient("meat", {meat = 1, toughmeat = 1}, 18, true)
AddQuagmireIngredient("quagmire_salmon", {meat = 1, fish = 1}, 16, true)
AddQuagmireIngredient("quagmire_crabmeat", {meat = 1, crabmeat = 1}, 16, true)
AddQuagmireIngredient("quagmire_goatmilk", nil, 0, false)
AddQuagmireIngredient("quagmire_syrup", {sweet = 1}, 0, false)
AddQuagmireIngredient("quagmire_sap", {sweet = 1}, 0, false)
AddQuagmireIngredient("rocks", {inedible = 1}, 0, false)
AddQuagmireIngredient("twigs", {inedible = 1}, 0, false)

for _, recipe in pairs(recipes) do
	for _, station in pairs(recipe.stations) do
		AddStationRecipe(station, recipe)
	end
end

local function GetIngredientData(list)
	local names = {}
	local tags = {}

	for _, name in pairs(list) do
		names[name] = (names[name] or 0) + 1

		local data = ingredients[name]
		if data ~= nil then
			for tag, value in pairs(data.tags) do
				tags[tag] = (tags[tag] or 0) + value
			end
		end
	end

	return {tags = tags, names = names}
end

local TestFood =
{
	MAX_INGREDIENTS = 4,
	stationtesting = "oven",
	foodtesting = "quagmire_food_001",
	foundrecipes = {},
	ingredients_test = {
		"quagmire_turnip_cooked",
		"quagmire_onion_cooked",
		"quagmire_carrot_cooked",
		"quagmire_potato_cooked",
		"quagmire_tomato_cooked",
		"quagmire_garlic_cooked",
		"quagmire_spotspice_ground",
		"quagmire_flour",
		"quagmire_foliage_cooked",
		"quagmire_mushrooms_cooked",
		"berries_cooked",
		"quagmire_cookedsmallmeat",
		"cookedmeat",
		"quagmire_salmon_cooked",
		"quagmire_crabmeat_cooked",
		"quagmire_goatmilk",
		"quagmire_syrup",
		"quagmire_sap",
		"rocks",
		"twigs"
	}
}

function TestFood:NodeTest(previngredients, prevlevel)
	local level = prevlevel + 1
	if level > self.MAX_INGREDIENTS then return end
	local curingredients = deepcopy(previngredients)
	for _, ingredient in pairs(self.ingredients_test) do
		table.insert(curingredients, ingredient)
		local allrecipes = stationrecipes[self.stationtesting] or {}
		local ingdata = GetIngredientData(curingredients)
		local countings = #curingredients
		for _, candidat in pairs(allrecipes) do
			if candidat.test(ingdata.names, ingdata.tags, countings) then
				if candidat.name == self.foodtesting then
					local foundingredients = deepcopy(curingredients)
					table.sort(foundingredients)
					table.insert(self.foundrecipes, foundingredients)
				end
			end
		end
		self:NodeTest(curingredients, level)
		table.remove(curingredients)
	end
end

function TestFood:Run(station, food)
	self.stationtesting = station
	self.foodtesting = food
	self.foundrecipes = {}

	self:NodeTest({}, 0)
	--cleanup dupplicates
	for i = #self.foundrecipes, 1, -1 do
		local flag_remove = false
		local recipeings = self.foundrecipes[i]
		for _, ings in pairs(self.foundrecipes) do
			if recipeings ~= ings and #recipeings == #ings then
				local flag_found = true
				for j = 1, #recipeings do
					if recipeings[j] ~= ings[j] then flag_found = false end
				end
				if flag_found then flag_remove = true end
			end
		end
		if flag_remove then table.remove(self.foundrecipes, i) end
	end
	table.sort(self.foundrecipes, function(a, b)
		if #a < #b then
			return true
		end
		return false
	end)
	--print result
	print("[StressTestFood] ingredients: ")
	local allrecipes = stationrecipes[self.stationtesting] or {}
	for i, ings in pairs(self.foundrecipes) do
		local ingsstr = ""
		for _, ing  in pairs(ings) do
			local str = ing
			str = string.gsub(str, "_cooked_", "")
			str = string.gsub(str, "cooked_", "")
			str = string.gsub(str, "quagmire_cooked", "quagmire_")
			str = string.gsub(str, "_cooked", "")
			str = string.gsub(str, "cooked", "")
			str = string.gsub(str, "quagmire_", "")
			ingsstr = ingsstr..str..", "
		end
		print(i..". "..ingsstr)
		local ingdata = GetIngredientData(ings)
		local countings = #ings
		for _, candidat in pairs(allrecipes) do
			if candidat.test(ingdata.names, ingdata.tags, countings) then
				if candidat.name ~= self.foodtesting then
					print(i..".	warning! with the same ingredients another candidat: "..candidat.name)
				end
			end
		end
	end
end

return
{
	CalculateRecipe = function(station, names)
		local allrecipes = stationrecipes[station] or {}
		local ingdata = GetIngredientData(names)

		for _, candidat in pairs(allrecipes) do
			if candidat.test(ingdata.names, ingdata.tags, #names) then
				return candidat.name
			end
		end

		return nil
	end,

	CanCookByIngredients = function(names)
		local countrocks = 0
		local counttwigs = 0
		local count = #names

		for _, name in pairs(names) do
			if name == "rocks" then
				countrocks = countrocks + 1
			end

			if name == "twigs" then
				counttwigs = counttwigs + 1
			end
		end

		if count > 0 and ((countrocks + counttwigs) == count or
		   countrocks == count or counttwigs == count) then
			return false
		end

		return true
	end,

	GetStationsByRecipe = function(recipe)
		return recipes[recipe] and recipes[recipe].stations or {}
	end,

	GetCravingsByRecipe = function(recipe)
		return recipes[recipe] and recipes[recipe].cravings or {}
	end,

	--Surg: dish can be nil (for quagmire_syrup, used in announcement cooked)
	GetDishByRecipe = function(recipe)
		return recipes[recipe] and recipes[recipe].dish or nil
	end,

	GetCookingTimeByRecipe = function(recipe)
		return recipes[recipe] and recipes[recipe].cookingtime or 0
	end,

	GetBurningTimeByRecipe = function(recipe)
		return recipes[recipe] and recipes[recipe].burningtime or 0
	end,

	GetCookingTimeIngredient = function(name)
		return ingredients[name] and ingredients[name].cookingtime or 0
	end,

	IsPreCookedIngredient = function(name)
		return ingredients[name] and ingredients[name].precooked or false
	end,

	GetFoodSoiledNormalize = function(stationtype, prefabfood)
		local result = {prefab = "quagmire_food_plate_goop", dish = "plate", dirty = "goop"}

		if stationtype == nil then
			return result
		end

		if prefabfood ~= nil and prefabfood ~= "quagmire_food_bowl_goop" and prefabfood ~= "quagmire_food_bowl_burnt" and
								 prefabfood ~= "quagmire_food_plate_goop" and prefabfood ~= "quagmire_food_plate_burnt" then
			local dish = recipes[prefabfood] and recipes[prefabfood].dish or nil

			if stationtype == "grill" or stationtype == "oven" then
				result = {prefab = "quagmire_food_"..dish.."_burnt", dish = dish, dirty = "burnt"}
			else
				if dish ~= nil then
					result = {prefab = "quagmire_food_"..dish.."_goop", dish = dish, dirty = "goop"}
				else
					--need for syrup
					result = {prefab = "quagmire_food_bowl_goop", dish = dish, dirty = "goop"}
				end
			end
		else
			if stationtype == "grill" then
				result = {prefab = "quagmire_food_plate_burnt", dish = "plate", dirty = "burnt"}
			elseif stationtype == "oven" then 
				result = {prefab = "quagmire_food_plate_goop", dish = "plate", dirty = "goop"}
			else
				result = {prefab = "quagmire_food_bowl_goop", dish = "bowl", dirty = "goop"}
			end
		end

		return result
	end,

	--Surg: for all sets of ingredients test is conducted and found match is printed.
	--	  dont worry, just wait 15 seconds.
	--	  debug only.
	StressTestFood = function(station, food)
		print("[StressTestFood] started, station: "..station..", food: "..food)
		TestFood:Run(station, food)
		print("[StressTestFood] finished")
	end,
}
