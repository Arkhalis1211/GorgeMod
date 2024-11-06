return {
	master_postinit = function(inst)
		TheWorld.altar = inst

		inst:AddComponent("inspectable")
		inst:AddComponent("quagmire_altar")

		inst:SetStateGraph("SGaltar")
	end,
}
