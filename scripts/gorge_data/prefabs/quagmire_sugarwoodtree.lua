local TREE_DEFS = {
	{
		prefab_name = "quagmire_sugarwoodtree_small",
		anim_file = "quagmire_tree_cotton_short",
		loot = {"log"},
		workleft = 5,
	},
	{
		prefab_name = "quagmire_sugarwoodtree_normal",
		anim_file = "quagmire_tree_cotton_normal",
		loot = {"log", "twigs"},
		workleft = 10,
	},
	{
		prefab_name = "quagmire_sugarwoodtree_tall",
		anim_file = "quagmire_tree_cotton_tall",
		loot = {"log", "log", "twigs"},
		workleft = 15,
	},
}

local function ChopDownTreeShake(inst)
	ShakeAllCameras(
		CAMERASHAKE.FULL,
		.25,
		.03,
		inst.stage > 2 and .5 or .25,
		inst, 6
	)
end

local function DigUpStump(inst)
	inst.components.lootdropper:SpawnLootPrefab("log")
	inst:Remove()
end

local function ChopDownTree(inst, chopper)
	inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

	local pt = inst:GetPosition()
	local hispos = chopper:GetPosition()
	local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
	
	if he_right then
		inst.AnimState:PlayAnimation("fallleft")
		inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
	else
		inst.AnimState:PlayAnimation("fallright")
		inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
	end

	inst.AnimState:PushAnimation("stump")

	if inst.flies then
		inst.flies:Remove()
		inst.flies = nil
	end

	inst:DoTaskInTime(.4, ChopDownTreeShake)

	inst:RemoveComponent("quagmire_tappable")
	
	inst:RemoveTag("tappable")
	inst:RemoveTag("shelter")
	inst:RemoveTag("cattoyairborne")
	
	inst:AddTag("stump")

	RemovePhysicsColliders(inst)

	inst.components.workable:SetWorkAction(ACTIONS.DIG)
	inst.components.workable:SetOnFinishCallback(DigUpStump)
	inst.components.workable:SetWorkLeft(1)
	
	local actualchopper = chopper:HasTag("shadowminion") and chopper.owner or chopper.userid
	local logs = 0
	
	for i, pref in ipairs(TREE_DEFS[inst.stage].loot) do
		local loot = SpawnPrefab((not GetGorgeGameModeProperty("log_rng") or math.random() <= 0.5) and pref or "twigs")
		inst.components.lootdropper:FlingItem(loot)
		logs = logs + 1
	end

	if actualchopper then
		UpdateStat(actualchopper, "logs", logs)
	end

	UpdateStat(nil, "logs", logs)
end

local function OnChop(inst, chopper)
	local x, y, z = inst.Transform:GetWorldPosition()

	if not inst:HasTag("stump") then
		if inst:HasTag("withered") then
			SpawnPrefab("sugarwood_leaf_withered_fx_chop").Transform:SetPosition(x, 1, z)
		elseif not inst:HasTag("dead") then
			SpawnPrefab("sugarwood_leaf_fx_chop").Transform:SetPosition(x, 1, z)
		end
	end

	if not (chopper ~= nil and chopper:HasTag("playerghost")) then
		inst.SoundEmitter:PlaySound(
			chopper ~= nil and chopper:HasTag("beaver") and
			"dontstarve/characters/woodie/beaver_chop_tree" or
			"dontstarve/wilson/use_axe_tree"
		)
	end
	
	if inst.components.quagmire_tappable ~= nil and inst.components.quagmire_tappable:IsTapped() then
		inst.components.quagmire_tappable:UninstallTap(nil)
	end

	inst.AnimState:PlayAnimation("chop")
	inst.AnimState:PushAnimation(math.random() > .5 and "sway1_loop" or "sway2_loop", true)
end

return {
	master_postinit = function(inst, tree_def, prefab_name)
		local r = math.random(1, 3)

		inst.stage = r

		inst.AnimState:SetTime(math.random() * 2)
		inst.AnimState:SetBank(TREE_DEFS[r].anim_file)

		inst:AddComponent("inspectable")
		inst:AddComponent("workable")
		inst:AddComponent("lootdropper")
		inst:AddComponent("quagmire_tappable")

		inst.components.workable:SetWorkAction(ACTIONS.CHOP)
		inst.components.workable:SetWorkLeft(TREE_DEFS[r].workleft)
		inst.components.workable:SetOnFinishCallback(ChopDownTree)
		inst.components.workable:SetOnWorkCallback(OnChop)
	end,
}
