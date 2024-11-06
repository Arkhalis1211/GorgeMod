require "behaviours/wander"
require "behaviours/leash"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local STOP_RUN_DIST = 7
local SEE_PLAYER_DIST = 3

local AVOID_PLAYER_DIST = 2
local AVOID_PLAYER_STOP = 4

local MAX_LEASH_DIST = 10
local MAX_WANDER_DIST = 10

local function GetHome(inst)
	return inst.components.knownlocations:GetLocation("home")
end

local Quagmire_ChickenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function Quagmire_ChickenBrain:OnStart()
    local root = PriorityNode(
    {
        Leash(self.inst, function() return GetHome(self.inst) end, MAX_LEASH_DIST, MAX_WANDER_DIST),
		WhileNode(function() return self.inst.sg:HasStateTag("idle") end, "Wandering", 
			Wander(self.inst, function() return GetHome(self.inst) end, MAX_WANDER_DIST)
		),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

function Quagmire_ChickenBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end

return Quagmire_ChickenBrain