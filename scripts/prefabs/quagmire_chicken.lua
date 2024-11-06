require "stategraphs/SGquagmirechicken"

local assets =
{
	Asset("ANIM", "anim/chicken.zip"),
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddDynamicShadow()
	inst.entity:AddPhysics()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	inst.Transform:SetFourFaced()

	inst:AddTag("animal")
	inst:AddTag("prey")
	inst:AddTag("chicken")
	inst:AddTag("smallcreature")

	MakeCharacterPhysics(inst, 1, 0.5)
	
	inst.DynamicShadow:SetSize(1, 1)

	inst.AnimState:SetBank("chicken")
	inst.AnimState:SetBuild("chicken")
	inst.AnimState:PlayAnimation("idle", true)
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)

	inst:AddComponent("combat")

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.RABBIT_RUN_SPEED
	inst.components.locomotor.runspeed = TUNING.RABBIT_RUN_SPEED
	
	inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.NAMES.CHICKEN
    inst.components.named:PickNewName()
	
	inst:AddComponent("knownlocations")

	inst:SetStateGraph("SGquagmirechicken")
	inst:SetBrain(require("brains/quagmirechickenbrain"))
	
	inst:ListenForNextEvent("ms_portalactivate", function()
		inst:DoTaskInTime(3 + math.random() * 5, function(inst)
			if inst.sg:HasStateTag("sleeping") then
				inst.sg:GoToState("sleeping_pst")
			end
		end)
	end, TheWorld)
	
	return inst
end

return Prefab("quagmire_chicken", fn, assets)