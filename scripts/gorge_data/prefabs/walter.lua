local PerksData = require "gorge_perks"

local function SpawnWoby(inst)
    local attempts = 0
    
    local max_attempts = 30
    local x, y, z = inst.Transform:GetWorldPosition()

    local woby = SpawnPrefab("quagmire_wobysmall")
	inst.woby = woby
	woby:LinkToPlayer(inst)
    inst:ListenForEvent("onremove", inst._woby_onremove, woby)
	woby:PushEvent("spawn")
	woby.Transform:SetPosition(TheWorld.spawnportal:GetPosition():Get())
	woby:Hide()
	local wobyfx = SpawnAt("quagmire_portal_player_fx", woby)
	woby:DoTaskInTime(1.2, function(inst)
		woby:Show()
		if woby.sg then
			woby.sg:GoToState("idle")
		end
		
		woby:DoTaskInTime(.1, function(inst)
			local fx = SpawnPrefab("quagmire_portal_playerdrip_fx")
			fx.entity:SetParent(woby.entity)
			fx.entity:AddFollower()
			fx.Follower:FollowSymbol(woby.GUID, "body", 0, 200, 0)
		end)
	end)		
	
    return woby
end

return {
	master_postinit = function(inst)
		inst:RemoveComponent("storyteller")
		inst._woby_spawntask:Cancel() --Asura: Remove old Woby
			inst._woby_spawntask = inst:DoTaskInTime(3, function(i) 
				if not inst:HasTag("quagmire_shooter") then
					i._woby_spawntask = nil 
					SpawnWoby(i) 
				end
			end)
		inst.SpawnWoby = SpawnWoby
	end,
}
