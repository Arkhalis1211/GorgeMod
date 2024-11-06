require("stategraphs/commonstates")
local events =
{
	CommonHandlers.OnStep(),
	CommonHandlers.OnLocomote(true, true),
}

local states =
{
	State{
		name= "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("idle_loop", false)
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end ),
		},
	},
	State{            --Hornet: - For wilba ::::>>
        name = "gift",
        tags = {"busy"},

        onenter = function(inst)
            --inst.components.talker:Say(STRINGS.PIG_TALK_DAILY_GIFTING[math.random(1, #STRINGS.PIG_TALK_DAILY_GIFTING)])
            inst.AnimState:PlayAnimation("pig_take")
            inst.Physics:Stop()
        end,

        timeline=
        {
            TimeEvent(13*FRAMES, 
                function(inst)
                    local resources = {"quagmire_potato", "quagmire_tomato", "quagmire_wheat", "quagmire_flour", "quagmire_turnip", "quagmire_carrot", "quagmire_garlic"}
					local hangry_resources = {}

                    player.components.inventory:GiveItem(SpawnPrefab(resources[math.random(1, #resources)]), nil, inst:GetPosition())
                end ),
        },
        
        events=
        {
            EventHandler("animover", 
                function(inst)
                    inst.sg:GoToState("idle") 
                end ),
        },
    }
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
},
{
	startwalk = "walk_pre",
	walk = "walk_loop",
	stopwalk = "walk_pst",
})

return StateGraph("quagmire_goatkid", states, events, "idle", {})
