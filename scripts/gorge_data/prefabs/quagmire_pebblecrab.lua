local brain = require "brains/pebblecrabbrain"

local sounds =
{
	walk = "dontstarve/quagmire/creature/pebble_crab/walk",
    burrow = "dontstarve/quagmire/creature/pebble_crab/burrow",
	emerge = "dontstarve/quagmire/creature/pebble_crab/emerge",
    hurt = "dontstarve/quagmire/creature/pebble_crab/scratch",
}

local function SetUnderPhysics(inst)
    if inst.isunder ~= true then
        inst.isunder = true
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    end
end

local function SetAbovePhysics(inst)
    if inst.isunder ~= false then
        inst.isunder = false
        ChangeToCharacterPhysics(inst)
    end
end

local function SetHome(inst)
	inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function StartTimer(inst)
	if not inst.components.timer:TimerExists("hide") then
		inst.components.timer:StartTimer("hide", TUNING.GORGE.PEBBLECRAB.HIDETIME)
	end
end

local function onnear(inst)
	if not inst.components.timer:TimerExists("hide") then
		inst.sg:GoToState("burrow")
		StartTimer(inst)
	end
end

return {
	master_postinit = function(inst)
		inst:AddTag("crab")
	
		inst:AddComponent("inspectable")
	
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.nobounce = true
		inst.components.inventoryitem.canbepickedup = false
		inst.components.inventoryitem.canbepickedupalive = true
	
		inst:AddComponent("health")
		inst.components.health.invincible = true

		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetLoot({"quagmire_crabmeat"})

		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = 6
		inst.components.locomotor.walkspeed = 1 
	
		inst:AddComponent("eater")
		inst.components.eater:SetDiet({ FOODTYPE.MEAT, FOODTYPE.FISH }, { FOODTYPE.MEAT, FOODTYPE.FISH })

		inst.sounds = sounds 

		inst.SetUnderPhysics = SetUnderPhysics
		inst.SetAbovePhysics = SetAbovePhysics

		inst:SetStateGraph("SGpebblecrab")
		
		inst:AddComponent("playerprox")
		inst.components.playerprox:SetDist(3, 4)
		inst.components.playerprox:SetOnPlayerNear(onnear)
		-- inst.components.playerprox:SetOnPlayerFar(onfar)
		
		inst:AddComponent("timer")
		
		inst:AddComponent("knownlocations")
		inst:AddComponent("homeseeker")

		inst:SetBrain(brain)
		inst:DoTaskInTime(0, SetHome)
		MakeFeedableSmallLivestock(inst, TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
		
		inst:ListenForEvent("timerdone", function(inst, data)
			if data.name == "hide" then
				if FindClosestPlayerToInst(inst, 4) then
					StartTimer(inst)
				else
					if inst.components.knownlocations:GetLocation("home") then
						inst.Physics:Teleport(inst.components.knownlocations:GetLocation("home"):Get())
					else
						local pos = inst:GetPosition()
						local offset, check_angle, deflected = FindWalkableOffset(
							pos,
							2 * math.pi * math.random(),
							TUNING.GORGE.PEBBLECRAB.APPEAR_RANGE,
							50,
							true,
							false,
							function(pt)
								local tile = TheWorld.Map:GetTileAtPoint(pt:Get())
								return tile == GROUND.ROAD or tile == GROUND.QUAGMIRE_CITYSTONE
							end
						)
						inst.Physics:Teleport(pos.x + offset.x, 0, pos.z + offset.z)
					end
					inst.sg:GoToState("emerge")
				end
			end
		end)
	end,
}
