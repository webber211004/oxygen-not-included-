require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/solar_panel.zip"),
    Asset("ANIM", "anim/winona_battery_placement.zip"),
}


local prefabs =
{
    "collapse_small",
    "winona_battery_high_shatterfx",
}

--------------------------------------------------------------------------

local function DoIdleChargeSound(inst)
    local t = math.floor(inst.AnimState:GetCurrentAnimationTime() / FRAMES + .5) % inst._idlechargeperiod
    if (t == 0 or t == 3 or t == 17 or t == 20) and inst._lastchargeframe ~= t then
        inst._lastchargeframe = t
        inst.SoundEmitter:PlaySound("dontstarve/common/together/spot_light/electricity", nil, GetRandomMinMax(.2, .5))
    end
end

local function StartIdleChargeSounds(inst)
    if inst._idlechargeperiod == nil then
        inst._idlechargeperiod = math.floor(inst.AnimState:GetCurrentAnimationLength() / FRAMES + .5)
        inst._lastchargeframe = nil
        inst.components.updatelooper:AddOnUpdateFn(DoIdleChargeSound)
    end
end

local function StopIdleChargeSounds(inst)
    if inst._idlechargeperiod ~= nil then
        inst._idlechargeperiod = nil
        inst._lastchargeframe = nil
        inst.components.updatelooper:RemoveOnUpdateFn(DoIdleChargeSound)
    end
end

--------------------------------------------------------------------------

local NUM_LEVELS = 6


local PERIOD = .5

local function DoAddBatteryPower(inst, node)
    node:AddBatteryPower(PERIOD + math.random(2, 6) * FRAMES)
end

local function OnBatteryTask(inst)
    inst.components.circuitnode:ForEachNode(DoAddBatteryPower)
end

local function StartBattery(inst)
    if inst._batterytask == nil then
        inst._batterytask = inst:DoPeriodicTask(PERIOD, OnBatteryTask, 0)
    end
end

local function StopBattery(inst)
    if inst._batterytask ~= nil then
        inst._batterytask:Cancel()
        inst._batterytask = nil
    end
end

local function UpdateCircuitPower(inst)
    inst._circuittask = nil
    if inst.components.fueled ~= nil then
        if inst.components.fueled.consuming then
            local load = 0
            inst.components.circuitnode:ForEachNode(function(inst, node)
                local batteries = 0
                node.components.circuitnode:ForEachNode(function(node, battery)
                    if battery.components.fueled ~= nil and battery.components.fueled.consuming then
                        batteries = batteries + 1
                    end
                end)
                load = load + 1 / batteries
            end)
            inst.components.fueled.rate = math.max(load, TUNING.WINONA_BATTERY_MIN_LOAD)
        else
            inst.components.fueled.rate = 0
        end
    end
end

local function OnCircuitChanged(inst)
    if inst._circuittask == nil then
        inst._circuittask = inst:DoTaskInTime(0, UpdateCircuitPower)
    end
end

local function NotifyCircuitChanged(inst, node)
    node:PushEvent("engineeringcircuitchanged")
end

local function BroadcastCircuitChanged(inst)
    inst.components.circuitnode:ForEachNode(NotifyCircuitChanged)
    if inst._circuittask ~= nil then
        inst._circuittask:Cancel()
    end
    UpdateCircuitPower(inst)
end

local function OnConnectCircuit(inst)
    if inst.components.fueled ~= nil and inst.components.fueled.consuming then
        StartBattery(inst)
    end
    OnCircuitChanged(inst)
end

local function OnDisconnectCircuit(inst)
    if not inst.components.circuitnode:IsConnected() then
        StopBattery(inst)
    end
    OnCircuitChanged(inst)
end

--------------------------------------------------------------------------

local function UpdateSoundLoop(inst, level)
    if inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:SetParameter("loop", "intensity", 1 - level / NUM_LEVELS)
    end
end

local function StartSoundLoop(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/on_LP", "loop")
        UpdateSoundLoop(inst, inst.components.fueled:GetCurrentSection())
    end
end

local function StopSoundLoop(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnEntitySleep(inst)
    StopSoundLoop(inst)
    StopIdleChargeSounds(inst)
end

local function OnEntityWake(inst)
    if inst.components.fueled ~= nil and inst.components.fueled.consuming then
        StartSoundLoop(inst)
    end
    if inst.AnimState:IsCurrentAnimation("work") then
        StartIdleChargeSounds(inst)
    end
end

--------------------------------------------------------------------------

local function OnHitAnimOver(inst)
    inst:RemoveEventCallback("animover", OnHitAnimOver)
    if inst.AnimState:IsCurrentAnimation("hit") then
        if inst.components.fueled:IsEmpty() then
            inst.AnimState:PlayAnimation("idle")
            StopIdleChargeSounds(inst)
        else
            inst.AnimState:PlayAnimation("work", true)
            if not inst:IsAsleep() then
                StartIdleChargeSounds(inst)
            end
        end
    end
end

local function PlayHitAnim(inst)
    inst:RemoveEventCallback("animover", OnHitAnimOver)
    inst:ListenForEvent("animover", OnHitAnimOver)
    inst.AnimState:PlayAnimation("hit")
    StopIdleChargeSounds(inst)
end

local function OnWorked(inst)
    if not inst:HasTag("NOCLICK") then
        PlayHitAnim(inst)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
end

local function OnWorkFinished(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end



local function OnFuelEmpty(inst)
    inst.components.fueled:StopConsuming()
    BroadcastCircuitChanged(inst)
    StopBattery(inst)
    StopSoundLoop(inst)

    if inst.AnimState:IsCurrentAnimation("work") then
        inst.AnimState:PlayAnimation("idle")
        StopIdleChargeSounds(inst)
    end
    if not POPULATING then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/down")
    end
end

local function OnFuelSectionChange(new, old, inst)
    UpdateSoundLoop(inst, new)
end

local function OnSave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") or nil
end

local function OnLoad(inst, data, ents)
    if data ~= nil then
		if not inst.components.fueled:IsEmpty() then
            if not inst.components.fueled.consuming then
                inst.components.fueled:StartConsuming()
                BroadcastCircuitChanged(inst)
            end
            inst.AnimState:PlayAnimation("work", true)
            if not inst:IsAsleep() then
                StartIdleChargeSounds(inst)
            end
            inst.AnimState:SetTime(inst.AnimState:GetCurrentAnimationLength() * math.random())
        end
    end
end

local function OnInit(inst)
    inst._inittask = nil
    inst.components.circuitnode:ConnectTo("engineering")
end

local function OnLoadPostPass(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        OnInit(inst)
    end
end

--------------------------------------------------------------------------

local function OnBuilt3(inst)
    inst:RemoveEventCallback("animover", OnBuilt3)
    if inst.AnimState:IsCurrentAnimation("place") then
        inst:RemoveTag("NOCLICK")
    end
end

local function OnBuilt2(inst)
    if inst.AnimState:IsCurrentAnimation("place") then
        inst.components.circuitnode:ConnectTo("engineering")
    end
end

local function OnBuilt(inst)--, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst.components.circuitnode:Disconnect()
    inst:ListenForEvent("animover", OnBuilt3)
    inst.AnimState:PlayAnimation("place")
    StopIdleChargeSounds(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/place_2")
    inst:AddTag("NOCLICK")
    inst:DoTaskInTime(60 * FRAMES, OnBuilt2)
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

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        if inst.helper == nil and inst:HasTag("HAMMER_workable") and not inst:HasTag("burnt") then
            inst.helper = CreateEntity()

            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.AnimState:SetBank("winona_battery_placement")
            inst.helper.AnimState:SetBuild("winona_battery_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

            inst.helper.entity:SetParent(inst.entity)

            if placerinst ~= nil and recipename ~= "solar_panel_low" and recipename ~= "winona_battery_low" and recipename ~= "winona_battery_high" then
                inst.helper:AddComponent("updatelooper")
                inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
                inst.helper.placerinst = placerinst
                OnUpdatePlacerHelper(inst.helper)
            end
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnIsDay(inst, isday)
    if isday then
		inst:DoTaskInTime(2, function()
			local delta = inst.components.fueled.maxfuel / .000001
			if inst.components.fueled:IsEmpty() then
				--prevent battery level flicker by subtracting a tiny bit from initial fuel
				delta = delta - .000001
			else
				local final = inst.components.fueled.currentfuel + delta
				local amtpergem = inst.components.fueled.maxfuel / .000001
				local curgemamt = final - math.floor(final / amtpergem) * amtpergem
				if curgemamt < 3 then
					--prevent new gem from shattering within 3 seconds of socketing
					delta = delta + 3 - curgemamt
				end
			end
			inst.components.fueled:DoDelta(delta)

			if not inst.components.fueled.consuming then
				inst.components.fueled:StartConsuming()
				BroadcastCircuitChanged(inst)
				if inst.components.circuitnode:IsConnected() then
					StartBattery(inst)
				end
				if not inst:IsAsleep() then
					StartSoundLoop(inst)
				end
			end

			PlayHitAnim(inst)
			inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
		end)
    else
		OnFuelEmpty(inst)
    end
end
local function OnInit2(inst)
    inst:WatchWorldState("isday", OnIsDay)
    OnIsDay(inst, TheWorld.state.isday)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .8)

    inst:AddTag("structure")
    inst:AddTag("engineeringbattery")

    inst.AnimState:SetBank("solar_panel")
    inst.AnimState:SetBuild("solar_panel")
    inst.AnimState:PlayAnimation("idle")

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper:AddRecipeFilter("winona_spotlight")
        inst.components.deployhelper:AddRecipeFilter("winona_catapult")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_low")
        inst.components.deployhelper:AddRecipeFilter("winona_battery_high")
        inst.components.deployhelper:AddRecipeFilter("solar_panel_low")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:DoTaskInTime(0, OnInit2)

    inst:AddComponent("updatelooper")

    inst:AddComponent("inspectable")

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetSections(NUM_LEVELS)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
    inst.components.fueled.maxfuel = TUNING.WINONA_BATTERY_HIGH_MAX_FUEL_TIME
    inst.components.fueled.fueltype = FUELTYPE.MAGIC

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

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst._batterytask = nil
    inst._inittask = inst:DoTaskInTime(0, OnInit)
    UpdateCircuitPower(inst)

    return inst
end

--------------------------------------------------------------------------

local function placer_postinit_fn(inst)

    local placer2 = CreateEntity()

    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    placer2.AnimState:SetBank("solar_panel")
    placer2.AnimState:SetBuild("solar_panel")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)

    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
end

--------------------------------------------------------------------------

return Prefab("solar_panel_low", fn, assets, prefabs),
    MakePlacer("solar_panel_low_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, nil, nil, nil, placer_postinit_fn)