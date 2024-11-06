local chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)
	local items = 
	{
		{
			
			item = {"armorsnurtleshell", "armormarble","armorwood","armorgrass"},
			chance = 0.3,
			initfn = function(item) 
				if item.components.armor then 
					item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.7, item.components.armor.maxcondition))
				end
			end
		},
		--Hats
		{
			item = {"footballhat","slurtlehat","wathgrithrhat"},
			chance = 0.3,
			initfn = function(item) 
			if item.components.armor then
				item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.7, item.components.armor.maxcondition))
				end
			end
		},
		
		{
			item = {"tophat","beehat","spiderhat"},
			chance = 0.4,
		},
	}
	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}
