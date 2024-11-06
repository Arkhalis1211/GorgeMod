local function onturnon(inst, self, owner)
    inst.AnimState:PushAnimation("proximity_loop", true)
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/mealing_stone/proximity_LP", "mealing")
end

local function onturnoff(inst)
    inst.AnimState:PushAnimation("idle", true)
	inst.SoundEmitter:KillSound("mealing")
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")

		MakeQuagmireShop(inst, onturnon, onturnoff)	
	end,
}
