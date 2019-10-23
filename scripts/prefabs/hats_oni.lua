local function MakeHat(name)
    local fname = "hat_"..name
    local symname = name.."hat"
    local prefabname = symname

    --If you want to use generic_perish to do more, it's still
    --commented in all the relevant places below in this file.
    --[[local function generic_perish(inst)
        inst:Remove()
    end]]

    local function onequip(inst, owner, symbol_override)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, symbol_override or "swap_hat")
        end
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function opentop_onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(fname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)

        MakeHauntableLaunch(inst)

        return inst
    end

    local function straw_custom_init(inst)
        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")
    end

    local function straw()
        local inst = simple(straw_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.STRAWHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        return inst
    end

    local function default()
        return simple()
    end

    local fn = nil
    local assets = { Asset("ANIM", "anim/"..fname..".zip") }
    local prefabs = nil

    if name == "straw" then
        fn = straw
    end

    return Prefab(prefabname, fn or default, assets, prefabs)
end

local function minerhatlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end
--"C:\games\Steam\steamapps\common\Don't Starve Mod Tools\mod_tools\scml.exe" C:\Users\Maks\Desktop\hats\swap_hat_grilling2.scml "C:\games\Steam\steamapps\common\Don't Starve Together\mods\ONI"
return  MakeHat("rocket_navigation"),
		MakeHat("rocket_piloting"),
		MakeHat("exosuit_training"),
		MakeHat("advanced_research"),
		MakeHat("field_research"),
		MakeHat("astronomy"),
		MakeHat("grilling"),
		MakeHat("grilling2"),
        Prefab("minerhatlight", minerhatlightfn)
