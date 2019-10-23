local Assets =
{
	Asset("ANIM", "anim/yellow_suit.zip"),
	Asset("ANIM", "anim/suits.zip"),
	Asset("IMAGE", "images/yellow_suit.tex"),
	Asset("ATLAS", "images/yellow_suit.xml"),	 
}


local function Equip(inst, doer)
	doer.AnimState:OverrideSymbol("torso", "yellow_suit", "torso")
	doer.AnimState:OverrideSymbol("torso_pelvis", "yellow_suit", "torso_pelvis")
	doer.AnimState:OverrideSymbol("arm_lower", "yellow_suit", "arm_lower")
	doer.AnimState:OverrideSymbol("leg", "yellow_suit", "leg")
	doer.AnimState:OverrideSymbol("hand", "yellow_suit", "hand")
	doer.AnimState:OverrideSymbol("foot", "yellow_suit", "foot")
	doer.AnimState:OverrideSymbol("arm_upper_skin", "yellow_suit", "arm_upper_skin")
	doer.AnimState:OverrideSymbol("arm_upper", "yellow_suit", "arm_upper")
	inst.components.fueled:StartConsuming()
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("suits")
	inst.AnimState:SetBuild("suits")
	inst.AnimState:PlayAnimation("idle_yellow")

	inst:AddTag("hat")
	inst:AddTag("ONI_suit")

    MakeInventoryFloatable(inst, "med", 0.1, 0.70)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/yellow_suit.xml"
	
	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(0.1)
	inst.components.fueled:SetDepletedFn(inst.Remove)
		
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip( Equip )
	
	return inst
end

return Prefab( "yellow_suit", fn, Assets)