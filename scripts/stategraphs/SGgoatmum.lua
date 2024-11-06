require("stategraphs/commonstates")

local function GoatSteps(inst)
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/walk")
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local events =
{
	CommonHandlers.OnStep(),
	CommonHandlers.OnLocomote(true, true),
	
	EventHandler("ontalk", function(inst)
        if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState(inst.components.goatmum.specialtalk or "talk")
        end
    end),
	
	EventHandler("player_near", function(inst)
        if not inst.sg:HasStateTag("busy") and
		not inst.sg:HasStateTag("talk") and
		not inst.sg:HasStateTag("running") and
		math.random() <= .5 and
		inst.components.goatmum:GetState() == GOATMUM_STATES.IDLE then
			inst.sg:GoToState("look", {anim = 1})
        end
    end),
	
	EventHandler("item_bought", function(inst, data)
		inst.sg:GoToState("bought", data.first)
    end),
	
	EventHandler("mum_state_changed", function(inst, data)
		local state = data.mumstate or 0
		if state == GOATMUM_STATES.START then
			inst.sg:GoToState("start_pre")
		elseif state == GOATMUM_STATES.WAIT_FOR_PURCHASE then
			inst.sg.mem.notalktime = 0
			inst.sg:GoToState("coin")
		end
    end),
	
	EventHandler("gameend", function(inst, data)
		inst.sg:GoToState("hide")
    end),
	
	EventHandler("snackrificed", function(inst, data)
		inst.sg:GoToState("snackrificed", {satisfied = data.satisfied, craving = data.craving})
    end),
	--[[
	EventHandler("cravingchanged", function(inst, data)
		inst.sg:GoToState("look", {anim = 2, announce = true})
    end),]]
}

local states =
{
	State{
		name= "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("idle_loop", true)
		end,
		
		onupdate = function(inst, dt)
			if inst.sg.mem.notalktime then
				inst.sg.mem.notalktime = inst.sg.mem.notalktime + dt
				
				if inst.sg.mem.notalktime >= TUNING.GORGE.GOATMUM.TIPS_CD then
					inst.sg.mem.notalktime = 0 -- Fox: Without this Mumsy says something twice
					inst.components.goatmum:SayTip()
				end
			end
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				if inst.brain and inst.brain.pot and math.random() <= .25 then
					inst.sg:GoToState("look")
				else
					inst.sg:GoToState("idle")
				end
			end ),
		},
	},
	
	State{
		name = "talk",
		tags = {"talk", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/talk")
			inst.AnimState:PlayAnimation("talk"..math.random(inst.components.goatmum.scared and 2 or 1, inst.components.goatmum.happy and 4 or 3), false)
			
			inst.sg.mem.notalktime = 0
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
		}
	},
	
	State{
		name = "look",
		tags = {"busy", "canrotate"},

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("look"..(data and data.anim or math.random(1, 2)), false)
			if data and data.announce then
				inst.sg.statemem.announce = data.announce
			end
			if not data then
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("idle")
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.sg.statemem.announce then
					inst.sg:RemoveStateTag("busy")
					inst.components.goatmum:AnnounceCraving()
				else
					inst.sg:GoToState("idle")
				end
			end ),
		}
	},
	
	State{
		name = "goodbye",
		tags = {"talk", "busy", "nointerrupt"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/talk")
			inst.AnimState:PlayAnimation("goodbye")
			inst.AnimState:PushAnimation("goodbye_loop", true)
		end
	},
	
	State{
		name = "coin",
		tags = {"busy"},

		onenter = function(inst)
			TheWorld.components.quagmire:StartHangriness()
			
			inst.components.locomotor:Stop()
			inst.Transform:SetRotation(270)
			inst.AnimState:PlayAnimation("coin", false)
		end,
		
		timeline = {			
			TimeEvent(23 * FRAMES, function(inst)
				for i = 1, TUNING.GORGE.START_COINS.COUNT do
					inst:DoTaskInTime(math.random() / 5 + i/100, function(inst)
						local offset = 1
						local spd = 1.75 + math.random() * 2.5
						local angle = (135 + math.random() * 45) * DEGREES * 1.1
						local x, y, z = inst.Transform:GetWorldPosition()
						
						local coin = SpawnPrefab(TUNING.GORGE.START_COINS.COIN_TYPE)
						coin.Transform:SetPosition(x - math.sin(angle) * offset, 1.35, z - math.cos(angle) * offset)
						
						coin:Toss()
						
						coin.Physics:SetVel(math.cos(angle) * spd, 12, math.sin(angle) * spd)
					end)
				end
				
				inst.sg:RemoveStateTag("busy")
			end),
		},
		
		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end ),
		},
		
		onexit = function(inst)
			inst.components.goatmum.shop_active = true
		end,
	},
	
	State{
		name = "bought",
		tags = {"busy"},

		onenter = function(inst, first)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("talk4")
			
			inst.components.talker:Chatter("GOATMUM_TALK_TRADE", math.random(1, #STRINGS.GOATMUM_TALK_TRADE))
			
			inst.sg.statemem.first = first
		end,
		
		timeline = {
			TimeEvent(10 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/clap")
			end),
			
			TimeEvent(18 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/clap")
			end),
			
			TimeEvent(30 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/clap")
			end),
			
			TimeEvent(42 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_mum/clap")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if not inst.sg.statemem.first then
					inst.sg:GoToState("idle")
				else
					inst.sg:GoToState("look", {anim = 2, announce = true})
				end
			end ),
		}
	},
	
	State{
		name = "snackrificed",
		tags = {"busy"},

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("talk"..(data.satisfied and 4 or 3))

			local str = "GOATMUM_CRAVING_"..(data.satisfied and "" or "MIS").."MATCH"
			inst.components.talker:Say(subfmt(STRINGS[str][math.random(#STRINGS[str])],
			{
				craving = STRINGS.GOATMUM_CRAVING_MAP[data.craving],
			}))
		end,

		events =
		{
			EventHandler("animover", function(inst) 
				inst.sg:GoToState("look", {anim = 2, announce = true})
			end ),
		}
	},
	
	State{
		name = "start_pre",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("start_pre")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("start_loop") end ),
		}
	},
	
	State{
		name = "start_loop",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("start_loop", true)
		end,

		events =
		{
			EventHandler("mum_state_changed", function(inst, data)
				inst.AnimState:PlayAnimation("start_pst")
				inst.sg.statemem.goidle = true
			end),
			
			EventHandler("animover", function(inst)
				if inst.sg.statemem.goidle then
					inst.sg:GoToState("idle")
				end
			end),
		}
	},
	
	State{
		name = "hide",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
		
			inst:Hide()
			inst.DynamicShadow:Enable(false)
			ToggleOffPhysics(inst)
		end,
		
		-- Fox: We're not suppose to do this, but just in case
		onexit = function(inst)
			inst:Show()
			inst.DynamicShadow:Enable(false)
			ToggleOnPhysics(inst)
		end,
	},
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
		TimeEvent(0*FRAMES, GoatSteps ),
		TimeEvent(12*FRAMES, GoatSteps ),
	},
},
{
	startwalk = "walk_pre",
	walk = "walk_loop",
	stopwalk = "walk_pst",
})

CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(0*FRAMES, GoatSteps ),
		TimeEvent(0*FRAMES, GoatSteps ),
	},
},
{
	startwalk = "run_pre",
	walk = "run_loop",
	stopwalk = "run_pst",
})

return StateGraph("quagmire_goatmum", states, events, "idle", {})
