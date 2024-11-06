local function Say(inst, str)
	inst.components.talker:Chatter(str, math.random(#STRINGS[str]))
end

local function OnActivate(inst)
	Say(inst, "QUAGMIRE_ELDER_TALK_BUY")
end

local function TurnOn(inst)
	Say(inst, "QUAGMIRE_ELDER_TALK_GREETING")
	inst.sg:GoToState("idle")
end

local function TurnOff(inst)
	inst.sg:GoToState("idle_sleep_pre")
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
	
		MakeQuagmireShop(inst, TurnOn, TurnOff, OnActivate, true)
		
		inst:SetStateGraph("SGswamppig_elder")
		
		inst:ListenForEvent("ontalk", function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/swamppig_elder/talk")
		end)
	end,
}
