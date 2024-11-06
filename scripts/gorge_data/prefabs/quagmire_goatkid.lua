local function Say(inst, str)
	inst.components.talker:Chatter(str, math.random(#STRINGS[str]))
end

local function Closed(inst)
	if inst.gameend then
		return
	end
	
	inst:PushEvent("onnear")
	Say(inst, "GOATKID_TALK_CLOSED")
end

local function TurnOn(inst)
	if inst.gameend then
		return
	end
	
	inst:PushEvent("onnear")
	Say(inst, "GOATKID_TALK_GREETING")
end

local function Activate(inst)
	inst:PushEvent("item_bought")
end

return {
	master_postinit = function(inst)
		inst:AddTag("goatkid")
	
		inst:AddComponent("inspectable")
		
		MakeQuagmireShop(inst, Closed, nil, Activate)
		
		inst:AddComponent("knownlocations")
		
		inst:AddComponent("locomotor")
		inst.components.locomotor.walkspeed = 3
		inst.components.locomotor.runspeed = 3
		
		inst:SetStateGraph("SGgoatkid")
		inst:SetBrain(require("brains/goatkidbrain"))
		
		inst:ListenForEvent("updateshops", function(_, val)
			if val then
				inst.components.playerprox.onnear = TurnOn
			end
		end, TheWorld)
		
		inst:DoTaskInTime(0, function(inst)
			inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
		end)
	end,
}
