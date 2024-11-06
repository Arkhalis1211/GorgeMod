local function GetAngleShadowMaxwell(pos, radius)
	local result = math.random(0, 360)
	local test_angles = {}
	local segments = 64

	for i = 1, segments do
		table.insert(test_angles, (2 * PI * i / segments))
	end

	local numangles = #test_angles

	while numangles > 0 do
		local index = math.random(1, numangles)
		local angle = test_angles[index]
		local x, z = math.cos(angle) * radius, math.sin(angle) * radius

		if TheWorld.Map:IsAboveGroundAtPoint(pos.x + x, 0, pos.z + z) then
			result = angle / DEGREES
			break
		end

		table.remove(test_angles, index)

		numangles = #test_angles
	end

	if result > 180 then
		result = -360 + result
	end

	return -result
end

local function OnSpawnShadow(inst)
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end

	inst.shadow = SpawnAt("quagmire_shadowwaxwell", inst)
	inst.shadow.book = inst
	inst.shadow.Transform:SetRotation(GetAngleShadowMaxwell(inst:GetPosition(), 2.5))
	inst.shadow.sg:GoToState("jumpout")

	inst.SoundEmitter:PlaySound("dontstarve/common/use_book_dark")
end

local function OnShadowKill(inst)
	if inst.AnimState:IsCurrentAnimation("proximity_loop") then
		inst.AnimState:PlayAnimation("proximity_pst")
		inst.AnimState:PushAnimation("idle")

		inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")

		inst.shadow = nil
	end
end

local function OnPickup(inst, owner)
	inst.owner = owner

	if inst.shadow ~= nil then
		inst.shadow:Kill()
		inst.shadow = nil
	end

	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end
end

local function OnDropped(inst)
	if inst.owner ~= nil and inst.owner:HasTag("shadowmagic") then
		inst.AnimState:PlayAnimation("proximity_pre")
		inst.AnimState:PushAnimation("use")
		inst.AnimState:PushAnimation("proximity_loop", true)

		inst.task = inst:DoTaskInTime(27 * FRAMES, OnSpawnShadow)
	else
		inst.AnimState:PlayAnimation("idle")
	end

	inst.owner = nil
end

return {
	master_postinit = function(inst)
		inst.owner = nil
		inst.shadow = nil
		inst.task = nil

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = "waxwelljournal"
		inst.components.inventoryitem:SetOnPickupFn(OnPickup)
		inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

		inst:ListenForEvent("shadowkill", OnShadowKill)		
	end,
}
