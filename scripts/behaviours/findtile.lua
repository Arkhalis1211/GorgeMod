local SEE_DIST = 3 * TILE_SCALE

local genericfollowposfn = function(inst) return inst:GetPosition() end

local function GetTillTiles(tilex, tiley)
    local result = {}
    local tilecenter = Point(TheWorld.Map:GetTileCenterPoint(tilex, tiley))

    for _, v in ipairs({{-1.99950, -1.99950}, {-0.66649, -1.99950}, {0.66651, -1.99950}, {1.99952, -1.99950}, {-1.99950, -0.66649}, {-0.66649, -0.66649}, {0.66651, -0.66649}, {1.99952, -0.66649}, {-1.99950, 0.66651}, {-0.66649, 0.66651}, {0.66651, 0.66651}, {1.99952, 0.66651}, {-1.99950, 1.99952}, {-0.66649, 1.99952}, {0.66651, 1.99952}, {1.99952, 1.99952}}) do
        local x, z = tilecenter.x + v[1], tilecenter.z + v[2]

        table.insert(result, {x, z})
    end

    return result
end

local function DoActionTill(self, inst, pos)
    local cantill = TheWorld.Map:CanTillSoilAtPoint(pos)
    local x, y, z = pos:Get()
    if cantill then
        local action = BufferedAction(inst, nil, ACTIONS.INTERACT_WITH, inst, pos)
        inst.components.locomotor:PushAction(action)
        self.istill = true
    end
    return cantill
end

FindTile = Class(BehaviourNode, function(self, inst, action)
    BehaviourNode._ctor(self, "FindTile")
    self.inst = inst
    self.action = action
end)

function FindTile:DBString()
    return string.format("Go to pos %s", tostring(self.istill))
end

local NOTAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "player", "monster" }
local ONEOFTAGS = { "plantedsoil", "soil" }
function FindTile:Visit()
    if self.status == READY then
        self:PickTarget()
        if self.istill then
			self.status = RUNNING
		else
			self.status = FAILED
        end
    end 
    if self.status == RUNNING then
        local plant = self.istill

        if not plant then
            self.istill = false
            self.status = FAILED
        else
            self.istill = false
            self.status = SUCCESS
        end
    end
end

function FindTile:PickTarget()
    if not self.inst:HasTag("tiller") or self.inst:HasTag("tired") then
        return
    end

    local pos = self.inst:GetPosition()
    local tilex, tiley = TheWorld.Map:GetTileCoordsAtPoint(pos.x, pos.y, pos.z)
    self.snaplistaction = GetTillTiles(tilex, tiley)

    local index = 1

    for i = #self.snaplistaction, 1, -1 do
        local snap = self.snaplistaction[i]
        local ents = TheSim:FindEntities(snap[1], 0, snap[2], 1, nil, NOTAGS, ONEOFTAGS)
        local flagremove = false

        for _, v in pairs(ents) do
            flagremove = true
            break
        end 

        if flagremove then 
            table.remove(self.snaplistaction, i) 
        end
    end

    while self.inst:IsValid() do
        local coord = self.snaplistaction[index]
        if coord == nil then break end
        if not DoActionTill(self, self.inst, Point(coord[1], 0, coord[2])) then break end

        index = index + 1
    end
end
