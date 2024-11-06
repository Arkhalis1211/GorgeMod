require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.INTERACT_WITH, function(inst, action)
        if inst:HasTag("fertilizer") then
            return "fertilize"
        elseif inst:HasTag("harvester") then
            if action.target and action.target:HasTag("soil") then
                return "plant"
            else
                return "pickup"
            end
        else
            return "till"
        end
    end),
}

local events =
{
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("premoving")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),

    EventHandler("timetorest", function(inst) inst.sg:GoToState("sleep") end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states =
{
    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.."die")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    },

    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.."walk_spider") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("walk_loop")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.."walk_spider") end),
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.."walk_spider") end),
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.."walk_spider") end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.."walk_spider") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        ontimeout = function(inst)
            inst.sg:GoToState("taunt")
        end,

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            local animname = "idle"
            if math.random() < 0.3 then
                inst.sg:SetTimeout(math.random()*2 + 2)
            end

            if inst:IsLightGreaterThan(1.0) and not inst.bedazzled and not (inst.components.follower and inst.components.follower.leader ~= nil) then
                inst.AnimState:PlayAnimation("cower" )
                inst.AnimState:PushAnimation("cower_loop", true)
            elseif start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(inst.sounds.."scream")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "fertilize",
        tags = {"fertilize", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("heal")
            inst.SoundEmitter:PlaySound(inst.sounds.."heal")
        end,

        timeline=
        {
            TimeEvent(30*FRAMES, function(inst)
                inst:Fertilize()
                inst.SoundEmitter:PlaySound(inst.sounds.."heal_fartcloud")
                inst:PushEvent("workdone")
            end ),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "plant",
        tags = {"plant", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound(inst.sounds.."eat", "eating")
        end,

        events=
        {
            EventHandler("animover", function(inst) 
                local ba = inst:GetBufferedAction()
                if ba and ba.target and ba.target:IsValid() then
                    local item = inst.components.inventory:FindItem(function(item) return item:HasTag("edible_SEEDS") end)
                    if item then
                        if item.components.stackable then
                            item = item.components.stackable:Get(1) 
                        end
                        item.components.quagmire_plantable:Plant(ba.target, inst.owner)
                    end
                    inst:PerformBufferedAction()
                end

                inst:PushEvent("workdone")

                inst.sg:GoToState("idle") 
                inst.SoundEmitter:KillSound("eating") 
            end),
        },
    },

    State{
        name = "pickup",
        tags = {"pickup", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound(inst.sounds.."eat", "eating")
        end,

        events=
        {
            EventHandler("animover", function(inst) 
                local ba = inst:GetBufferedAction()
                if ba and ba.target and ba.target:IsValid() then
                    inst.components.inventory:GiveItem(ba.target)
                    inst:PerformBufferedAction()
                end
                --pick up doesn't counts like dowork
                inst.sg:GoToState("idle") 
                inst.SoundEmitter:KillSound("eating") 
            end),
        },
    },

    State{
        name = "till",
        tags = {"till", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound(inst.sounds.."eat", "eating")
        end,

        events=
        {
            EventHandler("animover", function(inst) 
                local ba = inst:GetBufferedAction()
                if ba and ba.pos and ba.pos.local_pt then
                    inst.components.quagmire_tiller:Till(ba.pos.local_pt, inst.owner)
                    inst:PerformBufferedAction()
                end
                
                inst:PushEvent("workdone")

                inst.sg:GoToState("idle") 
                inst.SoundEmitter:KillSound("eating") 
            end),
        },
    },

    State{
        name = "sleep",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PushAnimation("sleep_pre", false)
            inst.SoundEmitter:PlaySound(inst.sounds.."fallAsleep")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("sleeping") end ),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

    State{
        name = "sleeping",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_loop")
        end,

        timeline=
        {
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.."sleeping", "sleeping") end ),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

    State{
        name = "wake",
        tags = {"busy", "wakeup"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.SoundEmitter:KillSound("sleeping")
            inst.SoundEmitter:PlaySound(inst.sounds.."wakeUp")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
}

return StateGraph("spider", states, events, "idle", actionhandlers)
