
return {
	master_postinit = function(inst)
		if GetGorgeGameModeProperty("moon_curse") then
			inst:AddComponent("quagmire_brightmarespawner")
		end
		inst:AddComponent("quagmire")
		
		inst:AddComponent("quagmire_birdspawner")
		
		inst:AddComponent("quagmire_perks")
		
		inst:AddComponent("quagmireanalytics")
		
		inst:DoTaskInTime(0, function(inst)
			if TheSim:FindFirstEntityWithTag("sammy") ~= nil then
				return
			end
			
			local spawn_point = TheSim:FindFirstEntityWithTag("sammy_point")
			if spawn_point then
				local off = 154 * DEGREES
				local r = 3.2
				local pos = spawn_point:GetPosition()
				
				SpawnPrefab("quagmire_trader_merm").Transform:SetPosition(pos.x + math.cos(off) * r, 0, pos.z + math.sin(off) * r) 
			end
		end)
	end,
}
