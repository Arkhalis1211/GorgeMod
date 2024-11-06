local firelevels =
{
    {anim="level1", sound="dontstarve/common/campfire", radius=0.1, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/campfire", radius=0.3, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/campfire", radius=0.6, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/campfire", radius=0.8, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=1},
}

local firelevels_darkness =
{
    {anim="level1", sound="dontstarve/common/campfire", radius=1, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/campfire", radius=1.5, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/campfire", radius=2.5, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/campfire", radius=3.75, intensity=.8, falloff=.33, colour = {255/255,255/255,192/255}, soundintensity=1},
}

return {
    master_postinit = function(inst)
		if GetGorgeGameModeProperty("darkness") then
			inst.components.firefx.levels = firelevels_darkness
		else
			inst.components.firefx.levels = firelevels
		end
    end,
}
