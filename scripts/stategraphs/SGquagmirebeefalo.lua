require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),

    EventHandler("death", function(inst)
		inst.sg:GoToState("death")
    end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
			if pushanim then
				inst.AnimState:PushAnimation("idle_loop", true)
			else
				inst.AnimState:PlayAnimation("idle_loop", true)
			end
			
			inst.sg:SetTimeout(1 + 1*math.random())
        end,

        timeline = {
            TimeEvent(5 * FRAMES, function(inst) inst.didalertnoise = nil end),
        },

        ontimeout = function(inst)
			local rand = math.random()
			if math.random() <= .5 then
				inst.sg:GoToState("idle")
			elseif rand < .5 then
				inst.sg:GoToState("graze_empty")
			elseif rand < .75 then
				inst.sg:GoToState("shake")
			else
				inst.sg:GoToState("bellow")
			end
        end,
    },
	
    State{
        name = "graze_empty",
        tags = {"idle", "canrotate", "busy"},
        
        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("graze2_pre")
            inst.AnimState:PushAnimation("graze2_loop")
            inst.sg:SetTimeout(1+math.random()*5)
        end,
        
        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("graze2_pst")
            inst.sg:GoToState("idle", true)
        end,

    },
    
    State{
        name = "shake",
        tags = {"idle", "canrotate", "busy"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
        end,
       
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	
	State{
        name = "bellow",
        tags = {"idle", "canrotate", "busy"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("bellow")
            inst.SoundEmitter:PlaySound(inst.sounds.grunt)
        end,
       
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "alert",
        tags = {"idle", "canrotate", "alert"},
        
        onenter = function(inst)
            inst.sg:GoToState("actual_alert")
        end,
    },
    
    State{
        name = "actual_alert",
        tags = {"idle", "canrotate", "alert"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.didalertnoise then
                inst.SoundEmitter:PlaySound(inst.sounds.curious)
                inst.didalertnoise = true
            end
            if not inst.AnimState:IsCurrentAnimation("alert_idle") then
                inst.AnimState:PlayAnimation("alert_pre")
                inst.AnimState:PushAnimation("alert_idle", true)
            end

            inst.sg:SetTimeout(2 + 2*math.random())
        end,
        
        ontimeout=function(inst)
            inst.sg:GoToState("actual_alert")
        end,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.yell)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())

            inst:DoTaskInTime(2, ErodeAway)
        end,
    },
   
    State
    {
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            local hastarget = inst.components.combat ~= nil and inst.components.combat:HasTarget()
            inst.AnimState:PlayAnimation(hastarget and "run_pre" or "run2_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },
   
    State
    {
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            local hastarget = inst.components.combat ~= nil and inst.components.combat:HasTarget()
            inst.AnimState:PlayAnimation(hastarget and "run_loop" or "run2_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = {
            TimeEvent(1*FRAMES, function(inst) inst.didalertnoise = nil end),
            TimeEvent(5*FRAMES, PlayFootstep),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },
   
    State
    {
        name = "run_stop",
        tags = { "idle" },

        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            local hastarget = inst.components.combat ~= nil and inst.components.combat:HasTarget()
            inst.AnimState:PlayAnimation(hastarget and "run_pst" or "run2_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddWalkStates(
    states,
    {
        walktimeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.didalertnoise = nil end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
        }
})


return StateGraph("beefalo", states, events, "idle", {})

