return {
	[CUT_SCENE.WON] = function(self)
		local scene_time = 33 * FRAMES
		
		self.quagmire.endgame = true
		self.quagmire.gameresult = true
		
		for i, player in ipairs(AllPlayers) do
			if player.sg and not player.sg:HasStateTag("opening") then
				player.sg:GoToState("win")
			end
		end

		TheWorld:DoTaskInTime(1, function()
			for i, player in ipairs(AllPlayers) do
				player:DoTaskInTime(1, function(player)
					player:ScreenFade(false, 1)
					player:DoTaskInTime(1, function(player)
						player:ShowHUD(false)
						player:SetCameraDistance(11)
						if player.components.playercontroller ~= nil then
							player.components.playercontroller:EnableMapControls(false)
							player.components.playercontroller:Enable(false)
						end
						player:ShowActions(false)
					end)
				end)

				player:DoTaskInTime(2, function(player)
					if player.sg then
						player.sg:GoToState("idle_wait_before_jump")
					end
				end)

				player:DoTaskInTime(3, function(player)
					player:SnapCamera(true)
					player:ScreenFade(true, 1)
				end)

				local function CutScene()
					player:DoTaskInTime(i / #AllPlayers / 2, function(player)
						if player.sg then
							player.sg:GoToState("portal_jump")
						end
					end)
				end
				player:ListenForNextEvent("updatecutscene", CutScene, TheWorld)
			end

			TheWorld:DoTaskInTime(2, function()
				local count = #AllPlayers
				local pos = TheWorld.spawnportal:GetPosition()
				
				for i, player in ipairs(AllPlayers) do
					local angle = math.pi * 1.5 * i / count
					local range = 3

					if player.Physics then
						player.Physics:Teleport(pos.x + math.cos(angle) * range, 0, pos.z - math.sin(angle) * range)
					else
						player.Transform:SetPosition(pos.x + math.cos(angle) * range, 0, pos.z - math.sin(angle) * range)
					end
					player:ForceFacePoint(pos.x, 0, pos.z)
				end
				
				TheWorld.altar._camerafocus:set(true)
			end)

			TheWorld:DoTaskInTime(4, function()
				TheWorld.altar:PushEvent("ending")
			end)
			
			
			TheWorld:ListenForNextEvent("updatecutscene", function()
				TheWorld.spawnportal._camerafocus:set(false)
				TheWorld:DoTaskInTime(scene_time + 1 + #AllPlayers/10, function()
					self.quagmire:EndGame()
				end)
			end, TheWorld)
		end)
	end,
	
	[CUT_SCENE.LOST] = function(self)
		local trans_time = 356 * FRAMES + 4 -- 3 secons for fades + 1 second for math.random
		if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
			trans_time = 156 * FRAMES
		end
		self.quagmire.endgame = true
		self.quagmire.gameresult = false
		
		for i, player in ipairs(AllPlayers) do
			if player.sg then
				player.sg:GoToState("idle_scared")
			end
			player.cached_pos = player:GetPosition()

			local function CutScene()
				player:ScreenFade(false, 1)
				player:DoTaskInTime(1 + math.random(), function(player)
					if player.cached_pos then
						local pos = player.cached_pos
						if player.Physics then
							player.Physics:Teleport(pos.x, 0, pos.z)
						else
							player.Transform:SetPosition(pos.x, 0, pos.z)
						end
					end

					player:SnapCamera()
					player:ScreenFade(true, 1)

					if player.components.inventory ~= nil then
						local handsitem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
						if handsitem ~= nil then
							player.components.inventory:DropItem(handsitem, true, true)
						end
					end

					if not (GetGorgeGameModeProperty("murder_mystery") and player == TheWorld.net.components.quagmire_murdermysterymanager:GetMurder()) then
						if player.sg then
							if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
								if player.cached_pos then
									local deer_ice_circle = SpawnPrefab("deer_ice_circle")
									local pos = player.cached_pos
									deer_ice_circle.Transform:SetPosition(pos.x, 0, pos.z)
								end
								player.sg:GoToState("idle_scared")
								player:DoTaskInTime(1, function()
									if player.components.freezable then
										player.components.freezable.state = "FROZEN"
									end
									player.sg:GoToState("frozen")
								end)
							else
								if player:HasTag("merm") then
									player.sg:GoToState("transform_pig")
								else
									player.sg:GoToState("transform_merm")
								end
							end
						end
					else
						player.sg:GoToState("idle_scared", true)
					end
				end)
			end
			player:ListenForNextEvent("updatecutscene", CutScene, TheWorld)

			player:DoTaskInTime(3, function(player)
				player.cached_pos = player:GetPosition()
				local pos = TheWorld.spawnportal:GetPosition()
				if player.Physics then
					player.Physics:Teleport(pos.x, 0, pos.z)
				else
					player.Transform:SetPosition(pos.x, 0, pos.z)
				end

				player:SetCameraDistance(15)
				player:SnapCamera(true)
				player:ScreenFade(true, 1)
			end)

			player:ListenForEvent("onremove", function()
				TheWorld:PushEvent("player_mermified")
			end)
		end
		
		TheWorld:ListenForNextEvent("updatecutscene", function()
			TheWorld:DoTaskInTime(trans_time, function()
				self.quagmire:EndGame()
			end)
		end, TheWorld)
	end,
}
