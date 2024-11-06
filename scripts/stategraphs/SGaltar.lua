-- Fox: Those symbols were refrenced only in bunaries:
-- swap_plate(bowl) swap_food_plate(bowl)

local events =
{
	EventHandler("craving_placed", function(inst, data)
        inst.sg:GoToState("idle_food", data.food)
    end),
	EventHandler("ending", function(inst)
		inst.sg:GoToState("ending")
    end),
}

local states =
{
	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_empty")
		end,
	},
	
	State{
		name = "idle_food",
		tags = {"idle", "full"},

		onenter = function(inst, food_data)
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/cooking/dish_place")

			inst.AnimState:PlayAnimation("idle_food", true)
			inst.AnimState:Show("shadow")
			
			if GetGorgeGameModeProperty("confusion_enabled") then
				local fx = SpawnPrefab("nightmarefuel")
				
				fx:AddTag("FX")
				fx:AddTag("NOCLICK")
				fx:RemoveComponent("stackable")
				fx:RemoveComponent("inspectable")
				fx:RemoveComponent("inventoryitem")
				fx:RemoveComponent("fuel")
				
				fx.AnimState:SetMultColour(1,1,1,1)
				fx.entity:SetParent(inst.entity)
				fx.entity:AddFollower()
				if food_data.dish == "bowl" then
					fx.Follower:FollowSymbol(inst.GUID, "swap_food_"..food_data.dish, 0, -35, 0)
				else
					fx.Follower:FollowSymbol(inst.GUID, "swap_food_"..food_data.dish, 0, 0, 0)
				end
				inst.AnimState:HideSymbol("swap_food_"..food_data.dish)
				inst:DoTaskInTime(TUNING.GORGE.ALTAR.SNACRIFICE_DELAY-1, function()
					fx:Remove()
					local fx = SpawnPrefab("die_fx")
					fx.entity:SetParent(inst.entity)
					fx.entity:AddFollower()
					if food_data.dish == "bowl" then
						fx.Follower:FollowSymbol(inst.GUID, "swap_food_"..food_data.dish, 0, -35, 0)
					else
						fx.Follower:FollowSymbol(inst.GUID, "swap_food_"..food_data.dish, 0, 0, 0)
					end
					inst.AnimState:ShowSymbol("swap_food_"..food_data.dish)
				end)
			end
			inst.AnimState:OverrideSymbol("swap_food_"..food_data.dish, food_data.product, "swap_food")
			inst.AnimState:OverrideSymbol("swap_"..food_data.dish, "quagmire_generic_"..food_data.dish, (food_data.silverdish and "silver" or "generic").."_"..food_data.dish)

			inst.sg.mem.food = food_data

			inst.sg:SetTimeout(TUNING.GORGE.ALTAR.SNACRIFICE_DELAY)
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("snacrifice")
		end,
	},

	State{
		name = "snacrifice",
		tags = {"busy", "full"},

		onenter = function(inst, food)
			inst.AnimState:PlayAnimation("teleport")
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/alter/offering")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},

		onexit = function(inst)
			inst.AnimState:Hide("shadow")
			inst.AnimState:ClearAllOverrideSymbols()
			if inst.sg.mem.food then
				TheWorld.components.quagmire:PushSnacrifice(inst.sg.mem.food)
				inst.sg.mem.food = nil
			end
		end,
	},

	State{
		name = "ending",
		tags = {"busy"},

		onenter = function(inst, food)
			inst._camerafocus:set(true)
			inst.AnimState:OverrideSymbol("ivy", "quagmire_altar", "ivy")
			inst.AnimState:Show("ivy")
			inst.AnimState:PlayAnimation("ending")
		end,

		timeline = {
			TimeEvent(13 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/alter/key_in")
			end)
		},

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("ending_loop")
			end),
		},

		onexit = function(inst)
			inst:DoTaskInTime(.25, function(inst)
				TheWorld.spawnportal:EndGame()
				inst._camerafocus:set(false)
			end)
		end,
	},

	State{
		name = "ending_loop",
		tags = {"idle"},

		onenter = function(inst, food)
			inst.AnimState:PlayAnimation("ending_loop", true)
		end,
	},
}

return StateGraph("quagmire_altar", states, events, "idle", {})
