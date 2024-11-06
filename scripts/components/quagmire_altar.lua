local Quagmire_Altar = Class(function(self, inst)
	self.inst = inst

	inst:AddTag("quagmire_altar")

	if CHEATS_ENABLED then
		rawset(_G, "testcraving", function(data) -- testcraving({product = "quagmire_food_003", dish = "bowl", silverdish = false})
			self.inst:PushEvent("craving_placed", {food = data})
		end)
	end
end)

function Quagmire_Altar:AcceptFoodTribute(player, food)
	if food.components.quagmire_portalkey then
		TheWorld:PushEvent("quagmire_win")
		food:Remove()
		return true
	end

	if not food:HasTag("preparedfood") then
		return false, "NOTDISH"
	elseif self.inst.sg:HasStateTag("full") then
		return false, "SLOTFULL"
	end

	self.inst:PushEvent("craving_placed", {
		food = {
			chief = food.chief,
			doer = player,
			product = food.prefab,
			dish = food.basedish,
			silverdish = (food:HasTag("replated_plate") or food:HasTag("replated_bowl")),
			stale = food.components.perishable:IsStale(),
			spoiled = food.components.perishable:IsSpoiled(),
			salted = food:HasTag("quagmire_salted"),
			recipe = food.recipe or {},
		}
	})

	if player then
		UpdateStat(player.userid, "tributes", 1)
	end

	food:Remove()

	return true
end

return Quagmire_Altar
