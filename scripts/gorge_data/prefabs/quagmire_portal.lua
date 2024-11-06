local function FindMumsy(inst)
	local mumsy = TheSim:FindFirstEntityWithTag("goatmum")
	if mumsy then
		if mumsy.components.knownlocations then
			mumsy.components.knownlocations:RememberLocation("portal", inst:GetPosition())
		end

		inst.mumsy = mumsy
	end
end

local function Activate(inst)
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/portal/LP", "LP")
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/portal/pre")

	inst.fx = inst:SpawnChild("quagmire_portal_activefx")
end

return {
	master_postinit = function(inst)
		TheWorld.spawnportal = inst
		
		function inst:Activate()
			-- print("[Quagmire_Portal] Activate")
			if inst.fx then
				return
			end

			TheWorld:PushEvent("ms_portalactivate")

			Activate(inst)
			inst:DoTaskInTime(3 + #GetPlayerClientTable()/10, inst.Deactivate)
		end

		function inst:Deactivate()
			-- print("[Quagmire_Portal] Deactivate")
			if not inst.fx then
				return
			end

			inst.fx.AnimState:PushAnimation("portal_pst")
			inst.fx:ListenForEvent("animover", function(fx)
				if inst.AnimState:AnimDone() then
					fx:Remove()
					inst.fx = nil
				end
			end)

			inst.SoundEmitter:KillSound("LP")

			if inst.mumsy then
				inst.mumsy.components.goatmum.portal = nil
				inst.mumsy = nil
			end

			inst.fx = nil
		end

		function inst:EndGame()
			if GetGorgeGameModeProperty("darkness") then
				inst.light = SpawnAt("quagmire_lantern_light", inst)
				inst.light.Light:SetRadius(6)
			end
		
			inst._camerafocus:set(true)
			Activate(inst)
			inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 0.5, function()
				local mumsy = TheSim:FindFirstEntityWithTag("goatmum")
				if mumsy then
					mumsy:PushEvent("start_talking")
				end
			end)
			for i, player in ipairs(AllPlayers) do
				player:DoTaskInTime(0, function(player)
					player:SetCameraDistance(17)
				end)
			end
		end
		
		inst:DoTaskInTime(0, function(inst)
			FindMumsy(inst)
			if inst.mumsy then
				inst.mumsy.components.goatmum.portal = inst
			end
		end)
		
	end
}
