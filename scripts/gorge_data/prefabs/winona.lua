return {
	master_postinit = function(inst)
		if inst:HasTag("hungrybuilder") then
			inst:RemoveTag("hungrybuilder")
		end
	end,
}
