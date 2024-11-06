local function CreateLight()
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddLight()

    fx.Light:SetRadius(1)
    fx.Light:SetIntensity(.4)
    fx.Light:SetFalloff(1.35)
    fx.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
    fx.Light:Enable(false)

    return fx
end

local function OnTargetDirty(inst)
    if not TheNet:IsDedicated() then
        if inst._target:value() ~= nil and inst._target:value() == ThePlayer then 
            inst.lightfx.Light:Enable(true)
        else
            inst.lightfx.Light:Enable(false)
        end
    end
end

local function OnRadiusDirty(inst)
    if not TheNet:IsDedicated() then
        inst.lightfx.Light:SetRadius(inst._radius:value())
    end
end

local function SetTarget(inst, target)
    target._mmlight = inst
    inst.entity:SetParent(target.entity)
    inst._target:set(target)
    OnTargetDirty(inst)
end

local function SetType(inst, typelight)
    if typelight == "murder" then
        inst._radius:set(14)
    elseif typelight == "innocent" then
        inst._radius:set(7)
    end
    OnRadiusDirty(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")

    inst._target = net_entity(inst.GUID, "quagmire_playerlight._target", "targetdirty")
    inst._radius = net_ushortint(inst.GUID, "quagmire_playerlight._radius", "radiusdirty")

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        inst.lightfx = CreateLight()
        inst.lightfx.entity:SetParent(inst.entity)
    end

    if not TheWorld.ismastersim then
        inst:ListenForEvent("targetdirty", OnTargetDirty)
        inst:ListenForEvent("radiusdirty", OnRadiusDirty)
        return inst
    end

    inst.SetTarget = SetTarget
    inst.SetType = SetType

    return inst
end

return Prefab("quagmire_playerlight", fn)
