local assets =
{
    Asset("ANIM", "anim/lighter_victorian.zip"),
}

local prefabs =
{
    "lighterfire",
}

local function SpawnFire(inst)
	if not inst.fire then
		local fx = SpawnPrefab("lighterfire")
		
		fx.entity:SetParent(inst.entity)
		fx.entity:AddFollower()
		fx.Follower:FollowSymbol(inst.GUID, "lighter", 7, -75, 0)
		fx:AttachLightTo(inst)
		
		inst.fire = fx
	end
end

local function RemoveFire(inst)
	if inst.fire then
		inst.fire:Remove()
		inst.fire = nil
	end
end

local function OnDropped(inst)
	if inst.components.quagmire_cd:GetCD() == 0 then
		SpawnFire(inst)
	end
end

local function OnCDDone(inst)
	if not inst:HasTag("cooker") then
		inst:AddTag("cooker")
	end
	
	if not inst.components.inventoryitem.owner then
		SpawnFire(inst)
	end
end

local function OnCook(inst, item, chef)
	inst.components.quagmire_cd:StartCD(TUNING.GORGE.LIGHTER_CD)
	
	inst:RemoveTag("cooker")
	
	RemoveFire(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lighter_victorian")
    inst.AnimState:SetBuild("lighter_victorian")
    inst.AnimState:PlayAnimation("idle")
	
	local s = 1.35
	inst.AnimState:SetScale(s, s, s)

	inst:AddComponent("quagmire_cd")

    inst:AddTag("dangerouscooker")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

	inst:SetPrefabNameOverride("lighter")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    -----------------------------------
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/gorge_inv.xml"
	inst.components.inventoryitem.imagename = "lighter_victorian"
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem:SetOnPickupFn(RemoveFire)
	
    -----------------------------------
    inst:AddComponent("cooker")
	inst.components.cooker.CanCook = function(self, item, chef)
		return chef and chef:HasTag("pyromaniac") and self.inst.components.quagmire_cd:GetCD() == 0
	end
	inst.components.cooker.oncookfn = OnCook

    inst:AddComponent("inspectable")
	
	inst:ListenForEvent("cd_done", OnCDDone)

    return inst
end

return Prefab("quagmire_lighter", fn, assets, prefabs)
