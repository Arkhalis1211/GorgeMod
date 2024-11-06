return {
	master_postinit = function(self, inst, _netvars)
		inst:ListenForEvent("hangriness_delta", function(src, data)
			_netvars.level:set(data.percent <= TUNING.GORGE.DANGER_THRESHOLD and 2 or 1)
		end, TheWorld)
		
		inst:ListenForEvent("ms_gameend", function(src, win)
			if win == 1 then
				_netvars.won:push()
			end
		end, TheWorld)
	end,
}
