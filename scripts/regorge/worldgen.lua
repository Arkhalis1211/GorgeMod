local menv = env
GLOBAL.setfenv(1, GLOBAL)

require "map/lockandkey"
require "map/tasks"
require "map/rooms"
require "map/terrain"
require "map/level"
require "map/room_functions"
require "worldtiledefs"

local UpvalueHacker = require "tools/upvaluehacker"

-- Fox: Klei were obviously trying to shut down any attempts to create this mod
local levellist = UpvalueHacker.GetUpvalue(AddLevel, "levellist")
if levellist then
	levellist.QUAGMIRE[1].background_node_range = {0, 1}
end

-- Asura: Let's make custom soil edge
local soil = LookupTileInfo(GROUND.QUAGMIRE_SOIL)
if menv.GetModConfigData("newsoil") then
	soil.name = "farmsoil" 
else
	soil.name = "carpet" 
end