local menv = env
GLOBAL.setfenv(1, GLOBAL)

local UpvalueHacker = require("tools/upvaluehacker")

menv.AddComponentPostInit("worldcharacterselectlobby", function(self)
	local _OnWallUpdate = self.OnWallUpdate
	local fixed
	function self:OnWallUpdate(...)
		if not fixed then
			UpvalueHacker.SetUpvalue(self.CanPlayersSpawn, 1, "_countdownf")
			fixed = true
		end
		_OnWallUpdate(self, ...)
	end
end)

if TheNet:IsDedicated() then
	return
end

require("debugkeys")

local hungry
local speed = 0
AddGlobalDebugKey(KEY_F, function()
	local hanginess = TheWorld.net.components.quagmire_hangriness
	if TheInput:IsKeyDown(KEY_CTRL) then
		speed = speed + 0.1
		if speed > 15 then
			speed = 0
		end
		hanginess:DebugSetSpeed(speed)
	else
		hungry = not hungry
		if hungry then
			hanginess:DebugSetPercent(TUNING.GORGE.DANGER_THRESHOLD)
		else
			hanginess:DebugSetPercent(1)
		end
	end
end)

AddGlobalDebugKey(KEY_B, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		TheWorld.components.quagmire:GoodEnding()
	else
		TheWorld.components.quagmire:BadEnding()
	end
end)

AddGlobalDebugKey(KEY_K, function()
    local cooking = require("gorge_cooking")
    cooking.StressTestFood("oven", "quagmire_food_023")
end)

AddGlobalDebugKey(KEY_N, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		ForceAssetReset()
	end
end)

menv.modimport("scripts/tools/screen_dbg.lua")