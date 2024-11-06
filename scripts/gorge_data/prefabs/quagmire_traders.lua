local function Say(inst, str)
	inst.components.talker:Chatter(str, math.random(#STRINGS[str]))
end

local function TurnOn(inst)
	Say(inst, "MERM1_TALK_GREETING")
end

local function TurnOn2(inst)
	Say(inst, "MERM2_TALK_GREETING")
end

local function Activate(inst)
	inst.AnimState:PlayAnimation("pig_take")
	inst.AnimState:PushAnimation("idle_loop", true)
	Say(inst, "MERM1_TALK_TRADE")
end

local function Activate2(inst)
	inst.AnimState:PlayAnimation("pig_take")
	inst.AnimState:PushAnimation("idle_loop", true)
	Say(inst, "MERM2_TALK_TRADE")
end

local function Closed(inst)
	Say(inst, "MERM_TALK_CLOSED")
end

return {
	master_postinit = function(inst)
		MakeQuagmireShop(inst, Closed)
	
        inst.AnimState:PlayAnimation("idle_loop", true)
		
		inst:AddComponent("inspectable")
		
		inst:ListenForEvent("ontalk", function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/attack")
		end)
	end,

	master_postinit_merm = function(inst)
		inst:AddTag("sammy")
	
		inst.components.prototyper.onactivate = Activate
		
		-- Fox: Spawning Leo
		--[[inst:DoTaskInTime(0, function(inst)
			local FIXED_ANGLE = 200
			local chicken = SpawnPrefab("quagmire_chicken")
			local pos = inst:GetPosition()
			local spawn_pos = Vector3(pos.x + math.cos(FIXED_ANGLE) * 12, 0, pos.z  + math.sin(FIXED_ANGLE) * 12)
			chicken.components.knownlocations:RememberLocation("home", spawn_pos)
			chicken.Transform:SetPosition(spawn_pos:Get())
		end)]]
		
		inst:ListenForEvent("updateshops", function(_, val)
			if val and inst.components.playerprox then
				inst.components.playerprox.onnear = TurnOn
			end
		end, TheWorld)
	end,
	
	master_postinit_merm2 = function(inst)
		inst.AnimState:SetBuild("merm_trader2_build")
		
		inst.components.prototyper.onactivate = Activate2
		
		inst:ListenForEvent("updateshops", function(_, val)
			if val and inst.components.playerprox then
				inst.components.playerprox.onnear = TurnOn2
			end
		end, TheWorld)
	end,
}
