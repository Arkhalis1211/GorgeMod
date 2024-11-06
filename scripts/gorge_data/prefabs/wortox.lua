-- Fox: Fixing his souls here
local wortox_soul_common = require("prefabs/wortox_soul_common")

wortox_soul_common.DoHeal = function(inst)
	if TheWorld.net and TheWorld.net.components.quagmire_hangriness then
		TheWorld.net.components.quagmire_hangriness:SoulPause()
	end
end

wortox_soul_common.HasSoul = function(victim)
	return not (victim:HasTag("shadowminion") or
				victim:HasTag("shadowcreature") or
				victim:HasTag("shadow"))
			and victim.components.health ~= nil
end

return {
	master_postinit = function(inst)
		inst:RemoveTag("souleater")
		
		inst:RemoveComponent("souleater")
		
		inst:RemoveEventCallback("gotnewitem", GetListener(inst, "gotnewitem"))
		inst:RemoveEventCallback("dropitem", GetListener(inst, "dropitem"))
		inst:RemoveEventCallback("soultoofew", GetListener(inst, "soultoofew"))
		inst:RemoveEventCallback("soulempty", GetListener(inst, "soulempty"))
	end,
}
