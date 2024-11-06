local Quagmire_Fertilizable = Class(function(self, inst)
    self.inst = inst
end)

function Quagmire_Fertilizable:Fertilize(fertilizer, doer)
    if self.inst.components.quagmire_crop ~= nil then        
        self.inst.components.quagmire_crop:Fertilize(fertilizer, doer)
    end

    return true
end

return Quagmire_Fertilizable
