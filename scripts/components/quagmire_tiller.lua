local Quagmire_Tiller = Class(function(self, inst)
    self.inst = inst
end)

function Quagmire_Tiller:Till(pos, doer)
    if not TheWorld.Map:CanTillSoilAtPoint(pos) then
        return false
    end

    local ents = TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, nil, {"soil", "brokensoil"})
    for _, inst in pairs(ents) do
        if inst:HasTag("brokensoil") then
            inst:PushEvent("collapse")
        end
        if inst:HasTag("soil") then
            inst:PushEvent("break")
        end
    end

    SpawnPrefab("quagmire_soil").Transform:SetPosition(pos.x, 0, pos.z)

    if doer then
        UpdateAchievement("farm_till", doer.userid)
    end

    return true
end

return Quagmire_Tiller