local function trygrowth(inst)
	local crop = inst.components.quagmire_crop
	if crop and crop.stage ~= crop.countstages then
		crop:Grow()
	end
end

local function OnRead(inst, reader)
	local x, y, z = reader.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, 0, z, TUNING.GORGE.BOOK_FERTILIZER_RANGE, nil, nil, { "plantedsoil" })
	if #ents > 0 then
		for k, plant in ipairs(ents) do
			for i = 0, 1 do
				plant:DoTaskInTime(i + math.random(), trygrowth)
			end
		end
	end

	inst:Remove()
	return true
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = "book_gardening"

		inst:AddComponent("inspectable")

		inst:AddComponent("book")
		inst.components.book.onread = OnRead
	end,
}
