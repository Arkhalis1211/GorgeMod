local function OnOpen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/safe/open")
	inst.AnimState:PlayAnimation("open")
	inst.AnimState:PushAnimation("opened")
end

local function OnClose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/safe/close")
	inst.AnimState:PlayAnimation("close")
	inst.AnimState:PushAnimation("idle_unlock")
end

local function OnUnlock(inst)
	inst._isunlocked = true
	inst.components.container.canbeopened = true

	inst:RemoveEventCallback("animover", OnUnlock)

	inst.AnimState:PlayAnimation("idle_unlock")
end

local function OnUseKey(inst, key, doer)
	if not key:IsValid() or key.components.klaussackkey == nil or inst._isunlocked then
		return false, nil, false
	elseif key.components.klaussackkey.keytype ~= inst.keyid then
		return false, "QUAGMIRE_WRONGKEY", false
	end

	local items = TheWorld.components.quagmire:GetSafeLoot()
	if items ~= nil then
		for _, prefab in ipairs(items) do
			inst.components.container:GiveItem(SpawnPrefab(prefab))
		end
	end

	inst:RemoveComponent("klaussacklock")

	inst.AnimState:PlayAnimation("unlock")
	inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/safe/key")

	inst:ListenForEvent("animover", OnUnlock)

	if doer then
		UpdateAchievement("gather_safe", doer.userid, true)
	end

	return true, nil, true
end

local function OnLoad(inst, data)
	if data and data.isunlocked then
		inst._isunlocked = data.isunlocked
		inst.components.container.canbeopened = data.isunlocked
		inst.AnimState:PlayAnimation("idle_unlock")
		inst:RemoveComponent("klaussacklock")
	end
end

return {
	master_postinit = function(inst)
		inst._isunlocked = false

		inst:AddComponent("inspectable")

		inst:AddComponent("container")
		inst.components.container:WidgetSetup("quagmire_safe")
		inst.components.container.onopenfn = OnOpen
		inst.components.container.onclosefn = OnClose
		inst.components.container.canbeopened = inst._isunlocked
	
		inst:AddComponent("klaussacklock")
		inst.components.klaussacklock:SetOnUseKey(OnUseKey)
		
		inst.keyid = "safe_key"
	
		inst.OnLoad = OnLoad
	end,
}
