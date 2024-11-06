local menv = env
GLOBAL.setfenv(1, GLOBAL)

local screen = "screens/gorge_gamemode"
local old
local curr = ""

rawset(_G, "SetScreen", function(scr) --SetScreen "screens/bell_shop_screen"
	screen = scr
end)

AddGlobalDebugKey(KEY_Z, function()
	local FE = TheFrontEnd
	curr = FE:GetActiveScreen().name
	
	if curr == old then
		FE:PopScreen(FE:GetActiveScreen())
	end
	
	package.loaded[screen] = nil
	local loaded, msg = pcall(require, screen)
	if loaded then
		local pushed, error = pcall(function()
			FE:PushScreen(require(screen)())
			old = FE:GetActiveScreen().name
		end)
		print("Pushed:", pushed, error)
	else
		print("ERROR:", msg)
	end
end)
