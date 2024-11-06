local menv = env
GLOBAL.setfenv(1, GLOBAL)

-- Fox: Load translations here
local translations = {}
function LoadGorgeTranslation(name)
	table.insert(translations, name)
end

menv.AddSimPostInit(function()
	if not next(translations) then
		return
	end
	
	for _, name in ipairs(translations) do
		print("[Gorge] Loading translation", name)
		require("translations/"..name)
	end
end)
