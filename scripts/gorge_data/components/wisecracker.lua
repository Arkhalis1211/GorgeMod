return {
	AddQuagmireEventListeners = function(inst)
		inst:ListenForEvent("ms_gameend", function(w, win)
			inst.components.talker:Say(GetString(inst, win == 1 and "QUAGMIRE_ANNOUNCE_WIN" or "QUAGMIRE_ANNOUNCE_LOSE"))
		end, TheWorld)
	end,
}
