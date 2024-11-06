local CraftingStation = Class(function(self, inst)
    self.inst = inst
    self.items = {}
end)

function CraftingStation:GetRecipes()
    if not self.inst.quagmire_shoptab then
		print("ERROR: " ..self.inst.prefab.. "s' quagmire_shoptab is nil!")
		return {}
	end
	
	local recipes = {}
	
	for name, rec in pairs(AllRecipes) do
		if rec.tab == self.inst.quagmire_shoptab then
			table.insert(recipes, name)
		end
	end
	
	return recipes
end

return CraftingStation
