local RoundsCalculator = require "gorge_rounds"
local CoinLogic = require "coin_logic"
local Foods = require "gorge_cooking"
local CutSceneFns = require "cut_scenes"

local COIN_RANGE = 2.5

local function DropCoins(inst, coins, pos)
	for id, count in ipairs(coins) do
		if count > 0 and (not GetGorgeGameModeProperty("endless") or id ~= 4) then
			for i = 1, count do
				inst:DoTaskInTime(i * id/10, function()
					local coin = SpawnPrefab("quagmire_coin"..id)

					local angle = math.pi * 2 * math.random()
					local range = math.max(COIN_RANGE * math.random(), 1)
					coin.Transform:SetPosition(pos.x + math.cos(angle) * range, 0, pos.z + math.sin(angle) * range)

					coin:Fall()
				end)
			end
		end
	end
end

local Quagmire = Class(function(self, inst)
	self.inst = inst

	self.current_craving = nil
	self.round = 0
	self.endgame = false
	self.gameresult = nil
	self.kitchenkits = deepcopy(TUNING.GORGE.SAFES_LOOT)

	self.inst:ListenForEvent("hangriness_delta", function(src, data)
		if data.current <= 0 then
			if GetGorgeGameModeProperty("endless") and self.inst.components.quagmireanalytics:GetGameTime() >= TUNING.GORGE.ENDLESS_MIN_TIME then
				self:GoodEnding()
			else
				self:BadEnding()
			end
		end
	end, TheWorld)

	self.inst:ListenForEvent("quagmire_win", function(src, data)
		self:GoodEnding()
	end, TheWorld)

	self.inst:ListenForEvent("ms_playerleft", function()
		if #AllPlayers == 0 then
			self:EndGame()
		end
	end)

    self.inst:ListenForEvent("ms_newplayercharacterspawned", function(src, data)
		if #AllPlayers == #GetPlayerClientTable() then
            self.inst:PushEvent("quagmire_allplayersspawned")
        end
	end)

	self.inst:DoTaskInTime(0, function()
		self.hangriness = self.inst.net.components.quagmire_hangriness
	end)
	
	CutSceneManager.quagmire = self
end)

function Quagmire:PushSnacrifice(data)
	local food_id = tonumber(string.match(data.product, "[%w+]%d+"))

	local cravings = Foods.GetCravingsByRecipe(data.product)

	local coins, appraisal_data = CoinLogic:CalculateReward(TUNING.GORGE.COIN_VALUES[food_id], data.stale, data.spoiled, self.current_craving, cravings, data.silverdish)
	
	if GetGorgeGameModeProperty("endless") and coins[4] and coins[4] > 0 then
		self.hangriness.DoDelta(self.hangriness.max * TUNING.GORGE.ENDLESS_BONUS * coins[4])
	end

	local pos = TheWorld.altar:GetPosition()
	self.inst:DoTaskInTime(0.2, function()
		DropCoins(self.inst, coins, pos)
	end)
	
	if self.inst.net._soul_active:value() then
		self.hangriness:Start(self.hangriness.max)
		self.inst:DoTaskInTime(0, function()
			self.hangriness:Stop()
		end)
	end
	
	self.inst:PushEvent("ms_quagmirerecipeappraised", {
		product = data.product,
		dish = data.dish,
		silverdish = data.silverdish,
		maxvalue = appraisal_data.maxvalue,
		matchedcraving = appraisal_data.matchedcraving,
		snackpenalty = appraisal_data.snackpenalty,
		salted = data.salted,
		coins = coins,
		matched = appraisal_data.matchedcraving ~= "",
		craving = cravings, -- Surg: Fox, this is self.current_craving or "table" cravings? not used anywhere (or analitics, later)
		recipe = data.recipe or {},
	})

	if data.chief then
		local chief = LookupPlayerInstByUserID(data.chief)
		if chief and chief:HasTag("masterchef") then
			self.inst:DoTaskInTime(4, function()
				if TheNet:IsDedicated() then
					self.hangriness:DoRumble(true)
				else
					TheWorld:PushEvent("quagmirehangrinessrumbled", { major = true })
				end

				local coins = {0, 0, 0, 0}

				if food_id < 20 then
					coins[1] = 1
				elseif food_id < 30 then
					coins[1] = 3
				elseif food_id < 50 then
					coins[2] = 1
				else
					coins[2] = 2
				end

				DropCoins(self.inst, coins, pos)
			end)
		end
	end

	if data.doer and appraisal_data.matchedcraving ~= "" then
		UpdateAchievement("tribute_fast", data.doer.userid, {matchedcraving = true})
	end

	self:GenerateNextCraving()
end

function Quagmire:BadEnding() -- TheWorld.components.quagmire:BadEnding()
	self.endgame = true
	self.gameresult = false

	self.inst:PushEvent("ms_gameend", 0)
	self.hangriness:Stop()
	
	CutSceneManager:SetCutScene(CUT_SCENE.LOST)
end

function Quagmire:GoodEnding() -- TheWorld.components.quagmire:GoodEnding()
	self.endgame = true
	self.gameresult = true
	
	self.inst:PushEvent("ms_gameend", 1)
	self.hangriness:Stop()

	CutSceneManager:SetCutScene(CUT_SCENE.WON)
end

function Quagmire:StartHangriness()
	self.inst.net.components.quagmire_hangriness:DoStart()
end

function Quagmire:GenerateNextCraving()
	self.round = self.round + 1
	self.current_craving = string.lower(RoundsCalculator:GetCraving(self.round))
	self.inst:PushEvent("ms_cravingchanged", {current = self.current_craving})
end

function Quagmire:UpdatePrototyping(val)
	self.inst:PushEvent("updateshops", val)
end

function Quagmire:GetCraving()
	return self.current_craving
end

function Quagmire:GetSafeLoot()
	local result = nil

	if #self.kitchenkits > 0 then
		local index = math.random(1, #self.kitchenkits)
		result = self.kitchenkits[index]
		table.remove (self.kitchenkits, index)
	end

	return result
end

local function ResetGame(id)
    local function doreset()
        StartNextInstance({
            reset_action = RESET_ACTION.LOAD_SLOT,
            save_slot    = ShardGameIndex:GetSlot(),
			gorge_game_mode = id or Settings.gorge_game_mode or "default",
        })
    end
	ShardGameIndex:Delete(doreset, true)
end

function Quagmire:EndGame()
	self.inst.components.quagmireanalytics:PushMatchResults()

	ResetGame()
end

function Quagmire:ChangeMode(id)
	ResetGame(id)
end

function Quagmire:GetDebugString()
	return string.format("craving: %s, round: %i", tostring(self.current_craving), self.round)
end

CutSceneManager = Class(function(self, inst)
	self.inst = TheWorld
	
	self.cut_scene = CUT_SCENE.NONE
end)

function CutSceneManager:SetCutScene(val)
	if val == self.cut_scene then
		return
	end
	
	if val ~= CUT_SCENE.NONE then
		CutSceneFns[val](self)
	end
	
	self.cut_scene = val
	
	TheWorld:PushEvent("ms_cutscene", val)
end

return Quagmire
