local Quagmire_Replatable = Class(function(self, inst)
    self.inst = inst
    self.basedish = ""
    self.dishtype = "generic"
end)

function Quagmire_Replatable:Replate(dishtype, inv, replater)
	if self.inst:HasTag("quagmire_replatable") and dishtype == "silver" then
		local playsound = false

		self.dishtype = dishtype

		self.inst.AnimState:OverrideSymbol("generic_"..self.basedish, "quagmire_generic_"..self.basedish, self.dishtype.."_"..self.basedish)

		self.inst:AddTag("replated_"..tostring(self.basedish))
		self.inst:RemoveTag("quagmire_replatable")

		if not inv then
			self.inst.AnimState:PlayAnimation("fall")
			self.inst.AnimState:PushAnimation("idle")
			playsound = true
		end

		self.inst.replate:set(self.dishtype)

		if not TheNet:IsDedicated() then
			self.inst.inv_image_bg = { atlas = "images/quagmire_food_common_inv_images.xml", image = self.basedish.."_"..self.dishtype..".tex" }
		end

		if replater then
			playsound = true
			UpdateAchievement("cook_silver", replater.userid, true)
		end

		if playsound then
			self.inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/cooking/dish_place")
		end

		UpdateStat(nil, "tributes_silvered", 1)
	end
end

return Quagmire_Replatable
