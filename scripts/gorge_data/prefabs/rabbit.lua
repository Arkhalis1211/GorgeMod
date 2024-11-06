local rabbitloot = { "quagmire_smallmeat" }

local function SetRabbitLoot(lootdropper)
	lootdropper:SetLoot(rabbitloot)
end

local function MakeInventoryRabbit(inst)
    SetRabbitLoot(inst.components.lootdropper)
end

local function LootSetupFunction(lootdropper)
	SetRabbitLoot(lootdropper)
end

local wintersounds =
{
    scream = "dontstarve/rabbit/winterscream",
    hurt = "dontstarve/rabbit/winterscream_short",
}

return {
	master_postinit = function(inst)
		inst:AddComponent("combat")
		MakeInventoryRabbit(inst)
		inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)
		inst.components.cookable.product = "quagmire_cookedsmallmeat"
		if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
			inst:DoTaskInTime(0, function()
				inst.AnimState:SetBuild("rabbit_winter_build")
				inst.sounds = wintersounds
				inst.components.inventoryitem:ChangeImageName("rabbit_winter")
			end)
		end
	end,
}
