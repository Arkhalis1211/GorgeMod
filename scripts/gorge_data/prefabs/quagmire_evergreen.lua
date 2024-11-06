local function makeanims(stage)
    return {
        idle = "idle_"..stage,
        sway1 = "sway1_loop_"..stage,
        sway2 = "sway2_loop_"..stage,
        chop = "chop_"..stage,
        fallleft = "fallleft_"..stage,
        fallright = "fallright_"..stage,
        stump = "stump_"..stage,
        burning = "burning_loop_"..stage,
        burnt = "burnt_"..stage,
        chop_burnt = "chop_burnt_"..stage,
        idle_chop_burnt = "idle_chop_burnt_"..stage,
    }
end

local data = {
	{
		loot = {"log"},
		work = 5,
		anim = makeanims("short"),
	},
	
	{
		loot = {"log", "log"},
		work = 10,
		anim = makeanims("normal"),
	},
	
	{
		loot = {"log", "log", "log"},
		work = 15,
		anim = makeanims("tall"),
	},
}

local function ChopDownTreeShake(inst)
    ShakeAllCameras(
        CAMERASHAKE.FULL,
        .25,
        .03,
        inst.stage > 2 and .5 or .25,
        inst,
        6
    )
end

local function GetStatus(inst)
    return (inst:HasTag("stump") and "STUMP")
        or nil
end

local function DigUpStump(inst)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

local function PushSway(inst)
    inst.AnimState:PushAnimation(math.random() > .5 and inst.anims.sway1 or inst.anims.sway2, true)
end

local function ChopDownTree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
	RemovePhysicsColliders(inst)

    local pt = inst:GetPosition()
    local hispos = chopper:GetPosition()
    local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
	
    if he_right then
        inst.AnimState:PlayAnimation(inst.anims.fallleft)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation(inst.anims.fallright)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end
	
    inst:DoTaskInTime(.4, ChopDownTreeShake)
    inst:RemoveComponent("workable")
	
    inst:ListenForEvent("animover", function(inst)
		local stump = SpawnAt("quagmire_evergreen_stump", inst)
		stump.AnimState:PlayAnimation(inst.anims.stump)
		inst:Remove()
	end)
	
	local actualchopper = chopper:HasTag("shadowminion") and chopper.owner or chopper.userid

	local logs = 0
	for i, pref in ipairs(data[inst.stage].loot) do
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
	
	SpawnPrefab("pine_needles_chop").Transform:SetPosition(x, 1, z)
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
	
    inst.AnimState:PlayAnimation(inst.anims.chop)

    PushSway(inst)
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = GetStatus
		local rng = math.random(1, 3)
		
		inst.anims = data[rng].anim
		inst.AnimState:PlayAnimation(inst.anims.stump)

		inst:AddComponent("workable")
		inst:AddComponent("lootdropper")
	end,
	
	master_postinit_stump = function(inst)
		inst:AddTag("stump")
	
		RemovePhysicsColliders(inst)
		inst.components.workable:SetWorkAction(ACTIONS.DIG)
		inst.components.workable:SetOnFinishCallback(DigUpStump)
		inst.components.workable:SetWorkLeft(1)
	end,
	
	master_postinit_tree = function(inst)
		local rng = math.random(1, 3)
		
		inst.anims = data[rng].anim
		inst.stage = rng
	
		inst.AnimState:SetTime(math.random() * 2)
		
		inst.components.workable:SetWorkAction(ACTIONS.CHOP)
		inst.components.workable:SetOnFinishCallback(ChopDownTree)
		inst.components.workable:SetOnWorkCallback(OnChop)
		inst.components.workable:SetWorkLeft(data[rng].work)
		
		inst:DoTaskInTime(0, PushSway)
	end,
}
