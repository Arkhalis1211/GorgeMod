local assets =
{
    Asset("ANIM", "anim/spat_bomb.zip"),
}

local prefabs =
{
    "spat_splat_fx",
    "spat_splash_fx_full",
    "spat_splash_fx_med",
    "spat_splash_fx_low",
    "spat_splash_fx_melted",
}

local function doprojectilehit(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_hit")
	
    SpawnAt("spat_splat_fx", inst).Transform:SetScale(1.65, 1.65, 1.65)

	local x, y, z = inst.Transform:GetWorldPosition()
	
	for i, player in ipairs(TheSim:FindEntities(x, 0, z, 5.5, {"player"}, {"notarget"})) do
        if player.components.pinnable ~= nil then
			if not player.components.pinnable:IsStuck() then
				player.components.pinnable:Stick()
			end
        end
	end
end

local function oncollide(inst, other)
    doprojectilehit(inst)
    inst:Remove()
end

local function OnHit(inst, attacker, target)
    doprojectilehit(inst, attacker)
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddPhysics()
	
	inst.Physics:SetMass(2)
	inst.Physics:SetFriction(.1)
	inst.Physics:SetDamping(0)
	inst.Physics:SetRestitution(.5)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
	inst.Physics:SetCapsule(0.5, 0.5)
	inst.Physics:SetDontRemoveOnSleep(true)

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")
	
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("spat_bomb")
    inst.AnimState:SetBuild("spat_bomb")
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.AnimState:SetScale(2, 2, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst.Physics:SetCollisionCallback(oncollide)

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetGravity(-100)
    inst.components.complexprojectile:SetOnHit(OnHit)

	inst.persists = false
	
    return inst
end

return Prefab("gnaw_projectile", fn, assets, prefabs)
