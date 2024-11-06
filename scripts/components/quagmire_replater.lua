local Quagmire_Replater = Class(function(self, inst)
    self.inst = inst
    self.basedish = nil
    self.dishtype = nil
end)

function Quagmire_Replater:SetUp(basedish, dishtype)
    self.basedish = basedish
    self.dishtype = dishtype
end

return Quagmire_Replater
