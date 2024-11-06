-- require("stategraphs/commonstates")

local events =
{
	--[[
    EventHandler("locomote", function(inst) 
		if not inst.sg:HasStateTag("moving") then
			if not inst.components.locomotor:WantsToMoveForward() then
				if not inst.sg:HasStateTag("idle") then
					if not inst.sg:HasStateTag("running") then
						inst.sg:GoToState("idle")
					end

					inst.sg:GoToState("idle")
				end
			elseif inst.components.locomotor:WantsToRun() then
				if not inst.sg:HasStateTag("running") then
					inst.sg:GoToState("run")
				end
			else
				if not inst.sg:HasStateTag("walking") then
					inst.sg:GoToState("walk")
				end
			end
		end
	end),]]
	EventHandler("locomote", function(inst)
		if (not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving")) then return end

		if not inst.components.locomotor:WantsToMoveForward() then
			if not inst.sg:HasStateTag("idle") then
				inst.sg:GoToState("idle", {softstop = true})
			end
		else
			if not inst.sg:HasStateTag("hopping") then
				inst.sg:GoToState("hop")
			end
		end
	end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states =
{
    State{
		name = "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst, data)
			inst.Physics:Stop()
			if data and data.softstop then
				inst.AnimState:PushAnimation("idle", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
			inst.sg:SetTimeout(2.5 + math.random())
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("funnyidle")
		end,
	},
	
	State{
		name = "hop",
		tags = {"moving", "canrotate", "hopping"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("hop")
			inst.components.locomotor:WalkForward()
		end,

		onupdate = function(inst)
			if not inst.components.locomotor:WantsToMoveForward() then
				inst.sg:GoToState("idle")
			end
		end,

		timeline =
		{
			TimeEvent(8 * FRAMES, function(inst)
				inst.components.locomotor:Stop()
			end),
		},
	},
	
	State{
		name = "funnyidle",
		tags = {"busy", "canrotate"},

		onenter = function(inst)
			if math.random() <= .15 then
				inst.AnimState:PlayAnimation("honk")
				inst.sg.statemem.honksound = true
			elseif math.random() <= .4 then
				inst.AnimState:PlayAnimation("peck")
				for i = 1, math.random(1, 2) do
					inst.AnimState:PushAnimation("peck")
				end
			else
				inst.AnimState:PlayAnimation("idle_"..math.random(2, 3))
			end
		end,
		
		timeline =
		{
			TimeEvent(12 * FRAMES, function(inst)
				if inst.sg.statemem.honksound then
					inst.SoundEmitter:PlaySound("gorge/chicken/hunk", "honk")
				end
			end),
			
			TimeEvent(29 * FRAMES, function(inst)
				if inst.sg.statemem.honksound then
					inst.SoundEmitter:KillSound("honk")
				end
			end),
		},
		
		events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
        }
	},
	
	State{
		name = "sleeping",
		tags = {"busy", "canrotate", "sleeping"},

		onenter = function(inst)
			-- inst.AnimState:PlayAnimation("sleep_pre")
			inst.AnimState:PlayAnimation("sleep_loop", true)
		end,
	},
	
	State{
		name = "sleeping_pst",
		tags = {"busy", "canrotate"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("sleep_pst")
		end,
		
		events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        }
	},
	
    State
    {
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
			inst.SoundEmitter:PlaySound("gorge/chicken/hunk", "scream")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
			if TheNet:IsDedicated() then
				TheWorld.net.components.quagmire_hangriness:DoRumble(true)
			else
				TheWorld:PushEvent("quagmirehangrinessrumbled", { major = true })
			end

			TheWorld.net.components.quagmire_hangriness:DebugSetSpeed(16)
        end,
    },

}

return StateGraph("quagmirechicken", states, events, "sleeping")