local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_sneeze.zip"),
}
local prefabs = {	"trinket_6" }

local start_inv = {
	"trinket_6",
	"trinket_6",
	"trinket_6",
}



local function onload(inst)

end


local common_postinit = function(inst) 
	inst:AddTag("ONIeater")
	inst.MiniMapEntity:SetIcon( "wanhi.tex" )
end

local master_postinit = function(inst)
	inst.soundsname = "willow"

    inst.customidleanim = "lightsneeze"

    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.OMNI, FOODTYPE.MEAT, FOODTYPE.GOODIES }, {})
    end
	
	inst.components.health:SetMaxHealth(100)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(125)
	
    inst.components.combat.damagemultiplier = 1
	
	inst.components.hunger.hungerrate = 1.2 * TUNING.WILSON_HUNGER_RATE
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
end

return MakePlayerCharacter("wanhi", prefabs, assets, common_postinit, master_postinit, start_inv)
