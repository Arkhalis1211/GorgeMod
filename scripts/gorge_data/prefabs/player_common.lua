local SPAWN_DELAY = 1.5

local function GetPlayerIndex(inst)
	for i, player in ipairs(AllPlayers) do
		if player == inst then
			return i
		end
	end
	return 0
end

return {
	master_postinit = function(inst)
		inst.quagmired = true
		
		--[[
		inst.EnableFire = function(inst, val)
			if val then
				if inst._fire then
					return
				end
				
				local fx = SpawnPrefab("quagmire_fire")
				if fx then
					fx.entity:SetParent(inst.entity)
					fx.entity:AddFollower()
					fx.Follower:FollowSymbol(inst.GUID, "swap_hat", 0, -250, 0)
					
					inst._fire = fx
				end
			elseif inst._fire then
				inst._fire:Remove()
				inst._fire = nil
			end
		end
		
		if GetGorgeGameModeProperty("darkness") then
			inst.fire = inst:SpawnChild("quagmire_light")
		
			inst.AnimState:OverrideSymbol("swap_hat", "hat_candle", "swap_hat")
			inst.AnimState:Show("HAT")
			inst.AnimState:Show("HAIR_HAT")
			inst.AnimState:Hide("HAIR_NOHAT")
			inst.AnimState:Hide("HAIR")
			
			inst:EnableFire(true)
		end]]
		
		inst.DoSpawn = function(inst)
			local playerfx = SpawnAt("quagmire_portal_player_fx", inst)
			if inst:HasTag("epic") then
				playerfx.Transform:SetScale(2.5, 2.5, 2.5)
			end
			inst:DoTaskInTime(1.2, function(inst)
				if inst.sg then
					inst.sg:GoToState("idle")
				end
				
				inst:DoTaskInTime(.1, function(inst)
					local fx = SpawnPrefab("quagmire_portal_playerdrip_fx")
					fx.entity:SetParent(inst.entity)
					fx.entity:AddFollower()
					fx.Follower:FollowSymbol(inst.GUID, "torso", 0, 50, 0)
				end)
			end)
		end
		
		inst:DoTaskInTime(0, function(inst)
			if inst.components.health then
				inst.components.health:SetInvincible(true)
			end
		end)
		
		inst:ListenForEvent("respawnfromcorpse", function(inst)
			inst:DoTaskInTime(1, function(inst)
				inst:ListenForNextEvent("newstate", function(inst)
					if inst.components.health then
						inst.components.health:SetInvincible(true)
					end
				end)
			end)
		end)
	end,
}
