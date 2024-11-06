local function PlayFallSound(inst, time)
	inst:DoTaskInTime(time * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/coins/drop") end)
end

local function OnDropped(inst)
	if inst.fx then
		inst.fx:Show()
		inst.fx:Appear()
	end
end

local function OnPickup(inst)
	if inst.fx then
		inst.fx:Hide()
	end
end

return {
	master_postinit = function(inst, hasfx)
		inst:AddComponent("inspectable")
	
		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
		
		if hasfx then
			inst.fx = inst:SpawnChild("quagmire_coin_fx")
			inst.fx:Appear()
		end
		
		inst.Toss = function(inst)
			inst.AnimState:PlayAnimation("toss1", false)
			inst.AnimState:PushAnimation("bounce"..math.random(1, 2), false)
			inst.AnimState:PushAnimation("idle", false)
			
			inst.components.inventoryitem.canbepickedup = false
			
			inst:DoTaskInTime(FRAMES * 20, function(inst)
				inst.components.inventoryitem.canbepickedup = true
			end)
			
			PlayFallSound(inst, 20)
			PlayFallSound(inst, 37)
		end
		
		inst.Fall = function(inst)
			if inst.fx then
				inst.fx:Hide()
			end
		
			inst.AnimState:PlayAnimation("fall", false)
			inst.AnimState:PushAnimation("bounce"..math.random(1,2), false)
			inst.AnimState:PushAnimation("idle", false)
			
			inst.components.inventoryitem.canbepickedup = false
			
			inst:DoTaskInTime(37 * FRAMES, function(inst)
				inst.components.inventoryitem.canbepickedup = true
			end)
			
			inst:DoTaskInTime(67 * FRAMES, function(inst)
				if not inst.fx then
					return
				end
				
				inst.fx:Show()
				inst.fx:Appear()
			end)
			
			PlayFallSound(inst, 37)
			PlayFallSound(inst, 54)
		end
		
		inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst)
			inst.AnimState:PlayAnimation("idle", false)
		end)
	end,
	
	master_postinit_fx = function(inst)
		inst.persists = false
		
		inst.Appear = function(inst)
			inst.AnimState:PlayAnimation("opal_pre")
			inst.AnimState:PlayAnimation("opal_loop", true)
		end
	end,
}
