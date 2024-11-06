local function Print(...) -- For debugging
	if CHEATS_ENABLED then
		print(...)
	end
end

require "behaviours/mumsywander"
require "behaviours/findandstay"
require "behaviours/doaction"

local MAX_WANDER_DIST = 20

local SOLO_START_FACE_DIST = 8
local SOLO_KEEP_FACE_DIST = 10

local RANGE_NEAR_PLAYER = 3 -- Fox: We need to keep their private space

local WANDER = {
	ANGLE = 45,
	ANGLE_RNG = {-100, 100},
	DIST = {8, 14}
}

local STANDSTILL_STATES = {
	-- [GOATMUM_STATES.IDLE] = true,
	[GOATMUM_STATES.START] = true,
	[GOATMUM_STATES.WELCOME] = true,
	[GOATMUM_STATES.WAIT_FOR_PURCHASE] = true,
	[GOATMUM_STATES.SNACKRIFICE] = true,
	[GOATMUM_STATES.GAMELOST] = true,
	[GOATMUM_STATES.GAMEWON] = true,
}

local function GetLeashPos(inst)
    return inst.components.knownlocations:GetLocation("portal") or nil
end

local function WhenStandStill(inst)
	return inst.sg:HasStateTag("busy") or STANDSTILL_STATES[inst.components.goatmum:GetState()]
end

-- Fox: This pot is so interesting...

local function PotTest(inst)
	local stewer

    if inst.takeitem:value() ~= nil then
        stewer = inst.takeitem:value()
    elseif inst.components.quagmire_stewer ~= nil then
        stewer = inst
    end
	
	if stewer ~= nil and stewer.components.quagmire_stewer ~= nil then
		return stewer.components.quagmire_stewer:IsBusy() and not inst:HasTag("fueldepleted")
    end
	
	return false
end

local function GetPotToThinkAbout(inst)
	local self = inst.brain
	
	-- Check the old one first
	if self.pot and not PotTest(self.pot) then
		Print("Mumsy lost a pot")
		self.pot = nil
	end
	
	if not self.pot then
		for i, point in ipairs(inst.points) do
			if PotTest(point) then
				self.pot = point
				Print("Mumsy found a pot", point)
				break
			end
		end
	end
	
	-- inst:PushEvent("pot_updated", self.pot)
	
	return self.pot
end

local function KeepFaceTarget(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, 4)
end

local function GetFaceTarget(inst)
	if inst.components.goatmum.shop_active then
		local target = FindClosestPlayerToInst(inst, 4, true)
		return target ~= nil and not target:HasTag("notarget") and target or nil
	end
end

local cached_player
local cached_dist = math.huge
local function GetwalkPos(inst)
	local player = FindClosestPlayerToInst(TheWorld.spawnportal, MAX_WANDER_DIST, true)
	if player then
		local dist = inst:GetDistanceSqToInst(player)
		-- We stay near cached player
		if player.userid == cached_player and dist <= cached_dist then
			cached_dist = dist
			Print("we are staying.")
			return
		end
		cached_dist = dist
		cached_player = player.userid
		
		Print("found player!", player)
		local angle = TheWorld.spawnportal:GetAngleToPoint(player.Transform:GetWorldPosition())
		if angle > -135 and angle < 45 then
			Print("player is in range!", player)
			local pos = player:GetPosition()
			local angle = math.random() * 2 * math.pi
			return Vector3(pos.x + math.cos(angle) * RANGE_NEAR_PLAYER, 0, pos.z + math.sin(angle) * RANGE_NEAR_PLAYER)
		end
	end
	Print("no players...")
	local portal = TheWorld.spawnportal
	return FindWalkableOffset(portal:GetPosition(), WANDER.ANGLE + math.random(unpack(WANDER.ANGLE_RNG)), math.random(unpack(WANDER.DIST)), 30, true, false)
end

local function GetAltar(inst)
	return TheWorld.altar
end

local MumsyBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function MumsyBrain:OnStart()
	local root =

	PriorityNode(
	{
		WhileNode(function() return self.inst.components.goatmum:GetState() == GOATMUM_STATES.SNACKRIFICE end, "WatchCraving", FindAndStay(self.inst, 3.5, GetAltar, true)),
        FaceEntity(self.inst, GetFaceTarget, KeepFaceTarget),
		WhileNode(function() return WhenStandStill(self.inst) end, "Standing", StandStill(self.inst)),
		FindAndStay(self.inst, 3.5, GetPotToThinkAbout),
		MumsyWander(self.inst, GetLeashPos, MAX_WANDER_DIST, {
			minwalktime = 1.25,
			randwalktime = 1.65,
			minwaittime = 2,
			randwaittime = 2.5,
		},
		GetwalkPos)
	}, 0.25)
	self.bt = BT(self.inst, root)
end

return MumsyBrain
