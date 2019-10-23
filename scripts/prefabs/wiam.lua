local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_sneeze.zip"),
}
local prefabs = {	"wiam_goggles" }

local start_inv = {
	"wiam_goggles"
}


local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wiam_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wiam_speed_mod")
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end


local common_postinit = function(inst) 
	inst:AddTag("ONIeater")
	inst.MiniMapEntity:SetIcon( "wiam.tex" )
end

local master_postinit = function(inst)
	inst.soundsname = "wilson"

    inst.customidleanim = "lightsneeze"

    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.OMNI, FOODTYPE.MEAT, FOODTYPE.GOODIES }, {})
    end
	
	inst.components.health:SetMaxHealth(125)
	inst.components.hunger:SetMax(75)
	inst.components.sanity:SetMax(200)
	
    inst.components.combat.damagemultiplier = 1
	
	inst.components.hunger.hungerrate = 1.2 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("wiam", prefabs, assets, common_postinit, master_postinit, start_inv)
