local _G = GLOBAL
local rawget = _G.rawget
local rawset = _G.rawset

mods = rawget(_G, "mods")
if not mods then
	mods = {}
	rawset(_G, "mods", mods)
end
env.mods = mods

if rawget(_G, "TheFrontEnd") then
	modimport("scripts/regorge/fe_patches.lua")
else
	modimport("scripts/regorge/worldgen.lua")
end
