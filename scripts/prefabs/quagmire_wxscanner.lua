
local assets =
{
    Asset("ANIM", "anim/wx_scanner.zip"),
}

local function CreateRingFX()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:Hide("inner")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)

    local scale = TUNING.WX78_SCANNER_PLAYER_PROX/8.5
    inst.Transform:SetScale(scale,scale,scale)

    inst:AddComponent("fader")

    return inst
end

local function RemoveHudIndicator(inst)  -- client code
	if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
		ThePlayer.HUD:RemoveTargetIndicator(inst)
	end
end

local function SetupHudIndicator(inst) -- client code
	ThePlayer.HUD:AddTargetIndicator(inst, {atlas = GetInventoryItemAtlas(inst.image..".tex", true), image = inst.image..".tex"})
	inst:DoTaskInTime(TUNING.MINIFLARE.TIME, RemoveHudIndicator)
	inst:ListenForEvent("onremove", RemoveHudIndicator)
end

local function ShowIndicator(inst)
    if ThePlayer and ThePlayer.HUD then
        SetupHudIndicator(inst)
    end
end

local function announcefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetCanSleep(false)

    inst:DoTaskInTime(0, ShowIndicator)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function NoticeScanner(inst, data)
    local dist = 10
    if not data then
        return
    end

    if inst:GetDistanceSqToInst(data.scanpref) >= dist*dist then
        return
    end

    local result = "error"
    local image = "skull_wilson"
    local colour = SCANNER_ANNOUNCE_COLOURS.ERROR

    if data.scanpref:HasTag("campfire") or data.scanpref:HasTag("quagmire_stewer") then
        if data.scanpref:HasTag("failedcooked") then
            result = "overcooked"
            image = data.scanpref:HasTag("campfire") and data.scanpref.prefaboverride:value().prefab.."_item" or data.scanpref.prefab.."_overcooked"
            colour = SCANNER_ANNOUNCE_COLOURS.OVERCOOKED
        else
            result = "cooked"
            image = data.scanpref:HasTag("campfire") and data.scanpref.prefaboverride:value().prefab.."_item" or data.scanpref.prefab
            colour = SCANNER_ANNOUNCE_COLOURS.COOKED
        end
    elseif data.scanpref:HasTag("sugarwoodtree") then
        if data.scanpref:HasTag("withered") then
            result = "sap_rot"
            image = "quagmire_sap_spoiled"
            colour = SCANNER_ANNOUNCE_COLOURS.SAP_ROT
        else
            result = "sap"
            image = "quagmire_sap"
            colour = SCANNER_ANNOUNCE_COLOURS.SAP
        end
    elseif data.scanpref:HasTag("crop") then
        if data.scanpref:HasTag("rotten") then
            result = "crop_rot"
            image = "potato_oversized_rot"
            colour = SCANNER_ANNOUNCE_COLOURS.CROP_ROT
        else
            result = "crop"
            image = "potato_oversized"
            colour = SCANNER_ANNOUNCE_COLOURS.CROP
        end
    elseif data.scanpref.prefab == "quagmire_salt_rack" then
        result = "salted"
        image = "quagmire_saltrock"
        colour = SCANNER_ANNOUNCE_COLOURS.SALTED
    end

    inst:Ping()

    --[[local announce = SpawnAt("quagmire_wxscanner_announce", inst)
    announce.name = STRINGS.GORGE.SCANNER[string.upper(result)]
    announce.image = image
    announce.playercolour = colour]]
    inst:DoTaskInTime(TUNING.MINIFLARE.TIME, function()
        --announce:Remove()
        inst:Ping(true)
    end)
	
	SendModRPCToClient(GetClientModRPC("ReGorge", "WxScannerInfo"), nil, result, image, colour[1], colour[2], colour[3], colour[4])

    if inst.owner then
        inst.owner:PushEvent("pingowner")
    end
end

local function Ping(inst, stop)
    local show = false
    
    if inst.pingtask then
        inst.pingtask:Cancel()
        inst.pingtask = nil
    end

    if stop then
        inst.AnimState:Hide("bottom_light")
        inst.AnimState:Hide("top_light")  
        return
    end

    inst.pingtask = inst:DoPeriodicTask(0.25, function()
        show = not show
        if show then
            inst.AnimState:Show("bottom_light")
            inst.AnimState:Show("top_light")    
            inst.SoundEmitter:PlaySound("WX_rework/scanner/ping")
        else
            inst.AnimState:Hide("bottom_light")
            inst.AnimState:Hide("top_light")    
        end
    end)
end

local function OnActivateFn(inst)
    inst.AnimState:PlayAnimation("turn_off_pre")
    inst.SoundEmitter:PlaySound("WX_rework/scanner/deactivate")
    inst:ListenForEvent("animover", function()
        SpawnAt("quagmire_wxscanner_item", inst)
        inst:Remove()   
    end)
end

local function SpawnRing(inst)
    if inst.ring == nil then
        inst.ring = CreateRingFX(inst)
    end
    inst:AddChild(inst.ring)

    inst.ring.AnimState:SetAddColour(0, 0.5, 0.2, 1)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 1, 0.5)

    -- inst.Transform:SetFourFaced() No Face for better looking

    inst.MiniMapEntity:SetIcon("wx78_scanner_item.png")

    inst.DynamicShadow:SetSize(1.2, 0.75)
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst.AnimState:SetBank("scanner")
    inst.AnimState:SetBuild("wx_scanner")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("bottom_light")
    inst.AnimState:Hide("top_light")

	inst:SetPrefabNameOverride("wx78_scanner")

    if not TheNet:IsDedicated() then
        SpawnRing(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inspectable")

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivateFn
    inst.components.activatable.quickaction = true
    inst.components.activatable.forcerightclickaction = true
    inst.components.activatable.forcenopickupaction = true

    inst.Ping = Ping 
    inst:ListenForEvent("scannernotice", function(src, data) NoticeScanner(inst, data) end, TheWorld)

    return inst
end

local function OnScannerDeployed(inst, pt, deployer)
    local scanner = SpawnPrefab("quagmire_wxscanner")
    if scanner ~= nil then
        scanner.Physics:SetCollides(false)
        scanner.Physics:Teleport(pt.x, 0, pt.z)
        scanner.Physics:SetCollides(true)

        scanner.AnimState:PlayAnimation("turn_on", false)
        scanner.AnimState:PushAnimation("idle", true)
        scanner.AnimState:Hide("bottom_light")
        scanner.AnimState:Hide("top_light")
        scanner.SoundEmitter:PlaySound("WX_rework/scanner/movement_lp", "movement_lp")
        scanner.SoundEmitter:PlaySound("WX_rework/scanner/locked_on")
        scanner.owner = deployer
        
        inst:Remove()
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("wx78_scanner_item.png")

    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst.AnimState:SetBank("scanner")
    inst.AnimState:SetBuild("wx_scanner")
    inst.AnimState:PlayAnimation("turn_off_idle")
    inst.AnimState:Hide("bottom_light")
    inst.AnimState:Hide("top_light")

    inst:AddTag("usedeploystring")

	inst:SetPrefabNameOverride("wx78_scanner_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wx78_scanner_item"

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM) -- use inst._custom_candeploy_fn
    inst.components.deployable.ondeploy = OnScannerDeployed
    inst.components.deployable.restrictedtag = "upgrademoduleowner"

    return inst
end

return Prefab("quagmire_wxscanner", fn, assets),
        Prefab("quagmire_wxscanner_item", itemfn, assets),
        MakePlacer("quagmire_wxscanner_item_placer", "scanner", "wx_scanner", "turn_off_idle"),
        Prefab("quagmire_wxscanner_announce", announcefn)
