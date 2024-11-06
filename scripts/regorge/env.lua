GorgeEnv = require("gorge_mod_fns")

local _InitializeModMain = ModManager.InitializeModMain
function ModManager:InitializeModMain(modname, env, mainfile, ...)
	if CHEATS_ENABLED then
		print(string.format("[DEBUG: GORGE] Injecting into %s", modname))
	end
	if env.GorgeEnv ~= GorgeEnv then
		env.GorgeEnv = GorgeEnv
	end
    return _InitializeModMain(self, modname, env, mainfile, ...)
end
