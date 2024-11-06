local sounds =
{
    close = "dontstarve/common/trap_close",
    rustle = "dontstarve/common/trap_rustle",
}

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("trap")
		inst.components.trap.targettag = "crab"
		inst.components.trap.baitsortorder = 1
		
		inst.AnimState:OverrideSymbol("shell", "quagmire_pebble_crab", "shell")
		inst.sounds = sounds
		inst:SetStateGraph("SGcrabtrap")
		
		inst:ListenForEvent("harvesttrap", function(inst, data)
			if data.doer then
				UpdateAchievement("gather_crab", data.doer.userid, true)
			end
		end)
	end,
}
