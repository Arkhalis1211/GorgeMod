-- Those are loaded in front end (when you enable the mod)
local menv = env
GLOBAL.setfenv(1, GLOBAL)

package.loaded["tools/mod_compatibility"] = nil

require("regorge/strings")

local AssetLoader = require("tools/assetloader")
local UIAnim = require("widgets/uianim")

local FE_Assets = {
	Asset("ANIM", "anim/quagmire_hangry_status.zip"),
}

local pre_comp = {
	["workshop-727057103"] = true,
	["workshop-1637709131"] = true,
}

require("tools/mod_compatibility")(menv, "gorge_compatible", "quagmire", pre_comp)

AssetLoader.LoadAssets(menv.modname, FE_Assets)

-- Fox: Note: AddClassPostConstruct doesn't affect this screen as we already constructed it
local function AddClassAfterConstruct(path, fn)
	fn(require(path))
end

local function DoFnForCurrentScreen(fn)
	local CurrentScreen = TheFrontEnd:GetActiveScreen()
	if CurrentScreen then
		fn(CurrentScreen)
	end
end

local function AddGnaw(self, root, s)
	if self.gnaw then
		return
	end
	
	self.gnaw = self[root]:AddChild(UIAnim())
	self.gnaw:GetAnimState():SetBank("quagmire_hangry_status")
	self.gnaw:GetAnimState():SetBuild("quagmire_hangry_status")
	self.gnaw:GetAnimState():PlayAnimation("happy", false)
	self.gnaw:GetAnimState():SetTime(22 * FRAMES)
	self.gnaw:GetAnimState():PushAnimation("idle", true)
	if s then
		self.gnaw:SetScale(s)
	end
	
	self.gnaw.inst:ListenForEvent("fe_unloadmods", function()
		self.gnaw:Kill()
		self.gnaw = nil
	end, TheGlobalInstance)
end

local function PatchModDetails(self)
	if self.currentmodname == menv.modname then
		AddGnaw(self, "detailimage")
	elseif self.gnaw then
		self.gnaw:Kill()
		self.gnaw = nil
	end
end

local function PatchModIcon(widget, data)
	local opt = widget.moditem
	local mod_data = (data or widget.data)
	if mod_data and mod_data.mod and mod_data.mod.modname == menv.modname then
		-- Fox: It seems that it triggers too fast if we change world tabs
		if not data and opt.gnaw then
			opt.gnaw:Kill()
			opt.gnaw = nil
		end
		AddGnaw(opt, "image", 0.8)
	elseif opt.gnaw then
		opt.gnaw:Kill()
		opt.gnaw = nil
	end
end

DoFnForCurrentScreen(function(self)
	if self.server_settings_tab then
		self.server_settings_tab.game_mode.spinner:SetOptions(GetGameModesSpinnerData(ModManager:GetEnabledServerModNames()))
		self.server_settings_tab.game_mode.spinner:SetSelected("quagmire")
		self.server_settings_tab.game_mode.spinner:Changed()
		self.server_settings_tab.game_mode.spinner:Disable()
	end
	
	-- Fox: If we enable mod for the first time mods_tab should exist
	-- and needs to be patched
	if self.mods_tab then
		if self.mods_tab.mods_scroll_list then
			for i, widget in ipairs(self.mods_tab.mods_scroll_list:GetListWidgets()) do
				PatchModIcon(widget)
			end
		end
		PatchModDetails(self.mods_tab)
	end
end)

local _update_fn
AddClassAfterConstruct("widgets/redux/modstab", function(self)
	local _ShowModDetails = self.ShowModDetails
	self.ShowModDetails = function(self, idx, ...)
		_ShowModDetails(self, idx, ...)
		PatchModDetails(self)
	end
	
	local _UpdateForWorkshop = self.UpdateForWorkshop
	self.UpdateForWorkshop = function(self, ...)
		_UpdateForWorkshop(self, ...)
		
		if self.mods_scroll_list and not _update_fn then
			_update_fn = self.mods_scroll_list.update_fn
			self.mods_scroll_list.update_fn = function(context, widget, data, index, ...)
				_update_fn(context, widget, data, index, ...)
				PatchModIcon(widget, data)
			end
		end
	end
	
	local function RemoveGnaw()
		TheGlobalInstance:RemoveEventCallback("fe_unloadmods", RemoveGnaw)
		self.ShowModDetails = _ShowModDetails
		self.UpdateForWorkshop = _UpdateForWorkshop
	end
	
	TheGlobalInstance:ListenForEvent("fe_unloadmods", RemoveGnaw)
end)

local GameModes = require("regorge/gamemodes")
local function GenerateGameModes()
	local modes = {}
	
	for i, mode in ipairs(GameModes:GetGameModes()) do
		table.insert(modes, {
			id = mode.id,
		})
	end
	
	for i, mod in ipairs(KnownModIndex:GetModsToLoad()) do
		local modinfo = KnownModIndex:GetModInfo(mod)
		if modinfo and modinfo.gorge_compatible and modinfo.gorge_game_modes then
			for i, mode in ipairs(modinfo.gorge_game_modes) do
				table.insert(modes, {
					id = mode.id,
					name = mode.name,
					desc = mode.description,
				})
			end
		end
	end
	
	return modes
end

-- Get custom game modes for spinner
local _LoadModConfigurationOptions = KnownModIndex.LoadModConfigurationOptions
function KnownModIndex:LoadModConfigurationOptions(mod, client, ...)
	local data = _LoadModConfigurationOptions(self, mod, client, ...)
	
	if data then
		for i, v in ipairs(data) do
			if v.name == "fixed_gamemode" then
				local mode_optns = 
				{
					{
						description = "Disabled",
						hover = "",
						data = false,
					}
				}
				
				for i, mode in ipairs(GenerateGameModes()) do
					table.insert(mode_optns, {
						description = mode.name or STRINGS.GORGE.GAMEMODES.NAMES[mode.id] or "ERROR",
						hover = mode.desc or STRINGS.GORGE.GAMEMODES.DESCRIPTIONS[mode.id] or "ERROR",
						data = mode.id,
					})
				end
				
				v.options = mode_optns
			end
		end
	end
	
	return data
end

local function OnUnload()
	DoFnForCurrentScreen(function(self)
		if self.server_settings_tab then
			local mods = RemoveByValue(ModManager:GetEnabledServerModNames(), menv.modname)
			self.server_settings_tab.game_mode.spinner:SetOptions(GetGameModesSpinnerData(mods))
			self.server_settings_tab.game_mode.spinner:Changed()
			self.server_settings_tab.game_mode.spinner:Enable()
		end
	end)

	TheGlobalInstance:RemoveEventCallback("fe_unloadmods", OnUnload)
	
	AssetLoader.UnloadAssets(menv.modname)
	KnownModIndex.LoadModConfigurationOptions = _LoadModConfigurationOptions
end

TheGlobalInstance:ListenForEvent("fe_unloadmods", OnUnload)