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
		if not inst.sg:HasStateTag("talking") then
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_kid/talk")
		end
    end),
	
	EventHandler("item_bought", function(inst, data)
		inst.sg:GoToState("bought", data.first)
    end),
	
	EventHandler("gameend", function(inst, data)
		if not data.win then
			inst.sg:GoToState("hide")
		else
			inst.sg.mem.ending = true
			inst.sg:GoToState("idle")
		end
    end),
	
	EventHandler("jumping", function(inst, data)
		inst.sg.mem.jumping = data and data.jumping
    end),
	
	EventHandler("onnear", function(inst)
		if not inst.sg.mem.ending then
			inst.sg:GoToState("onnear")
		end
    end),
}

local states =
{
	State{
		name= "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("idle_loop", true)
			
			local length = inst.AnimState:GetCurrentAnimationLength()
			inst.sg:SetTimeout(length * (inst.sg.mem.jumping and 2 or 1))
		end,
		
		ontimeout = function(inst)
			if inst.sg.mem.ending and inst.sg.mem.jumping then
				inst.sg:GoToState("win")
			else
				inst.sg:GoToState("idle")
			end
		end,
	},
	
	State{
		name = "bought",
		tags = {"busy", "talking"},

		onenter = function(inst, first)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("cheer_pre")
			inst.AnimState:PushAnimation("cheer_loop")
			inst.AnimState:PushAnimation("cheer_pst")
			
			inst.components.talker:Chatter("GOATKID_TALK_TRADE", math.random(1, #STRINGS.GOATKID_TALK_TRADE))
			
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_kid/item_sold")	
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end ),
		}
	},
	
	State{
		name = "win",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("cheer_pre")
			inst.AnimState:PushAnimation("cheer_loop")
			
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/goat_kid/item_sold")	
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("win_pst")
				end
			end),
		}
	},
	
	State{
		name = "win_pst",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("cheer_pst")
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		}
	},
	
	State{
		name = "onnear",
		tags = {"idle"},

		onenter = function(inst, first)
			inst.components.locomotor:Stop()
			
			inst.AnimState:PlayAnimation("idle_happy")
			
			inst.components.talker:Chatter("GOATKID_TALK_GREETING", math.random(1, #STRINGS.GOATKID_TALK_GREETING))
		end,
		
		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end ),
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

return StateGraph("quagmire_goatkid", states, events, "idle", {})
