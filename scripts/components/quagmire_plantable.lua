local Quagmire_Plantable = Class(function(self, inst)
    self.inst = inst
    self.product = nil
end)

function Quagmire_Plantable:Plant(target, doer)  
    local product = self.inst.components.quagmire_plantable.product

    if not product or not doer then
        return false
    end
	
    SpawnAt("quagmire_"..product.."_planted", target).components.quagmire_crop.farmer = doer.userid
    doer.SoundEmitter:PlaySound("dontstarve/common/plant")
	
	UpdateStat(doer.userid, "crops_planted", 1)
	UpdateAchievement("farm_sow_all", doer.userid, self.inst.prefab)
	
    target:Remove()
    self.inst:Remove()

    return true
end

return Quagmire_Plantable