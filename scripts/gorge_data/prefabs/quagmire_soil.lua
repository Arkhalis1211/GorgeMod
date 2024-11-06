--[[
Note. support animation quagmire_soil:
    rise
	risen
	collapse_full
	break
	broken
	collapse_broken
	grow_small
	crop_small
	grow_med
	crop_med
	grow_full
	crop_full
	grow_rot
	crop_rot
	picked
	dug
]]

local function onbreak(inst)
    inst.AnimState:PlayAnimation("break")
    inst.AnimState:PushAnimation("broken")
    inst:RemoveTag("soil")
    inst:AddTag("brokensoil")
end

local function oncollapse(inst)
    inst.AnimState:PlayAnimation("collapse_broken")
    inst:RemoveTag("brokensoil")
    inst:ListenForEvent("animover", inst.Remove)
end

return {
	master_postinit = function(inst)
        inst:ListenForEvent("break", onbreak)
        inst:ListenForEvent("collapse", oncollapse)
	end,
}
