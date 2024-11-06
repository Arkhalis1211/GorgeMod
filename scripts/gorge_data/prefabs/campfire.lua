local function onupdatefueled(inst)
	if inst.components.burnable ~= nil and inst.components.fueled ~= nil then

		if inst.components.fueled:GetCurrentSection() == 1 then
			inst.components.fueled.rate = 0
		else
			inst.components.fueled.rate = TheWorld.state.israining and 1 + TUNING.CAMPFIRE_RAIN_RATE * TheWorld.state.precipitationrate or 1
		end

		inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
	end
end

return {
	master_postinit = function(inst)
		inst.components.fueled:SetUpdateFn(onupdatefueled)
	end,
}
