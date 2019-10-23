local Assets =
{
	Asset("ANIM", "anim/bars.zip"),
	Asset("IMAGE", "images/blue_suit.tex"),
	Asset("ATLAS", "images/blue_suit.xml"),	 
}


local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("bars")
	inst.AnimState:SetBuild("bars")
	inst.AnimState:PlayAnimation("idle")

	
	--cookable (from cookable component) added to pristine state for optimization
	inst:AddTag("cookable")

	MakeInventoryFloatable(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 10
	inst.components.edible.hungervalue = 15
	inst.components.edible.sanityvalue = -5     
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(600)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("stackable")

	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	inst:AddComponent("bait")

	inst:AddComponent("tradable")

	inst:AddComponent("cookable")
	inst.components.cookable.product = "mushbar_cooked"

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

local function fn_cooked()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("bars")
	inst.AnimState:SetBuild("bars")
	inst.AnimState:PlayAnimation("mushbar_cooked")


	MakeInventoryFloatable(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(700)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 25
	inst.components.edible.hungervalue = 35
	inst.components.edible.sanityvalue = 0
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	---------------------        

	inst:AddComponent("bait")

	------------------------------------------------
	inst:AddComponent("tradable")

	MakeHauntableLaunchAndPerish(inst)

	return inst
end


local function fn_fieldration()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("bars")
	inst.AnimState:SetBuild("bars")
	inst.AnimState:PlayAnimation("fieldration")


	MakeInventoryFloatable(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(700)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 25
	inst.components.edible.hungervalue = 35
	inst.components.edible.sanityvalue = 0
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	---------------------        

	inst:AddComponent("bait")

	------------------------------------------------
	inst:AddComponent("tradable")

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

local function fn_fruitcake()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("bars")
	inst.AnimState:SetBuild("bars")
	inst.AnimState:PlayAnimation("fruitcake")


	MakeInventoryFloatable(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(700)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 25
	inst.components.edible.hungervalue = 35
	inst.components.edible.sanityvalue = 0
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	---------------------        

	inst:AddComponent("bait")

	------------------------------------------------
	inst:AddComponent("tradable")

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

return Prefab( "mushbar", fn, Assets),
		Prefab("mushbar_cooked", fn_cooked, Assets),
		Prefab("mushbar_fieldration", fn_fieldration, Assets),
		Prefab("mushbar_fruitcake", fn_fruitcake, Assets)
