local brain = require "brains/quagmirebeefalobrain"

local sounds = 
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve/beefalo/grunt",
    yell = "dontstarve/beefalo/yell",
    swish = "dontstarve/beefalo/tail_swish",
    curious = "dontstarve/beefalo/curious",
    angry = "dontstarve/beefalo/angry",
    sleep = "dontstarve/beefalo/sleep",
}

local function SetHome(inst)
	inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
		
		inst:AddComponent("health")
		inst.components.health.invincible = true
		
		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetLoot({"meat", "meat"})
		
		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = 6
		inst.components.locomotor.walkspeed = 1
		
		inst:AddComponent("periodicspawner")                 --TODO: Hornet- These values might need to be changed, I have no idea how accurate they are
		inst.components.periodicspawner:SetPrefab("poop")
		inst.components.periodicspawner:SetRandomTimes(40, 60)
		inst.components.periodicspawner:SetDensityInRange(20, 2)
		inst.components.periodicspawner:SetMinimumSpacing(8)
		inst.components.periodicspawner:Start()
		
		inst:AddComponent("knownlocations")
		
		inst.sounds = sounds

	    inst:SetStateGraph("SGquagmirebeefalo")
		inst:SetBrain(brain)
		
		inst:DoTaskInTime(0, SetHome)
	end,
}
