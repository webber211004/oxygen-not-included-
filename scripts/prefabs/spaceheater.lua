require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/spaceheater.zip"),
    Asset("ANIM", "anim/winona_spotlight_placement.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local assets_head =
{
    Asset("ANIM", "anim/spaceheater.zip"),
}

local prefabs =
{
    "winona_spotlight_head",
    "winona_battery_sparks",
    "collapse_small",
}

--------------------------------------------------------------------------

local PLACER_SCALE = 1.5

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    elseif helperinst:IsNear(helperinst.placerinst, TUNING.WINONA_BATTERY_RANGE) then
        local hp = helperinst:GetPosition()
        local p1 = TheWorld.Map:GetPlatformAtPoint(hp.x, hp.z)

        local pp = helperinst.placerinst:GetPosition()
        local p2 = TheWorld.Map:GetPlatformAtPoint(pp.x, pp.z)

        if p1 == p2 then
            helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
        else
            helperinst.AnimState:SetAddColour(0, 0, 0, 0)
        end
    else
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

local function CreatePlacerBatteryRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    return inst
end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_spotlight_placement")
    inst.AnimState:SetBuild("winona_spotlight_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    CreatePlacerBatteryRing().entity:SetParent(inst.entity)

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
            if recipename == "spaceheater" then
                inst.helper = CreatePlacerRing()
                inst.helper.entity:SetParent(inst.entity)
            else
                inst.helper = CreatePlacerBatteryRing()
                inst.helper.entity:SetParent(inst.entity)
                if placerinst ~= nil and (recipename == "winona_battery_low" or recipename == "winona_battery_high") then
                    inst.helper:AddComponent("updatelooper")
                    inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                    inst.helper.placerinst = placerinst
                    OnUpdatePlacerHelper(inst.helper)
                end
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

--------------------------------------------------------------------------


local function OnUpdateLightServer(inst, dt)
	--inst.AnimState:PlayAnimation("activate")
	inst.AnimState:PlayAnimation("activate")
	inst.AnimState:PushAnimation("idle_on", true)
end

local function EnableLight(inst, enable)
    if not enable then
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
            inst._powertask = nil
        end

		inst.AnimState:SetLightOverride(0)
		inst.AnimState:PlayAnimation("deactivate")
		inst.AnimState:PushAnimation("idle_off", true)
    else
        if inst.AnimState:IsCurrentAnimation("place") then
			inst.AnimState:PlayAnimation("activate")
            inst.AnimState:PushAnimation("idle_on", true)
        end
        if not inst:IsAsleep() then
			OnUpdateLightServer(inst, 0)
        end
    end
end

--------------------------------------------------------------------------

local function OnBuilt2(inst)
    if inst.components.workable:CanBeWorked() then
        inst:RemoveTag("NOCLICK")
        if not inst:HasTag("burnt") then
            inst.components.circuitnode:ConnectTo("engineeringbattery")
        end
    end
end

local function OnBuilt3(inst)
    inst:RemoveEventCallback("animover", OnBuilt3)
    if inst.AnimState:IsCurrentAnimation("place") then
		inst.AnimState:PlayAnimation("idle_off", true)
    end
end

local function OnBuilt(inst)--, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst:AddTag("NOCLICK")
    EnableLight(inst, false)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/place")
    inst:DoTaskInTime(37 * FRAMES, OnBuilt2)
    inst:ListenForEvent("animover", OnBuilt3)
end

--------------------------------------------------------------------------

local function OnWorked(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
end

local function OnWorkFinished(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.components.workable:SetWorkable(false)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.Physics:SetActive(false)
    inst.components.lootdropper:DropLoot()
    inst.AnimState:Show("light")
    EnableLight(inst, false)
    inst.AnimState:PlayAnimation("death_pst")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/destroy")

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("none")

    inst:DoTaskInTime(2, ErodeAway)
end

local function OnWorkedBurnt(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

--------------------------------------------------------------------------

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst._powertask == nil and "OFF")
        or nil
end

local function AddBatteryPower(inst, power)
    local remaining = inst._powertask ~= nil and GetTaskRemaining(inst._powertask) or 0
    if power > remaining then
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
        else
            EnableLight(inst, true)
        end
        inst._powertask = inst:DoTaskInTime(power, EnableLight, false)
    end
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
end

local function OnConnectCircuit(inst)--, node)
    if not inst._wired then
        inst._wired = true
        inst.AnimState:ClearOverrideSymbol("wire")
    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if inst.components.circuitnode:IsConnected() then
        OnCircuitChanged(inst)
    elseif inst._wired then
        inst._wired = nil
        inst.AnimState:OverrideSymbol("wire", "spaceheater", "dummy")
        EnableLight(inst, false)
    end
end

--------------------------------------------------------------------------

local function OnSave(inst, data)
	data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil
end

local function OnLoad(inst, data)
    if data ~= nil then
		local dirty = false

		if data.power ~= nil then
			AddBatteryPower(inst, math.max(2 * FRAMES, data.power / 1000))
		end
    end

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if inst.components.workable:CanBeWorked() and not inst:HasTag("burnt") then
        inst.components.circuitnode:ConnectTo(nil)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.Transform:SetEightFaced()

    inst:AddTag("engineering")
    inst:AddTag("spotlight")
    inst:AddTag("structure")

    inst.AnimState:SetBank("spaceheater")
    inst.AnimState:SetBuild("spaceheater")
    inst.AnimState:PlayAnimation("idle_off", true)

    inst.MiniMapEntity:SetIcon("spaceheater.png")

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("spaceheater")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("colouradder")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)

    MakeHauntableWork(inst)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.AddBatteryPower = AddBatteryPower

    inst._wired = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

-----------------------------------------------------------------

return Prefab("spaceheater", fn, assets, prefabs),
    MakePlacer("spaceheater_placer", "spaceheater", "spaceheater", "idle_off")
