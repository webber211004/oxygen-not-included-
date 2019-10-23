local Assets =
{
	Asset("ANIM", "anim/wiam_goggles.zip"),
	Asset("ANIM", "anim/swap_wiam_goggles.zip"),
	Asset("IMAGE", "images/wiam_goggles.tex"),
	Asset("ATLAS", "images/wiam_goggles.xml"),	 
}


local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_hat", "swap_wiam_goggles", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
		
	owner.AnimState:Show("HEAD")
	owner.AnimState:Hide("HEAD_HAT")
			
	if owner:HasTag("ONIeater") then
		if owner.components.eater ~= nil then
			owner.components.eater:SetDiet({ FOODTYPE.MEAT, FOODTYPE.GOODIES,  FOODGROUP.OMNI }, { FOODTYPE.MEAT, FOODTYPE.GOODIES,  FOODGROUP.OMNI })
		end
	end
	
	inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAIR")
	end
	if owner:HasTag("ONIeater") then
		if owner.components.eater ~= nil then
			owner.components.eater:SetDiet({ FOODGROUP.OMNI, FOODTYPE.MEAT, FOODTYPE.GOODIES }, {})
		end
	end
	
	inst.components.fueled:StopConsuming()
end

local function onperish(inst)
	inst:Remove()
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("wiam_goggles")
	inst.AnimState:SetBuild("wiam_goggles")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("hat")
	
    MakeInventoryFloatable(inst, "small", nil, 0.95)

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/wiam_goggles.xml"

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(50)
	inst.components.fueled:SetDepletedFn(inst.Remove)
		
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
		
	inst.components.equippable.walkspeedmult = 1.2
	
	return inst
end

return Prefab( "wiam_goggles", fn, Assets)