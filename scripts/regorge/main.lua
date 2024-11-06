local menv = env
GLOBAL.setfenv(1, GLOBAL)

rawset(_G, "CHEATS_ENABLED", (menv.MODROOT:find("regorgeitaled") and #menv.MODROOT == 22) and true or false)

if CHEATS_ENABLED then
	menv.modimport("scripts/regorge/debug.lua")
end

--===INITIALISATION===--

local UpvalueHacker = require "tools/upvaluehacker"

require("regorge/util")
require("regorge/standardcomponents")
require("regorge/sync_recipebook")
require("actions")

-- Dirty disable skilltree
local skilltreedefs = require "prefabs/skilltree_defs"
for characterprefab, skills in pairs(skilltreedefs.SKILLTREE_DEFS) do
    skilltreedefs.SKILLTREE_DEFS[characterprefab] = nil
end

menv.AddComponentPostInit("skilltreeupdater", function(self)
    local original_AddSkillXP = self.AddSkillXP
    self.AddSkillXP = function(amount, prefab, fromrpc)
        TheSkillTree.ignorexp = true -- disable notifications
        original_AddSkillXP(self, amount, prefab, fromrpc)
    end
end)

-- Fixing all Mod characters and not supported ones
local NO_PATCH_CHARACTERS = {
	"wilson",
	"willow",
	"wolfgang",
	"wendy",
	"wickerbottom",
	"wx78",
	"woodie",
	"waxwell",
	"webber",
	"wathgrithr",
	-- "winona",
}

-- Wrong ingredients for quagmire world
local LOCKED_INGREDIENTS = {
	"carrot",
	"carrot_cooked",
	"potato",
	"potato_cooked",
	"onion",
	"onion_cooked",
	"garlic",
	"garlic_cooked",
	"tomato",
	"tomato_cooked",
}

menv.modimport("scripts/regorge/lobby_commands.lua")
menv.modimport("scripts/regorge/ui.lua")

--===PREFABS===--

-- Spawn wrong ingredients must be remove
for _, ingname in pairs(LOCKED_INGREDIENTS) do
	menv.AddPrefabPostInit(ingname, function(inst)
		inst:DoTaskInTime(0, inst.Remove)
	end)
end

local function CanBeRevivedBy(inst, reviver)
	return reviver:HasTag("admin")
end

menv.AddPlayerPostInit(function(inst)
	inst._isvoted = net_bool(inst.GUID, "quagmire_vote._isvoted")
	inst._isskippedvote = net_bool(inst.GUID, "quagmire_vote._isskippedvote")
	inst._votecount = net_byte(inst.GUID, "quagmire_vote._votecount")
	inst._votecount:set(0)

	if TheNet:GetPVPEnabled() and not GetGorgeGameModeProperty("murder_mystery") then
		inst:AddTag("canbeslaughtered")
	end

	if GetGorgeGameModeProperty("murder_mystery") then
		inst:AddTag("noplayerindicator")
	end

	if not inst.not_shopper and not inst:HasTag("quagmire_shopper") and not inst:HasTag("quagmire_cheapskate") then -- Fox: we should let moders remove this tag
		inst:AddTag("quagmire_shopper")
	end

	inst:DoTaskInTime(0.1, function()
		if GetGorgeGameModeProperty("murder_mystery") then
			local manager = TheWorld.net.components.quagmire_murdermysterymanager
			if manager and manager:GetMurder() and manager:GetMurder().userid == inst.userid then
				if not inst.components.quagmire_cd then
					inst:AddComponent("quagmire_cd")
					inst.components.quagmire_cd:StartCD(TUNING.GORGE.MURDERER_CD)
				end
			else
				if not inst.components.quagmire_innocent then
					inst:AddComponent("quagmire_innocent")
				end
			end
		end
	end)

	if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
		if inst.components.frostybreather then
			inst.components.frostybreather:SetOffsetFn(function() return Vector3(.3, 1.15, 0) end)
			inst.components.frostybreather:Enable()
			inst.components.frostybreather:StartBreath()
		end
	end

	if not TheNet:GetIsServer() then
		return
	end

	if GetGorgeGameModeProperty("moon_curse") then
		if inst.components.sanity then
			inst.components.sanity.IsEnlightened = function() return true end
			inst.components.sanity.IsLunacyMode = function() return true end
		end
	end

	if not inst.components.eater then
		inst:AddComponent("eater")
	end

	if GetGorgeGameModeProperty("murder_mystery") then
		if inst.components.revivablecorpse then
			inst.components.revivablecorpse:SetCanBeRevivedByFn(CanBeRevivedBy)
		end
	end
	-- Patching official characters
	if not table.contains(NO_PATCH_CHARACTERS, inst.prefab) and HasEventData(inst.prefab) then
		event_server_data("quagmire", "prefabs/" .. inst.prefab).master_postinit(inst)
	end

	if not inst.quagmired then
		local post_init = require("gorge_data/prefabs/player_common")
		post_init.master_postinit(inst)
	end
end)

menv.AddPrefabPostInit("wortox", function(inst)
	inst:ListenForEvent("setowner", function(inst)
		if inst.components.playeractionpicker ~= nil then
			inst.components.playeractionpicker.pointspecialactionsfn = nil
		end
	end)
end)

menv.AddPrefabPostInit("quagmire_goatmum", function(inst)
	inst:AddTag("giftmachine")
	inst:AddTag("moddedgiftmachine") --[API] Modded Skins compatibility
end)

menv.AddPrefabPostInitAny(function(inst)
	if GetGorgeGameModeProperty("confusion_enabled") then
		local names = {}
		for i, name in ipairs(PREFABFILES) do
			if (type(STRINGS.NAMES[string.upper(name)]) == "string" and STRINGS.NAMES[string.upper(name)] ~= nil and GetInventoryItemAtlas(name .. ".tex", true) ~= nil) then
				table.insert(names, name)
			end
		end
		local name = GetRandomItem(names)
		if inst.components.inventoryitem then
			inst.components.inventoryitem:ChangeImageName(name)
			inst.components.inventoryitem.atlasname = GetInventoryItemAtlas(name .. ".tex", true)
		end
		inst:SetPrefabNameOverride(name)
	end

	if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
		if inst.AnimState then
			inst.AnimState:Show("snow")
		end
	end
end)

local function SetGroundOverlay()
	TheWorld.Map:SetOverlayTexture("levels/textures/snow.tex")
	TheWorld.Map:SetOverlayColor0(1, 1, 1, 1)
	TheWorld.Map:SetOverlayColor1(1, 1, 1, 1)
	TheWorld.Map:SetOverlayColor2(1, 1, 1, 1)
	TheWorld.Map:SetOverlayLerp(0.5)
	TheWorld.state.snowlevel = 0.16
end

local function OnPlayerActivated(inst, player)
	if inst._snowfx then
		inst._snowfx.entity:SetParent(player.entity)
		inst._snowfx.particles_per_tick = 20
		inst._snowfx:PostInit()
	end
end

local function OnPlayerDeactivated(inst, player)
	if inst._snowfx then
		inst._snowfx.entity:SetParent(nil)
	end
end

local _Recipe = Recipe._ctor
Recipe._ctor = function(self, ...)
	_Recipe(self, ...)

	if self and self.tab then
		self.sg_state = self.tab.shop and "give" or nil
	end
end

menv.AddPrefabPostInit("quagmire", function(inst)
	local TILLSOILBLOCKED_MUST_TAGS = { "plantedsoil" }
	function Map:CanTillSoilAtPoint(x, y, z)
		local pt
		if y == nil and z == nil then --Geometric placement compat...
			pt = x
		else
			pt = Vector3(x, y, z)
		end
		return TheWorld.Map:IsFarmableSoilAtPoint(pt:Get())
			and #TheSim:FindEntities(pt.x, 0, pt.z, 1, TILLSOILBLOCKED_MUST_TAGS) <= 0
	end

	-- Fox: Add our custom recipes
	-- ToDo: maybe we can use just Recipe?

	for name, data in pairs(GorgeRecipes) do
		menv.AddRecipe(name, data.ingredients, data.tab, TECH.LOST, nil, nil, true, data.count, data.tag or "quagmire_shopper", data.atlas, data.image, nil, data.product).gamemode_specific =
			data.gamemode
		if not data.fixed_price and not data.tag then
			local _ingredients = deepcopy(data.ingredients)
			for i, ing in ipairs(_ingredients) do
				for i = 1, 2 do
					if ing.type:find("quagmire_coin" .. i) then
						ing.amount = math.max(ing.amount - 1, 1)
					end
				end
			end
			menv.AddRecipe(name .. "_cs", _ingredients, data.tab, TECH.LOST, nil, nil, true, data.count, "quagmire_cheapskate", data.atlas or "images/inventoryimages.xml", data.image or (data.product or name) .. ".tex", nil, data.product or name).gamemode_specific =
				data.gamemode
		end
	end

	inst.Map:SetUndergroundFadeHeight(0)

	if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
		SetGroundOverlay()
		inst._snowfx = SpawnPrefab("quagmire_snow")
		inst._snowfx.particles_per_tick = 0
	end

	local function UpdateGameMode(inst)
		if GetGorgeGameModeProperty("darkness") then
			inst:PushEvent("overrideambientlighting", Point(0, 0, 0))
		end
		--[[
		for name, rec in pairs(AllRecipes) do
			if rec.gamemode_specific and rec.gamemode_specific ~= GetGorgeGameMode() then
				rec.tab = nil
			end
		end]]
	end

	if not TheNet:IsDedicated() then
		inst:ListenForEvent("ms_client_gamemode_synced", UpdateGameMode)
		inst:ListenForEvent("playeractivated", OnPlayerActivated, inst)
		inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, inst)
	end

	inst:DoTaskInTime(0.1, function(inst) -- 0.1 after SyncGameMode in "quagmire_network"
		if GetGorgeGameModeProperty("moon_curse") then
			inst:PushEvent("overridecolourcube", "images/colour_cubes/lunacy_regular_cc.tex")
		end
	end)
end)

local _GetValidRecipe = GetValidRecipe
function GetValidRecipe(name, ...)
	local rec = _GetValidRecipe(name, ...)
	if rec and rec.gamemode_specific and rec.gamemode_specific ~= GetGorgeGameMode() then
		return nil
	end
	return rec
end

menv.AddPrefabPostInit("quagmire_network", function(inst)
	inst.localhost_level = net_ushortint(inst.GUID, "quagmire_network.inst.localhost_level")
	inst._soul_active = net_bool(inst.GUID, "quagmire_network._soul_active", "soul_active_dirty")
	inst._gamemode = net_string(inst.GUID, "quagmire_network._gamemode")
	inst._gamemode:set(1)

	inst._perks = net_string(inst.GUID, "quagmire_network._perks", "perks_dirty")

	inst._murder = net_entity(inst.GUID, "quagmire_network._murder")
	inst._mmvotetime = net_byte(inst.GUID, "quagmire_network._mmvotetime")
	inst._skippedvotes = net_byte(inst.GUID, "quagmire_network._skippedvotes")
	inst._skippedvotes:set(0)

	function inst:GetHostLevel()
		return inst.localhost_level:value()
	end

	if TheNet:GetIsServer() then
		if not inst.components.gorge_voter then
			inst:AddComponent("gorge_voter")
		end

		if TheNet:GetServerIsClientHosted() then
			wxputils.GetEventStatus("quagmire", 1, function(success)
				if success then
					local host_level = TheInventory:GetWXPLevel("quagmire")
					inst.localhost_level:set(host_level)
				end
			end)
		end

		inst._gamemode:set(Settings.gorge_game_mode or "default")
	else
		wxputils.GetEventStatus("quagmire", 1, function()
		end)
	end

	inst:DoTaskInTime(0.1, function()
		if GetGorgeGameModeProperty("murder_mystery") then
			inst:AddComponent("quagmire_murdermysterymanager")
		end
	end)

	if not TheNet:IsDedicated() then
		inst.perks = {}

		local function SyncGameMode()
			TheWorld:PushEvent("ms_client_gamemode_synced", inst._gamemode:value())
		end

		inst:ListenForEvent("gamemode_dirty", SyncGameMode)
		inst:DoTaskInTime(0, SyncGameMode)

		inst:ListenForEvent("soul_active_dirty", function()
			TheWorld:PushEvent("wortox_hangriness_pause", { active = inst._soul_active:value() })
		end)

		if GORGE_SETTINGS.PERKS_ENABLED then
			local function SyncPerks()
				inst.perks = loadstring(inst._perks:value())()
				TheWorld:PushEvent("perks_updated", inst.perks)
			end

			inst:ListenForEvent("perks_dirty", SyncPerks)
			inst:DoTaskInTime(0, SyncPerks)
		end
	end

	function inst:SyncPerks(perks)
		local data = DataDumper(perks)
		inst._perks:set(data)
	end

	function inst:GetPerks(userid)
		if userid then
			return inst.perks and inst.perks[userid] or 1
		else
			return inst.perks or {}
		end
	end
end)

menv.AddPrefabPostInit("quagmire_swampig_house", function(inst)
	inst.AnimState:SetBank("quagmire_houses")
	inst.AnimState:SetBuild("quagmire_houses")
	inst.AnimState:PlayAnimation("idle")
end)

menv.AddPrefabPostInit("quagmire_swampig_house_rubble", function(inst)
	inst.AnimState:SetBank("quagmire_houses")
	inst.AnimState:SetBuild("quagmire_houses")
	inst.AnimState:PlayAnimation("rubble")
end)

local function EnableVoteButton(inst)
	if not inst._parent or not inst._parent.HUD or not inst._parent.HUD.controls.votebutton then
		return
	end

	if inst._votebutton:value() then
		inst._parent.HUD.controls.votebutton:Show()
	else
		inst._parent.HUD.controls.votebutton:Hide()
		if TheFrontEnd:GetActiveScreen().name == "VotePanel" then
			TheFrontEnd:PopScreen()
		end
	end
end

menv.AddPrefabPostInit("player_classified", function(inst)
	--[[
	inst.mermification_sounds = net_smallbyte(inst.GUID, "regorge.mermification", "mermificationdirty")
	
	if not TheNet:IsDedicated() then
		local function onmermificationdirty(inst)
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/quagmire/transform/music/"..inst.mermification_sounds:value())
		end
	
		inst:ListenForEvent("mermificationdirty", onmermificationdirty)
	end
	]]
	inst._votebutton = net_bool(inst.GUID, "quagmire_vote._votebutton", "_votebutton_dirty")

	if not TheNet:IsDedicated() then
		inst:ListenForEvent("_votebutton_dirty", EnableVoteButton)
	end
	if TheNet:GetIsServer() then
		inst:DoTaskInTime(0, function(inst)
			if inst.MapExplorer then
				inst.MapExplorer:EnableUpdate(false)
			end
		end)
	end
end)

--===COMPONENTS===--

-- Fox: ACCEL_THRESHOLDS should be synced with clients
-- ToDo: Maybe sync it through netvar?
menv.AddComponentPostInit("quagmire_hangriness", function(self)
	local function SetAccel(mult)
		print(string.format("[Gorge Debug] Setting Acceleration with multiplier: %0.2f", mult))

		local ACCEL_THRESHOLDS = {}
		for i = 1, 15 do
			table.insert(ACCEL_THRESHOLDS, { threshold = 6000 - 25 * i, accel = (.018 + .002 * i) * mult })
		end
		table.insert(ACCEL_THRESHOLDS, { threshold = 0, accel = .05 * mult })
		UpvalueHacker.SetUpvalue(self.GetTimeRemaining, ACCEL_THRESHOLDS, "ACCEL_THRESHOLDS")
	end

	local function RecalculateAcceleration()
		if GetGorgeGameModeProperty("dynamic_hungriness") then
			if self.dynamic then
				return
			end

			self.dynamic = true

			local function Recalc()
				if self.inst.components.worldcharacterselectlobby:GetSpawnDelay() > -1 then
					SetAccel(#GetPlayerClientTable() / 3)
				end
			end

			self.inst:ListenForEvent("player_ready_to_start_dirty", Recalc)
		else
			local multiplier = GetGorgeGameModeProperty("hungriness_speedmult")

			if multiplier then
				SetAccel(multiplier)
			end
		end
	end

	if TheNet:GetIsServer() then
		self.inst:DoTaskInTime(0, RecalculateAcceleration)
	else
		self.inst:ListenForEvent("ms_client_gamemode_synced", RecalculateAcceleration, TheWorld)
	end
end)

menv.AddComponentPostInit("playeractionpicker", function(self)
	local _OldSortActionList = self.SortActionList
	function self:SortActionList(actions, target, useitem)
		if #actions == 0 then
			return actions
		end

		for i, action in ipairs(actions) do
			if action == ACTIONS.EAT or action == ACTIONS.FEEDPLAYER or (GetGorgeGameModeProperty("murder_mystery") and action == ACTIONS.REVIVE_CORPSE) then
				table.remove(actions, i) --Hornet: Bad! no eating! :0 --Asura: and not reviving! for new gamemode
			end
		end

		return _OldSortActionList(self, actions, target, useitem)
	end
end)

--===OTHER===--

-- Fox: We don't have seasons for the Gorge...
local _GetActiveFestivalEventServerName = GetActiveFestivalEventServerName
function GetActiveFestivalEventServerName(...)
	return "Quagmire"
end

-- Force loading our world
local _GetGenOptions = ShardIndex.GetGenOptions
ShardIndex.GetGenOptions = function(self, ...)
	local Levels = require("map/levels")
	return Levels.GetDataForLevelID("QUAGMIRE") or _GetGenOptions(self, ...)
end

-- Klei forgot to add string.upper
TUNING.GAMEMODE_STARTING_ITEMS.quagmire = TUNING.GAMEMODE_STARTING_ITEMS.QUAGMIRE


local containers = require("containers")
local params = {}

local _widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
	local t = data or params[prefab or container.inst.prefab]
	if t then
		for k, v in pairs(t) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos and #container.widget.slotpos or 0)
	else
		_widgetsetup(container, prefab, data, ...)
	end
end

--------------------------------------------------------------------------
local function quagmire_wobysmall()
	local quagmire_wobysmall =
	{
		widget =
		{
			slotpos =
			{
				Vector3(-(64 + 12), 0, 0),
				Vector3(0, 0, 0),
				Vector3(64 + 12, 0, 0),
			},
			animbank = "ui_chest_3x1",
			animbuild = "quagmire_woby_3x1",
			pos = Vector3(-50, -150, 0),
			side_align_tip = 100,
		},
		type = "backpack",
	}

	return quagmire_wobysmall
end

--------------------------------------------------------------------------
--[[ quagmire_wobysmall ]]
--------------------------------------------------------------------------
params.quagmire_wobysmall = quagmire_wobysmall()

params.slingshot =
{
	widget =
	{
		slotpos =
		{
			Vector3(0, 92 + 4, 0),
		},
		slotbg =
		{
			{ image = "slingshot_ammo_slot.tex" },
		},
		animbank = "quagmire_ui_pot_1x4",
		animbuild = "quagmire_ui_pot_1x4",
		pos = Vector3(0, 15, 0),
	},
	usespecificslotsforitems = true,
	type = "hand_inv",
}

function params.slingshot.itemtestfn(container, item, slot)
	return item:HasTag("slingshotammo")
end

local REGORGEMURDER = menv.AddAction("REGORGEMURDER", STRINGS.GORGE.MMACTIONS.REGORGEMURDER, function(act)
	if act.target.components.quagmire_innocent ~= nil and act.target.components.quagmire_innocent:CanDie(act.doer) then
		local success = act.target.components.quagmire_innocent:Kill(act.doer)
		return success ~= false
	end
end)

REGORGEMURDER.priority = 1
REGORGEMURDER.distance = 1.1
REGORGEMURDER.stroverridefn = function(act)
	local t = GetTime()
	if act.target ~= act.doer._lasttarget or act.doer._lastactionstr == nil or act.doer._actionresettime < t then
		act.doer._lastactionstr = GetRandomItem(STRINGS.ACTIONS.SLAUGHTER)
		act.doer._lasttarget = act.target
	end
	act.doer._actionresettime = t + .1
	return act.doer._lastactionstr .. " " .. act.target:GetDisplayName() or "Kill"
end

menv.AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REGORGEMURDER, "doshortaction"))
menv.AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REGORGEMURDER, "doshortaction"))

local REGORGEREPORT = menv.AddAction("REGORGEREPORT", STRINGS.GORGE.MMACTIONS.REGORGEREPORT, function(act)
	if act.target.components.quagmire_innocent ~= nil and act.target.components.quagmire_innocent:CanReport(act.doer) then
		local success = act.target.components.quagmire_innocent:Report(act.doer)
		return success ~= false
	end
end)

REGORGEREPORT.priority = 1
REGORGEREPORT.distance = 1.1

menv.AddComponentAction("SCENE", "quagmire_innocent", function(inst, doer, actions, right)
	if doer ~= inst and inst:HasTag("reportable") then
		table.insert(actions, ACTIONS.REGORGEREPORT)
	elseif doer ~= inst and inst:HasTag("killable") and doer.components.quagmire_cd and doer.components.quagmire_cd:GetCD() == 0 then
		table.insert(actions, ACTIONS.REGORGEMURDER)
	end
end)

menv.AddComponentAction("SCENE", "quagmire_altar", function(inst, doer, actions, right)
	if doer ~= inst and inst:HasTag("reportable") then
		table.insert(actions, ACTIONS.REGORGEREPORT)
	end
end)

menv.AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REGORGEREPORT, "domediumaction"))
menv.AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REGORGEREPORT, "domediumaction"))

do
	require("entityscript")

	local COMPONENT_ACTIONS = UpvalueHacker.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
	COMPONENT_ACTIONS.SCENE.prototyper = function(inst, doer, actions, right)
		--DO NOTHING! It's for Shop Tabs
	end
end

function MakeDeployableFertilizerPristine(inst)
end

function MakeDeployableFertilizer(inst)
end

--RPC's
menv.AddClientModRPCHandler("ReGorge", "WxScannerInfo", function(result, image, r, g, b, a)
	if ThePlayer == nil then return end

	local inst = CreateEntity() --poopy hack!
	inst.entity:AddTransform()
	inst.playercolour = { r, g, b, a }
	inst.name = STRINGS.GORGE.SCANNER[string.upper(result)]

	ThePlayer.HUD:AddTargetIndicator(inst, {
		atlas = GetInventoryItemAtlas(image .. ".tex", true),
		image = image ..
			".tex"
	})

	inst:DoTaskInTime(TUNING.MINIFLARE.TIME, function()
		if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
			ThePlayer.HUD:RemoveTargetIndicator(inst)
		end
		inst:Remove()
	end)
end)

if not TheNet:GetIsServer() then
	return
end

--===PREFABS===--

local world_objects_patch = require "world_objects_patch"
menv.AddPrefabPostInit("spawnpoint_master", function(inst)
	inst:DoTaskInTime(0, function(inst)
		local pos = inst:GetPosition()
		world_objects_patch.Execute(pos.x, pos.z)
	end)
end)

menv.AddPrefabPostInit("trap", function(inst)
	inst.components.trap.targettag = "rabbit"
end)

menv.AddPrefabPostInit("quagmire_merm_cart1", function(inst)
	inst:AddTag("sammy_point")
end)

menv.AddPrefabPostInit("quagmire_pigeon", function(inst)
	inst:AddComponent("combat")
end)

menv.AddPrefabPostInit("slingshot", function(inst)
	inst.components.weapon:SetRange(TUNING.GORGE.SLINGSHOT_DISTANCE, TUNING.GORGE.SLINGSHOT_DISTANCE_MAX)
end)

-- Fox: fix for Maxwell's shadow crash...
menv.AddPrefabPostInit("quagmire_shadowwaxwell", function(inst)
	inst:SetPhysicsRadiusOverride(.5)
end)

--===COMPONENTS===--

menv.AddComponentPostInit("inspectable", function(self)
	if not GetGorgeGameModeProperty("confusion_enabled") then
		return
	end

	function self:GetDescription(viewer)
		return GetString(viewer, "DESCRIBE_CONFUSION")
	end
end)

local _GetDescription = GetDescription
function GetDescription(inst, ...)
	if not GetGorgeGameModeProperty("confusion_enabled") then
		return _GetDescription(inst, ...)
	end
	if type(inst) == "table" then
		return GetString(DESCRIBE_CONFUSION)
	end
end

menv.AddComponentPostInit("lootdropper", function(self)
	function self:GetRecipeLoot(...)
		return {}
	end
end)

menv.AddComponentPostInit("prototyper", function(self)
	if not self.inst.nomumsy then
		self.inst:RemoveTag("prototyper")

		local isgoat = self.inst.components.goatmum ~= nil
		self.inst:ListenForEvent(isgoat and "shop_changed" or "updateshops", function(_, val)
			if val then
				self.inst:AddTag("prototyper")
			else
				self.inst:RemoveTag("prototyper")
			end
		end, not isgoat and TheWorld)
	end
end)

-- Fox: Since we're using really tricky way of prototyping it doesn't trigger prototypers' activation
menv.AddComponentPostInit("builder", function(self)
	local _MakeRecipe = self.MakeRecipe
	self.MakeRecipe = function(self, recipe, pt, rot, skin, onsuccess)
		local function _onsuccess(...)
			local proto = self.current_prototyper or TheSim:FindFirstEntityWithTag("prototyper")
			if proto then
				proto.components.prototyper:Activate(self.inst, recipe)
			end

			if TUNING.GORGE.SHOPKEEPERS_TABS[recipe.tab] then
				UpdateStat(self.inst.userid, "buys", 1)
			end
			UpdateAchievement("gather_spice", self.inst.userid, { recipe = recipe })
			if onsuccess then
				return onsuccess(...)
			end
		end
		return _MakeRecipe(self, recipe, pt, rot, skin, _onsuccess)
	end

	local _DoBuild = self.DoBuild
	function self:DoBuild(recname, pt, rotation, skin)
		local recipe = GetValidRecipe(recname)
		return _DoBuild(self, recname, pt, rotation, skin or (recipe and TUNING.GORGE.ITEM_SKINS[recipe.product]))
	end
end)

menv.AddComponentPostInit("perishable", function(self)
	local _SetPerishTime = self.SetPerishTime
	function self:SetPerishTime(time, ...)
		return _SetPerishTime(self, time * (GetGorgeGameModeProperty("perish_mult") or 1))
	end
end)

menv.AddComponentPostInit("fishingrod", function(self)
	local _Collect = self.Collect

	function self:Collect(...)
		if self.fisherman and self.fisherman:HasTag("merm")
			and self.caughtfish and self.caughtfish.components.stackable then
			self.caughtfish.components.stackable:SetStackSize(math.random() <= 0.5 and 2 or 1)
		end
		return _Collect(self, ...)
	end
end)

menv.AddComponentPostInit("inventoryitem", function(self)
	local function Check(self)
		return GetGorgeGameModeProperty("thieves_enabled") and
			self.inst.components.perishable and
			not self.inst:HasTag("smallcreature")
	end

	local function ClearTasks(self)
		if self.clr_task then
			self.clr_task:Cancel()
			self.clr_task = nil
		end

		if self.thief_task then
			self.thief_task:Cancel()
			self.thief_task = nil
		end
	end

	local function Steal(inst)
		if self.owner then
			return
		end

		ClearTasks(self)

		if not inst.components.colourtweener then
			inst:AddComponent("colourtweener")
		end

		inst.components.colourtweener:StartTween({ 0, 0, 0, 0.65 }, 25 * FRAMES, function()
			self.clr_task = inst:DoTaskInTime(32 * FRAMES, function()
				inst.components.colourtweener:StartTween({ 0, 0, 0, 0 }, 20 * FRAMES)
			end)
		end)

		local pos = inst:GetPosition()
		SpawnAt("quagmire_shadow_thief_fx", Vector3(pos.x, 0, pos.z))

		self.saved_colour = { inst.AnimState:GetMultColour() }

		self.thief_task = inst:DoTaskInTime(57 * FRAMES, function()
			self.canbepickedup = false

			self.thief_task = inst:DoTaskInTime(20 * FRAMES, function()
				inst:Remove()
			end)
		end)

		inst:RemoveEventCallback("on_landed", Steal)
	end

	self.inst:ListenForEvent("onpickup", function(inst)
		if not Check(self) then
			return
		end

		ClearTasks(self)

		if inst.components.colourtweener then
			inst.components.colourtweener:EndTween()
		end

		local clr = self.saved_colour or { 1, 1, 1, 1 }
		inst.AnimState:SetMultColour(clr[1], clr[2], clr[3], clr[4])
		self.saved_colour = nil

		inst:RemoveEventCallback("on_landed", Steal)
	end)

	self.inst:ListenForEvent("ondropped", function(inst)
		if not Check(self) then
			return
		end

		inst:ListenForEvent("on_landed", Steal)
	end)
end)

menv.AddComponentPostInit("playerspawner", function(self)
	self.spawn_pos = {}

	local function GetPlayerIndex(inst)
		for i, player in ipairs(GetPlayerClientTable()) do
			if player.userid == inst.userid then
				return i
			end
		end
		return 0
	end

	local _SpawnAtLocation = self.SpawnAtLocation
	function self:SpawnAtLocation(inst, player, x, y, z, ...)
		if not next(self.spawn_pos) then
			self:GenerateSpawnPositions()
			TheWorld.spawnportal:DoTaskInTime(1.5, TheWorld.spawnportal.Activate)
		end

		local index = GetPlayerIndex(player)
		local pos = self.spawn_pos[index]

		if player.sg then
			player.sg:GoToState("quagmire_hide")
		end
		player:DoTaskInTime(3 + index / 10, player.DoSpawn)

		if GORGE_EVENT == SPECIAL_EVENTS.WINTERS_FEAST then
			if player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == nil then
				local hat = math.random() > 0.5 and SpawnPrefab("winterhat") or SpawnPrefab("earmuffshat")
				hat:RemoveComponent("fueled")
				if player ~= nil and player.components.inventory ~= nil then
					player.components.inventory:Equip(hat)
				end
			elseif player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) == nil then
				local trunkvest = math.random() > 0.5 and SpawnPrefab("trunkvest_summer") or
					SpawnPrefab("trunkvest_winter")
				trunkvest:RemoveComponent("fueled")
				if player ~= nil and player.components.inventory ~= nil then
					player.components.inventory:Equip(trunkvest)
				end
			end
		end
		return _SpawnAtLocation(self, inst, player, pos.x, 0, pos.z, ...)
	end

	function self:GenerateSpawnPositions()
		local count = #GetPlayerClientTable()
		local pos = TheWorld.spawnportal:GetPosition()
		local range = 1.75
		local lantern_range = 3.5

		for i = 1, count do
			local angle = 2 * math.pi * i / count
			self.spawn_pos[i] = Vector3(pos.x + math.cos(angle) * range, 0, pos.z + math.sin(angle) * range)
			if GetGorgeGameModeProperty("darkness") and not GetGorgeGameModeProperty("murder_mystery") then
				local lantern = SpawnAt("quagmire_lantern",
					Vector3(pos.x + math.cos(angle) * lantern_range, 0, pos.z + math.sin(angle) * lantern_range))
				lantern.components.machine:TurnOn()
			end
		end
	end
end)

--===OTHER===--

-- Fox: we don't need to render MiniMap
local _EnableUpdate = MapExplorer.EnableUpdate
MapExplorer.EnableUpdate = function(self, val, ...)
	return _EnableUpdate(self, false, ...)
end

-- Fox: We don't need to save anything
function SaveGame(isshutdown, cb, ...)
	if cb ~= nil then
		return cb(true)
	end
	return true
end

menv.AddSimPostInit(function()
	if GORGE_SETTINGS.FIXED_GAME_MODE then
		Settings.gorge_game_mode = GORGE_SETTINGS.FIXED_GAME_MODE
	end

	local bans = TheNet:GetBlacklist()
	for i, data in pairs(bans) do
		if data.userid and REGORGE_DEVELOPERS[data.userid] then
			table.remove(bans, i)
		end
	end
	TheNet:SetBlacklist(bans)
end)

local _OnSimPaused = OnSimPaused
function OnSimPaused(...)
	GorgeError(1)
	return _OnSimPaused(...)
end

-- Fox: We need to add eater component before master_postinit
do
	local MakePlayerCharacter = require("prefabs/player_common")
	package.loaded["prefabs/player_common"] = function(prefab, deps, assets, common, master, ...)
		if prefab == "walter" then
			local _master = master
			master = function(inst, ...)
				if not inst.components.eater then
					inst:AddComponent("eater")
				end
				return _master(inst, ...)
			end
		end
		return MakePlayerCharacter(prefab, deps, assets, common, master, ...)
	end
end

TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS = 25

menv.AddClassPostConstruct("components/combat_replica", function(self)
	local _CanBeAttacked = self.CanBeAttacked
	self.CanBeAttacked = function(self, attacker)
		local equipped_hand = attacker and attacker.components.inventory and
			attacker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
		if equipped_hand and equipped_hand:HasTag("slingshot") then
			return true
		else
			return false
		end
	end
end)

local function GetGameMode(game_mode)
	return GAME_MODES[game_mode] or GAME_MODE_ERROR
end
function GetGameModeProperty(property)
	if GetGorgeGameModeProperty("moon_curse") then
		if property == "icons_use_cc" then
			return false
		end
	end
	return GetGameMode(TheNet:GetServerGameMode())[property]
end
