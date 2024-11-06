local assets =
{
    Asset("ANIM", "anim/lantern_victorian.zip"),
    Asset("ANIM", "anim/swap_lantern_victorian.zip"),
	
    Asset("ATLAS", "images/gorge_inv.xml"),
    Asset("IMAGE", "images/gorge_inv.tex"),
}

local prefabs =
{
    "quagmire_lantern_light",
}

local function DoTurnOffSound(inst, owner)
    inst._soundtask = nil
    (owner ~= nil and owner:IsValid() and owner.SoundEmitter or inst.SoundEmitter):PlaySound("dontstarve/wilson/lantern_off")
end

local function PlayTurnOffSound(inst)
    if inst._soundtask == nil and inst:GetTimeAlive() > 0 then
        inst._soundtask = inst:DoTaskInTime(0, DoTurnOffSound, inst.components.inventoryitem.owner)
    end
end

local function PlayTurnOnSound(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    elseif not POPULATING then
        inst._light.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on")
    end
end

local function onremovelight(light)
    light._lantern._light = nil
end

local function stoptrackingowner(inst)
    if inst._owner ~= nil then
        inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
        inst._owner = nil
    end
end

local function starttrackingowner(inst, owner)
    if owner ~= inst._owner then
        stoptrackingowner(inst)
        if owner ~= nil and owner.components.inventory ~= nil then
            inst._owner = owner
            inst:ListenForEvent("equip", inst._onownerequip, owner)
        end
    end
end

local function turnon(inst)
	local owner = inst.components.inventoryitem.owner

	if inst._light == nil then
		inst._light = SpawnPrefab("quagmire_lantern_light")
		inst._light._lantern = inst
		inst:ListenForEvent("onremove", onremovelight, inst._light)
		PlayTurnOnSound(inst)
	end
	inst._light.entity:SetParent((owner or inst).entity)

	inst.AnimState:PlayAnimation("idle_on", true)

	if owner ~= nil and inst.components.equippable:IsEquipped() then
		owner.AnimState:Show("LANTERN_OVERLAY")
	end

	inst.components.machine.ison = true
	inst.components.inventoryitem:ChangeImageName("quagmire_lantern_lit")
	inst:PushEvent("lantern_on")
end

local function turnoff(inst)
    stoptrackingowner(inst)

    if inst._light ~= nil then
        inst._light:Remove()
        PlayTurnOffSound(inst)
    end

    inst.AnimState:PlayAnimation("idle_off", false)

    if inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:Hide("LANTERN_OVERLAY")
    end

	inst.components.inventoryitem:ChangeImageName("quagmire_lantern")
	
    inst.components.machine.ison = false
    inst:PushEvent("lantern_off")
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_lantern_victorian", "swap_lantern_victorian")
	owner.AnimState:OverrideSymbol("lantern_overlay", "swap_lantern", "lantern_overlay")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

	owner.AnimState:Show("LANTERN_OVERLAY")
	turnon(inst)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")

    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end
end

local function lantern_onremovefx(fx)
    fx._lantern._lit_fx_inst = nil
end

local function lantern_enterlimbo(inst)
    if inst._lit_fx_inst ~= nil then
        inst._lit_fx_inst._lastpos = inst._lit_fx_inst:GetPosition()
        local parent = inst.entity:GetParent()
        if parent ~= nil then
            local x, y, z = parent.Transform:GetWorldPosition()
            local angle = (360 - parent.Transform:GetRotation()) * DEGREES
            local dx = inst._lit_fx_inst._lastpos.x - x
            local dz = inst._lit_fx_inst._lastpos.z - z
            local sinangle, cosangle = math.sin(angle), math.cos(angle)
            inst._lit_fx_inst._lastpos.x = dx * cosangle + dz * sinangle
            inst._lit_fx_inst._lastpos.y = inst._lit_fx_inst._lastpos.y - y
            inst._lit_fx_inst._lastpos.z = dz * cosangle - dx * sinangle
        end
    end
end

local function lantern_off(inst)
    local fx = inst._lit_fx_inst
    if fx ~= nil then
        if fx.KillFX ~= nil then
            inst._lit_fx_inst = nil
            inst:RemoveEventCallback("onremove", lantern_onremovefx, fx)
            fx:RemoveEventCallback("enterlimbo", lantern_enterlimbo, inst)
            fx._lastpos = fx._lastpos or fx:GetPosition()
            fx.entity:SetParent(nil)
            if fx.Follower ~= nil then
                fx.Follower:FollowSymbol(0, "", 0, 0, 0)
            end
            fx.Transform:SetPosition(fx._lastpos:Get())
            fx:KillFX()
        else
            fx:Remove()
        end
    end
end

local function lantern_on(inst)
    local owner = inst.components.inventoryitem.owner
    if owner ~= nil then
        if inst._lit_fx_inst ~= nil and inst._lit_fx_inst.prefab ~= inst._heldfx then
            lantern_off(inst)
        end
        if inst._heldfx ~= nil and inst._lit_fx_inst == nil then
			inst._lit_fx_inst = SpawnPrefab("cane_victorian_fx")
			inst._lit_fx_inst._lantern = inst
			inst:ListenForEvent("onremove", lantern_onremovefx, inst._lit_fx_inst)
				
            inst._lit_fx_inst.entity:SetParent(owner.entity)
			
			inst._lit_fx_inst.entity:AddFollower()
            inst._lit_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 65, -10, 0)
        end
    else
        if inst._lit_fx_inst ~= nil and inst._lit_fx_inst.prefab ~= inst._groundfx then
            lantern_off(inst)
        end
        if inst._groundfx ~= nil and inst._lit_fx_inst == nil then
			inst._lit_fx_inst = SpawnPrefab("cane_victorian_fx")
			inst._lit_fx_inst._lantern = inst
			inst:ListenForEvent("onremove", lantern_onremovefx, inst._lit_fx_inst)
			if inst._lit_fx_inst.KillFX ~= nil then
				inst._lit_fx_inst:ListenForEvent("enterlimbo", lantern_enterlimbo, inst)
			end
			
			inst._lit_fx_inst.entity:SetParent(inst.entity)
			
			inst._lit_fx_inst.entity:AddFollower()
			inst._lit_fx_inst.Follower:FollowSymbol(inst.GUID, "lantern01", 6, -63, 0)
		end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lantern_victorian")
    inst.AnimState:SetBuild("lantern_victorian")
    inst.AnimState:PlayAnimation("idle_off", false)

    inst:AddTag("light")

	inst:SetPrefabNameOverride("lantern")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/gorge_inv.xml"
    inst.components.inventoryitem.imagename = "quagmire_lantern.tex"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("equippable")

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0

    inst._light = nil

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.OnRemoveEntity = OnRemove

    inst._onownerequip = function(owner, data)
        if data.item ~= inst and (data.eslot == EQUIPSLOTS.HANDS) then
            turnoff(inst)
        end
    end
	
	inst._heldfx = {"cane_victorian_fx"}
	inst._groundfx = {"cane_victorian_fx"}
	
	inst:ListenForEvent("lantern_on", lantern_on)
	inst:ListenForEvent("lantern_off", lantern_off)
	inst:ListenForEvent("unequipped", lantern_off)
	inst:ListenForEvent("onremove", lantern_off)
	
    return inst
end

local function lanternlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(3)
	
	inst.Light:SetIntensity(.4)
	inst.Light:SetFalloff(1.35)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("quagmire_lantern", fn, assets, prefabs),
    Prefab("quagmire_lantern_light", lanternlightfn)