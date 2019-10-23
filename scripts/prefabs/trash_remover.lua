require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/microbemusher.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}

local prefabs =
{
    "winona_battery_sparks",
    "collapse_small",
}

local function OnWorked(inst, worker, workleft, numworks)
    inst.components.workable:SetWorkLeft(4)
end

local function OnWorkedBurnt(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)

    inst.SoundEmitter:KillAllSounds()

    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkedBurnt)

    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()

    inst:AddTag("notarget") 
end

local function OnBuilt(inst)--, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst.AnimState:PlayAnimation("activate")
end

local function OnSave(inst, data)
	data.power = inst._powertask ~= nil and math.ceil(GetTaskRemaining(inst._powertask) * 1000) or nil
end

local function OnLoad(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    if data ~= nil then
    else
        if data ~= nil and data.power ~= nil then
            inst:AddBatteryPower(math.max(2 * FRAMES, data.power / 1000))
            if inst:HasTag("idle") then
                inst.AnimState:PlayAnimation("idle", true) --loading = true
            end
        end
        --Enable connections, but leave the initial connection to batteries' OnPostLoad
        inst.components.circuitnode:ConnectTo(nil)
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineeringbattery")
end

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

    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("inner")
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
            if recipename == "winona_catapult" then
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

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst._powertask == nil and "OFF")
        or nil
end

local function PowerOff(inst)
    inst._powertask = nil
    inst:PushEvent("togglepower", { ison = false })
end

local function AddBatteryPower(inst, power)
    local remaining = inst._powertask ~= nil and GetTaskRemaining(inst._powertask) or 0
    if power > remaining then
        local doturnon = false
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
        else
            doturnon = true
        end
        inst._powertask = inst:DoTaskInTime(power, PowerOff)
        if doturnon then
            if not inst:IsAsleep() then
            end
            inst:PushEvent("togglepower", { ison = true })
        end
    end
end

local function IsPowered(inst)
    return inst._powertask ~= nil
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function OnCircuitChanged(inst)
    inst.AnimState:PlayAnimation("activate")
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)    
end

local function OnConnectCircuit(inst)--, node)
    if not inst._wired then
        inst._wired = true

    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)--, node)
    if inst.components.circuitnode:IsConnected() then
        OnCircuitChanged(inst)
    elseif inst._wired then
        inst._wired = nil
        if inst._powertask ~= nil then
            inst._powertask:Cancel()
            PowerOff(inst)
        end
    end
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

    inst.Transform:SetSixFaced()

    inst:AddTag("companion")
    inst:AddTag("noauradamage")
    inst:AddTag("engineering")
    inst:AddTag("catapult")
    inst:AddTag("structure")

    inst.AnimState:SetBank("microbemusher")
    inst.AnimState:SetBuild("microbemusher")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("winona_catapult.png")

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._state = 1

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("updatelooper")
    inst:AddComponent("colouradder")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(OnWorked)

    inst:AddComponent("savedrotation")

    inst:AddComponent("circuitnode")
    inst.components.circuitnode:SetRange(TUNING.WINONA_BATTERY_RANGE)
    inst.components.circuitnode:SetOnConnectFn(OnConnectCircuit)
    inst.components.circuitnode:SetOnDisconnectFn(OnDisconnectCircuit)
    inst.components.circuitnode.connectsacrossplatforms = false

    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("engineeringcircuitchanged", OnCircuitChanged)

    MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.AddBatteryPower = AddBatteryPower
    inst.IsPowered = IsPowered

    inst._wired = nil
    inst._flash = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

--------------------------------------------------------------------------

local function CreatePlacerCatapult()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("microbemusher")
    inst.AnimState:SetBuild("microbemusher")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(1)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the catapult placer on top of the catapult range ground placer
    --Also add the small battery range indicator

    local placer2 = CreatePlacerBatteryRing()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    placer2 = CreatePlacerCatapult()
    placer2.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:Hide("inner")
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
end

--------------------------------------------------------------------------
return Prefab("trash_remover", fn, assets, prefabs),
    MakePlacer("trash_remover_placer", "winona_catapult_placement", "winona_catapult_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)
