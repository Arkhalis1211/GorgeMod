local states =
{
	State{
		name = "idle_sleep_pre",
		tags = {"idle", "sleeping"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("sleep_pre")
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle_sleep")
			end ),
		},
	},
	
	State{
		name = "idle_sleep",
		tags = {"idle"},

		onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/swamppig_elder/sleep_out")
			inst.AnimState:PlayAnimation("sleep_loop")
			
			if not inst.sg.mem.talk_sleep then
				inst.sg.mem.talk_sleep = TUNING.GORGE.SWAMP_PIG_ELDER.TALK_SLEEP_CD
			end
			inst.sg.mem.talk_sleep = inst.sg.mem.talk_sleep - 1
			if inst.sg.mem.talk_sleep <= 0 then
				inst.sg.mem.talk_sleep = TUNING.GORGE.SWAMP_PIG_ELDER.TALK_SLEEP_CD
				inst.components.talker:Chatter("QUAGMIRE_ELDER_TALK_SLEEP", math.random(#STRINGS.QUAGMIRE_ELDER_TALK_SLEEP))
			end
		end,
		
		timeline = {
			TimeEvent(29 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/swamppig_elder/sleep_in")
			end)
		},
		
		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle_sleep")
			end ),
		},
	},
	
	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("sleep_pst")
			inst.AnimState:PushAnimation("idle", true)
		end,
	},
}


return StateGraph("quagmire_swampigelder", states, {}, "idle_sleep", {})
