local Quagmire_Cookwaretrader = Class(function(self, inst)
    self.inst = inst
    self.acceptcookwaretest = nil
    self.inst:AddTag("quagmire_cookwaretrader")
end)

function Quagmire_Cookwaretrader:SetAcceptCookwareTest(fn)
    self.acceptcookwaretest = fn
end

function Quagmire_Cookwaretrader:AcceptCookware(giver, item)
    if self.acceptcookwaretest ~= nil and not self.acceptcookwaretest(self.inst, giver, item) then
        return false
    end

    if self.inst.components.shelf ~= nil then
        if self.inst.components.shelf.itemonshelf ~= nil then
            return false
        end

        item.cook_pending = giver.userid

        self.inst.components.shelf.cantakeitem = true
        self.inst.components.shelf:PutItemOnShelf(item)
        giver.components.inventory:RemoveItem(item)
        item:Hide()

        return true
    end    

    return false
end

return Quagmire_Cookwaretrader
