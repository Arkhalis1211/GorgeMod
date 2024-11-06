function MakeQuagmireShop(inst, onnear, onfar, onactivate, nomumsy)
    inst.nomumsy = nomumsy

    inst:AddComponent("prototyper")
    inst.components.prototyper.onactivate = onactivate
    
    inst:AddComponent("craftingstation")
	
	inst:AddComponent("playerprox")
	inst.components.playerprox.near = 4
	inst.components.playerprox.far = 6
	inst.components.playerprox.onnear = onnear
	inst.components.playerprox.onfar = onfar
end

function MakeQuagmireCookDish(inst, suffix, station)
    local function CloseContainer(inst)
        inst.components.container:Close()
        inst.AnimState:Show("Lid")
    end

    local function OnOpen(inst, data)
		inst.AnimState:Hide("Lid")
		
		if not data or not data.slot then
			inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
		end

        local x, y, z = inst.Transform:GetWorldPosition()
        if inst.components.inventoryitem:GetContainer() then
            inst.components.container:Open(inst.components.inventoryitem.owner)
            inst.components.inventoryitem:RemoveFromOwner()
            inst.components.inventoryitem:DoDropPhysics(x, y, z, true, .5)
        end
    end 

    local function OnClose(inst)
        inst.AnimState:Show("Lid")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    end

    local function OnItemLose(inst)
        if inst:HasTag("soiled") then
            inst:RemoveTag("soiled")
            inst.AnimState:Hide("goop")
            inst.components.inventoryitem:ChangeImageName(inst.prefab)
        end
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(CloseContainer)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("quagmire_pot"..suffix)
    inst.components.container.onopenfn = OnOpen        
    inst.components.container.onclosefn = OnClose

    inst:AddComponent("quagmire_stewer")
    inst.components.quagmire_stewer.stationname = station

    inst:ListenForEvent("itemget", OnOpen)
    inst:ListenForEvent("itemlose", OnItemLose)
end
