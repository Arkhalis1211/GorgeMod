--------------------------------------------------------------------------
--[[ Quagmire_Stewer class definition ]]
--------------------------------------------------------------------------
local cooking = require("gorge_cooking")

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local STATES =
{
	NONE = 0,
	FAIL = 1,
	COOKING = 2,
	BURNING = 3,
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _firepit = nil
local _station = nil
local _stationtype = nil
local _stationcofficient = 1

local _state = STATES.NONE
local _bakingcofficient = 1
local _percentheat = 0

local _target = {}
local _cache = {}
local _food_GUIDs = {}
local _cached_food = nil

local _onopenfn = nil
local _onclosefn = nil
local _onitemgetfn = nil
local _onitemlosefn = nil
local _onheatstartfn = nil
local _onheatstopfn = nil
local _ondonecookingfn = nil
local _onfailedcookingfn = nil

local _chief = nil
local _container = inst.components.container
local _isempty = true
local _isopen = false

local _updating = false
local _lock_containerevents = false
local _realtime = 0

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function ClearCache()
	for i = 1, #_cache do
		_cache[i] = {slot = i, prefab = nil, elapsedtime = 0, scheduledtime = 0}
	end
end

local function ResetTarget()
	_target = 
	{
		recipe = nil,
		spoiledrecipe = nil,
		dish = nil,
		dirty = nil,
		recipetime = 0,
		elapsedtime = 0,
		scheduledtime = 0,
		achievement_saved = nil,
	}
end

local function RegisterShief()
	if inst.cook_pending and not _chief then
		_chief = inst.cook_pending
	end
end

local function GetIngredients()
	local num = 0
	local total = 0
	local ingredients = {}

	for _, item in pairs(_container.slots) do
		if item ~= nil then
			table.insert(ingredients, item.prefab)

			if item.components.perishable ~= nil then
				num = num + 1
				total = total + item.components.perishable:GetPercent()
			end
		end
	end

	local spoil = (num <= 0 and 1) or 1 - (1 - total / num) * 0.9

	return ingredients, spoil
end

local function ToggleSpoilageIngredients(enable)
	for _, item in pairs (_container.slots) do
		if item ~= nil and item.components.perishable ~= nil then
			if enable then
				item.components.perishable:StartPerishing()
			else
				item.components.perishable:StopPerishing()
			end
		end
	end
end

local function Start()
	local ingredients, _ = GetIngredients()

	if not cooking.CanCookByIngredients(ingredients) then
		return
	end

	if not _updating and not _isempty then
		ToggleSpoilageIngredients(false)
		inst:StartUpdatingComponent(self)
		_updating = true
	end
end

local function Stop()
	if _updating then
		ToggleSpoilageIngredients(true)
		inst:StopUpdatingComponent(self)
		_updating = false
	end
end

local function PlanningSpoil(max_elapsedtime)
	local foodsoiled = cooking.GetFoodSoiledNormalize(_stationtype, _target.recipe)

	_target.spoiledrecipe = foodsoiled.prefab
	_target.dish = foodsoiled.dish
	_target.dirty = foodsoiled.dirty

	if _target.recipe ~= nil then
		local recipetime = cooking.GetBurningTimeByRecipe(_target.recipe)
		if type(recipetime) == "table" then
			_target.recipetime = recipetime[_stationtype] or 0
		else
			_target.recipetime = recipetime
		end
	else
		_target.recipetime = 25 * _stationcofficient
	end

	if max_elapsedtime == 0 and not inst:HasTag("donecooking") then
		_target.elapsedtime = 0
		_realtime = 0
	end

	if _target.elapsedtime == 0 or max_elapsedtime > _target.elapsedtime then
		_target.elapsedtime = max_elapsedtime
	end

	_target.scheduledtime = _target.elapsedtime + (_target.recipetime - _target.elapsedtime)
end

local function PlanningRecipe()
	local cachereplica = deepcopy(_cache)

	RegisterShief()
	ClearCache()

	if _isempty then
		ResetTarget()
		_state = STATES.NONE
		_chief = nil
		return
	end

	local max_elapsedtime = 0
	local max_difference = 0
	local ingredients = {}

	-- update cache
	for slot = 1, _container.numslots do
		local item = _container.slots[slot]

		if item ~= nil then
			local cookingtime = cooking.GetCookingTimeIngredient(item.prefab) * _stationcofficient * (GetGorgeGameModeProperty("ing_cooking_time") or 1)
			local precooked = cooking.IsPreCookedIngredient(item.prefab)
			local index_cr = 0
			
			_cache[slot].prefab = item.prefab
			_cache[slot].scheduledtime = cookingtime

			if precooked then
				_cache[slot].elapsedtime = cookingtime
			end

			for i = 1, #cachereplica do
				if cachereplica[i].prefab == item.prefab then
					_cache[slot].elapsedtime = cachereplica[i].elapsedtime
					index_cr = i
					break
				end
			end

			local difference = _cache[slot].scheduledtime - _cache[slot].elapsedtime

			if difference > max_difference then
				max_difference = difference
			end

			if _cache[slot].elapsedtime > max_elapsedtime then
				max_elapsedtime = _cache[slot].elapsedtime
			end

			if index_cr > 0 then
				table.remove(cachereplica, index_cr)
			end

			table.insert(ingredients, item.prefab)
		end
	end

	-- planning
	local recipe = cooking.CalculateRecipe(_stationtype, ingredients)

	if recipe ~= nil then
		if _target.recipe ~= recipe then
			_target.recipe = recipe
			_target.dish = cooking.GetDishByRecipe(recipe)
			_target.dirty = nil
			local recipetime = cooking.GetCookingTimeByRecipe(recipe)
			if type(recipetime) == "table" then
				_target.recipetime = recipetime[_stationtype] or 0
			else
				_target.recipetime = recipetime
			end
		end

		_target.spoiledrecipe = nil

		if max_difference == 0 then
			_target.elapsedtime = max_elapsedtime
		end

		if max_elapsedtime == 0 then
			_target.elapsedtime = 0
			_realtime = 0
		end

		local total_time = _target.elapsedtime + max_difference
		local scheduledtime = 0

		if _target.recipetime <= total_time then
			scheduledtime =  max_difference
		else
			scheduledtime = _target.recipetime - _target.elapsedtime
		end

		_target.scheduledtime = scheduledtime + _target.elapsedtime

		_state = STATES.COOKING
	else
		PlanningSpoil(max_elapsedtime)

		if inst:HasTag("donecooking") then
			_state = STATES.BURNING
		else
			_state = STATES.FAIL
		end
	end
end

local function DoDelta(delta)
	local num = 0
	local num_ready = 0

	for i = 1, #_cache do
		if _cache[i].prefab ~= nil then
			local item = _container.slots[i]

			num = num + 1

			_cache[i].elapsedtime = _cache[i].elapsedtime + delta

			if _cache[i].elapsedtime >= _cache[i].scheduledtime then
				_cache[i].elapsedtime = _cache[i].scheduledtime
			end

			if _cache[i].elapsedtime == _cache[i].scheduledtime and item ~= nil then
				num_ready = num_ready + 1

				if  item.components.cookable ~= nil then
					local itemcooked  = item.components.cookable:Cook(inst, nil)

					-- debug info
					--print("[Quagmire_Stewer] Ingredient cooked:", item.prefab, _cache[i].elapsedtime, _realtime)

					if itemcooked.components.perishable ~= nil then
						itemcooked.components.perishable:StopPerishing()
					end

					_lock_containerevents = true

					_container:RemoveItemBySlot(i)
					_container:GiveItem(itemcooked, i)
					item:Remove()

					_lock_containerevents = false

					_cache[i].prefab = itemcooked.prefab
				end
			end
		end
	end

	return (num > 0 and num == num_ready)
end

local function DoStew()
	local food = nil

	if _state == STATES.COOKING and _target.recipe ~= nil then
		food = SpawnPrefab(_target.recipe)
	end

	if (_state == STATES.FAIL or _state == STATES.BURNING) and _target.spoiledrecipe ~= nil then
		food = SpawnPrefab(_target.spoiledrecipe)
	end

	if food ~= nil then
		local ingredients, spoilage = GetIngredients()

		food.recipe =
		{
			product = food.prefab,
			dish = _target.dish,
			station = _stationtype,
			overcooked = false,
			ingredients = {},
		}

		food.chief = _chief

		_lock_containerevents = true

		_container:DestroyContents()
		_container:GiveItem(food)

		_lock_containerevents = false

		ClearCache()

		_cache[1].prefab = food.prefab

		if _state == STATES.FAIL or _state == STATES.BURNING then
			if _state == STATES.BURNING then
				food.recipe.overcooked = true
			end

			if _target.recipe == "quagmire_syrup" then
				food.recipe.dish = "bowl"
			end

			if not inst:HasTag("donecooking") then
				inst:AddTag("donecooking")
			end

			inst:AddTag("failedcooked")

			TheWorld:PushEvent("scannernotice", {scanpref = inst})

			if not inst:HasTag("takeonly") then
				inst:AddTag("takeonly")
			end

			if _onfailedcookingfn ~= nil then
				_onfailedcookingfn(_station, inst, {prefab = _target.spoiledrecipe, dish = "plate", dirty = "burnt"})
			end

			ResetTarget()

			_chief = nil
			_state = STATES.NONE
		end

		if _state == STATES.COOKING then
			if food.components.perishable ~= nil then
				food.components.perishable:StopPerishing()
				food.components.perishable:SetPercent(spoilage)
			end

			food.recipe.ingredients = ingredients

			inst:AddTag("donecooking")
			inst:AddTag("takeonly")

			if _ondonecookingfn ~= nil then
				_ondonecookingfn(_station, inst, {prefab = _target.recipe, dish = _target.dish, dirty = _target.dirty})
			end

			TheWorld:PushEvent("scannernotice", {scanpref = inst})

			-- debug info
			--print("[Quagmire_Stewer] Food cooked:", _target.recipe, _target.elapsedtime, _realtime)

			_target.elapsedtime = 0

			PlanningSpoil(0)

			_state = STATES.BURNING
		end
	end
end

local function UpdateSaverAchievement(taker)
	if taker and _state == STATES.BURNING and _target and
	(_target.elapsedtime / _target.scheduledtime) >= TUNING.GORGE.MEAL_SAVER_DELTA and
	not _target.achievement_saved then
		UpdateStat(taker.userid, "meals_saved", 1)
		_target.achievement_saved = true
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPercentHeatChange(firepit, data)
	local old_percentheat = _percentheat

	_percentheat = data.percent

	if _percentheat > 0 then
		local pernormal = 2 - _percentheat
		local multiplier = 1

		if _station ~= nil and _station.buff._show:value() then
			multiplier = 1.25
		end

		-- Surg: crazy formula, but it provides the similarity timings between 0 - 180 seconds original Gorge :)
		_bakingcofficient =  (pernormal ^ pernormal ^ pernormal) / multiplier
	else
		_bakingcofficient = 1
	end

	if _station ~= nil then
		if _onheatstartfn ~= nil and _percentheat ~= 0 and old_percentheat == 0 then
			_onheatstartfn(_station, inst, _isempty)
			Start()
		end

		if _onheatstopfn ~= nil and _percentheat == 0 and old_percentheat ~= 0 then
			_onheatstopfn(_station, inst)
			Stop()
		end
	end
end

local function OnOpen(stewer, data)
	_isopen = true

	if _station ~= nil then
		_state = STATES.NONE
		Stop()

		if _onopenfn ~= nil then
			_onopenfn(_station, inst)
		end
	end
	
	if data and data.doer and _stationtype == "grill" then
		UpdateSaverAchievement(data.doer)
	end

	if inst:HasTag("donecooking") then
		local food = _container.slots[1]

		if food ~= nil and food.recipe ~= nil and _cached_food ~= food.GUID then
			_cached_food = food.GUID

			if food.chief ~= nil then
				UpdateAchievement("cook_large", food.chief, {recipe = food.recipe})
				UpdateAchievement("cook_all_stations", food.chief, {recipe = food.recipe})
				UpdateAchievement("quag_encore_all_stations_large", food.chief, {recipe = food.recipe})
				if food.recipe.overcooked then
					UpdateStat(food.chief, "meals_burnt", 1)
					UpdateStat(nil, "meals_burnt", 1)
				elseif not food:HasTag("failedcooked") then
					UpdateStat(food.chief, "meals_made", 1)
				end
			end
			
			TheWorld:PushEvent("ms_quagmirerecipediscovered", {recipe = food.recipe})
		end
	end
end

local function OnClose(stewer, data)
	_isopen = false

	if _station ~= nil then
		if data ~= nil and data.doer ~= nil then
			inst.cook_pending = data.doer.userid
		end

		PlanningRecipe()

		if _onclosefn ~= nil then
			_onclosefn(_station, inst)
		end

		if _percentheat > 0 then
			if _onheatstartfn ~= nil then
				_onheatstartfn(_station, inst, _isempty)
			end

			Start()
		end
	end
end

local function OnItemGet(stewer, data)
	_isempty = false

	if _onitemgetfn ~= nil then
		_onitemgetfn(_station, inst, data)
	end
end

local function OnItemLose(stewer, data)
	_isempty = _container:IsEmpty()

	if _onitemlosefn ~= nil then
		_onitemlosefn(_station, inst, data)
	end

	if not _lock_containerevents then
		if inst:HasTag("donecooking") then
			inst:RemoveTag("donecooking")
			inst:RemoveTag("failedcooked")
			inst:RemoveTag("takeonly")
			ClearCache()
			ResetTarget()
			_chief = nil
			_realtime = 0
		end

		if not _updating and _station ~= nil then
			PlanningRecipe()
		end
	end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

ResetTarget()

_isempty = _container:IsEmpty()

for i = 1, _container.numslots do
	table.insert(_cache, {slot = i, prefab = nil, elapsedtime = 0, scheduledtime = 0})
end

inst:ListenForEvent("onopen", OnOpen)
inst:ListenForEvent("onclose", OnClose)
inst:ListenForEvent("itemget", OnItemGet)
inst:ListenForEvent("itemlose", OnItemLose)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetOpenFn(fn)
	_onopenfn = fn
end

function self:SetCloseFn(fn)
	_onclosefn = fn
end

function self:SetItemGetFn(fn)
	_onitemgetfn = fn
end

function self:SetItemLoseFn(fn)
	_onitemlosefn = fn
end

function self:SetHeatStartFn(fn)
	_onheatstartfn = fn
end

function self:SetHeatStopFn(fn)
	_onheatstopfn = fn
end

function self:SetDoneCookingFn(fn)
	_ondonecookingfn = fn
end

function self:SetFailedCookingFn(fn)
	_onfailedcookingfn = fn
end

function self:IsOpen()
	return _isopen
end

function self:GetState()
	return _state
end

function self:IsBusy()
	return _state ~= STATES.NONE
end

function self:Connect(firepit, station, stationtype)
	_firepit = firepit
	_station = station
	_stationtype = stationtype

	if stationtype == "grill" then
		_stationcofficient = 0.75
	elseif stationtype == "oven" then
		_stationcofficient = 1.25
	else
		_stationcofficient = 1
	end

	if stationtype ~= "grill" then
		local pos = station:GetPosition()
		inst.Transform:SetPosition(pos.x, 0.8, pos.z)
		PlanningRecipe()
	end

	if _firepit ~= nil then
		inst:ListenForEvent("percentusedchange", OnPercentHeatChange, _firepit)
		OnPercentHeatChange(_firepit, {percent = _firepit.components.fueled:GetPercent()})
	end
end

function self:Disconnect(taker)
	Stop()

	if _firepit ~= nil then
		inst:RemoveEventCallback("percentusedchange", OnPercentHeatChange, _firepit)
	end
	
	UpdateSaverAchievement(taker)

	_firepit = nil
	_station = nil
	_stationtype = nil
	_stationcofficient = 1
	_bakingcofficient = 1
	_percentheat = 0

	_onopenfn = nil
	_onclosefn = nil
	_onitemgetfn = nil
	_onitemlosefn = nil
	_onheatstartfn = nil
	_onheatstopfn = nil
	_ondonecookingfn = nil
	_onfailedcookingfn = nil

	_lock_containerevents = false
end

--------------------------------------------------------------------------
--[[ Update component ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
	if dt == 0 then
		return
	end

	if _target == nil or _state == STATES.NONE or inst:HasTag("failedcooked") then
		Stop()
		return
	end

	local delta = dt / _bakingcofficient
	local ready = DoDelta(delta)

	_realtime = _realtime + dt

	_target.elapsedtime = _target.elapsedtime + delta

	if _target.elapsedtime >= _target.scheduledtime then
		_target.elapsedtime = _target.scheduledtime
	end

	if _target.elapsedtime == _target.scheduledtime and ready then
		DoStew()
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
	local state = "NONE"

	if _state == STATES.FAIL then
		state = "FAIL"
	elseif _state == STATES.COOKING then
		state = "COOKING"
	elseif _state == STATES.BURNING then
		state = "BURNING"
	end

	local cache = string.format("target [recipe: %s, spoiled recipe: %s scheduled time: %.2f, elapsed time: %.2f]\n", tostring(_target.recipe), tostring(_target.spoiledrecipe), _target.scheduledtime, _target.elapsedtime)
	for _, v in pairs(_cache) do		
		cache = cache..string.format("%s. %s, elapsed time: %.2f / %.2f\n", tostring(v.slot), tostring(v.prefab), v.elapsedtime, v.scheduledtime)
	end

	--debug perishable
	local perishable_info = ""
	for _, item in pairs (_container.slots) do
		if item ~= nil then
			if item.components.perishable ~= nil then
				if item.components.perishable.updatetask ~= nil then
					perishable_info = perishable_info..item.prefab.."[enable]\n"
				else
					perishable_info = perishable_info..item.prefab.."[disable]\n"
				end
			else
				perishable_info = perishable_info..item.prefab.."[none]\n"
			end
		end
	end

	return string.format("updating: %s, state: %s, chief: %s, baking cofficient: %.2f, real time: %.2f\n----CACHE----\n", tostring(_updating), state, tostring(_chief), _bakingcofficient, _realtime)..cache.."\n"..perishable_info
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
