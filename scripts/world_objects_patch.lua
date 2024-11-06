local map = require "map/static_layouts/events/quagmire_kitchen"

--Note: 1342x1215 - coords "spawnpoint_master" in quagmire_kitchen.lua table
local CENTER_X = 1342
local CENTER_Z = 1215
local MAP_TILE_WIDTH = 64
local MAP_TILE_HEIGHT = 64

local function _execute(snapx, snapz)
    for _, v in ipairs(map.layers) do
        if v.type == "objectgroup" then
            for _, o in ipairs(v.objects) do
                local prefab = o.type
                if prefab == "sapling" or
                   prefab == "berrybush2" or
                   prefab == "rabbit" or
                   prefab == "quagmire_spotspice_shrub" or
                   prefab == "quagmire_sugarwoodtree" or
                   prefab == "quagmire_fern" or
                   prefab == "quagmire_rubble_clocktower" or
                   prefab == "quagmire_rubble_empty" or
                   prefab == "quagmire_rubble_bike" or
                   prefab == "rocks" or
                   prefab == "firepit" then
                    local x = ((CENTER_X - o.x) / MAP_TILE_WIDTH) * TILE_SCALE
                    local z = (-(CENTER_Z - o.y) / MAP_TILE_HEIGHT) * TILE_SCALE
                    local ents = TheSim:FindEntities(snapx + x, 0, snapz + z, 0.5)

                    if ents[1] == nil or (ents[1] and ents[1].prefab ~= prefab) then
                        local inst = SpawnAt(prefab, Vector3(snapx + x, 0, snapz + z))
                        if o.properties["data.fueled.fuel"] ~= nil and inst.components.fueled then
                            inst.components.fueled:SetPercent(o.properties["data.fueled.fuel"])
                        end
                    end
                end
            end
        end
    end

    --now parkspikes supported x86 and x64

    local PARKSPIKE_X = ((CENTER_X - 1786) / MAP_TILE_WIDTH) * TILE_SCALE
    local PARKSPIKE1_Z = ((-(CENTER_Z - 1021) / MAP_TILE_HEIGHT) * TILE_SCALE)
    local PARKSPIKE2_Z = ((-(CENTER_Z - 1254) / MAP_TILE_HEIGHT) * TILE_SCALE)
    --Note: 0.72 = (0.18 * 4), look at function quagmire_parkspike_row in "map/layouts.lua"
    local parkspikes =
    {
        {prefab = "quagmire_parkspike", x = PARKSPIKE_X, z = PARKSPIKE1_Z + (0.72 * 0)},
        {prefab = "quagmire_parkspike_short", x = PARKSPIKE_X, z = PARKSPIKE1_Z + (0.72 * 1)},
        {prefab = "quagmire_parkspike", x = PARKSPIKE_X, z = PARKSPIKE1_Z + (0.72 * 2)},
        {prefab = "quagmire_parkspike_short", x = PARKSPIKE_X, z = PARKSPIKE1_Z + (0.72 * 3)},
        {prefab = "quagmire_parkspike", x = PARKSPIKE_X, z = PARKSPIKE2_Z + (0.72 * 8)}
    }

    for _, v in ipairs(parkspikes) do
        local ents = TheSim:FindEntities(snapx + v.x, 0, snapz + v.z, 0.5)
        if ents[1] == nil or (ents[1] and ents[1].prefab ~= v.prefab) then
            local inst = SpawnAt(v.prefab, Vector3(snapx + v.x, 0, snapz + v.z))
        end
    end
end

return
{
    Execute = _execute
}