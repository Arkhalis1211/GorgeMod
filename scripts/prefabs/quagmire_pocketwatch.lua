
local assets =
{
    Asset("SCRIPT", "scripts/prefabs/pocketwatch_common.lua"),
    Asset("ANIM", "anim/pocketwatch.zip"),
    Asset("ANIM", "anim/pocketwatch_marble.zip"),
}

local prefabs = 
{
	"pocketwatch_cast_fx",
	"pocketwatch_cast_fx_mount",
	"pocketwatch_heal_fx",
	"pocketwatch_heal_fx_mount",
}

local PocketWatchCommon = require "prefabs/pocketwatch_common"

local function Heal_DoCastSpell(inst, doer)
	local health = doer.components.health

    if health and not health:IsDead() then
		local fx = SpawnPrefab("pocketwatch_heal_fx")
		fx.entity:SetParent(doer.entity)

		inst.components.rechargeable:Discharge(TUNING.GORGE.POCKETWATCH.COOLDOWN)
		local x, y, z = doer.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, TUNING.GORGE.POCKETWATCH.RANGE, nil, {"small_livestock"}, { "fresh", "stale", "spoiled" })

		for k, v in ipairs(ents) do
            if v and v.components.perishable then
                v.components.perishable:AddTime(TUNING.GORGE.POCKETWATCH.FRESHNESS)
                v:DoTaskInTime(math.random(), function() 
                    local fx = SpawnPrefab("pocketwatch_heal_fx")
                    fx.entity:SetParent(v.entity)
                    fx.Transform:SetScale(0.75, 0.75, 0.75)
                    fx.Transform:SetPosition(0, -1, 0)
                end)
            end
        end

		return true
	end
end

local function fn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_marble", Heal_DoCastSpell, true)

    if not TheWorld.ismastersim then
        return inst
    end

	inst.castfxcolour = {255 / 255, 241 / 255, 236 / 255}
	inst.components.inventoryitem:ChangeImageName("pocketwatch_heal")

    return inst
end

return Prefab("quagmire_pocketwatch", fn, assets, prefabs)