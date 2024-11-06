local function GetDebugString(inst)
    local result = "STEWER-> <none>"
    local stewer = nil

    if inst.takeitem:value() ~= nil then
        stewer = inst.takeitem:value()
    elseif inst.components.quagmire_stewer ~= nil then
        stewer = inst
    end

    if stewer ~= nil and stewer.components.quagmire_stewer ~= nil then
        result = "STEWER-> "..stewer.components.quagmire_stewer:GetDebugString()
    end

    return result
end

-- Surg, fueled sections: 
--     1 - ~21 sec.
--     2 - ~28 sec.
--     3 - ~43 sec.
--     4 - ~88 sec.
-- amount 180 seconds
local function OnFueldSectionChanged(inst, section)
    local station = inst.prefaboverride:value()
    local cofficient = 1  -- sections 0 and 2 have cofficient 1 (~43 sec.)

    if section.newsection == 4 then
        cofficient = 2.12 -- ~21 sec.
    elseif section.newsection == 3 then 
        cofficient = 1.5  -- ~28 sec.
    elseif section.newsection == 1 then
        cofficient = 0.5  -- ~88 sec.
    end

    inst.components.fueled.rate_modifiers:SetModifier(inst.prefab, cofficient)

    if station ~= nil then
        if station.OnFueldSectionChanged ~= nil then
            station:OnFueldSectionChanged(section.newsection, section.oldsection)
        end
    end
end

local function OnPercentUsedChange(inst, percentused)
    local stewer = nil

    if inst.takeitem:value() ~= nil then
        stewer = inst.takeitem:value()
    elseif inst.components.quagmire_stewer ~= nil then
        stewer = inst
    end
end

return {
    master_postinit = function(inst, OnPrefabOverrideDirty, OnRadiusDirty)        
        inst:RemoveTag("quagmire_stewer")
        inst:RemoveTag("quagmire_cookwaretrader")
        inst:RemoveComponent("cooker")

        inst.components.fueled.maxfuel = TUNING.GORGE.FIREPIT_FUEL_MAX
        inst.components.fueled.bonusmult = 0.999 --can't be 1

        --need add befor installations
        inst:AddComponent("container")
        inst.components.container.canbeopened = false

        inst:AddComponent("quagmire_installations")
        inst.components.quagmire_installations.oninstallfn = function(inst, station)
            local stationprefab = station.prefab

            if stationprefab == "quagmire_grill" or stationprefab == "quagmire_grill_small" then
                inst.components.container.canbeopened = true
                inst.components.container:WidgetSetup(stationprefab)
            end

            inst.prefaboverride:set(station)
            inst.radius:set(140)

            OnPrefabOverrideDirty(inst)
            OnRadiusDirty(inst)
        end

        inst:ListenForEvent("onfueldsectionchanged", OnFueldSectionChanged)
        inst:ListenForEvent("percentusedchange", OnPercentUsedChange)

        inst:DoTaskInTime(0, function(inst)
            local mum = TheSim:FindFirstEntityWithTag("goatmum")
            if mum and mum.points then
                table.insert(mum.points, inst)
            end
        end)

        inst.debugstringfn = GetDebugString
    end,
}
