PrefabFiles = {
	"wiam",
	"wiam_none",
	"light_bug",
	"wanhi",
	"wanhi_none",
	"blue_suit",
	"green_suit",
	"red_suit",
	"yellow_suit",
	"spaceheater",
	"microbemusher",
	"mushbar",
	"solar_panel_low",
	"trash_remover",
	"wiam_goggles",
	"hats_oni",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/wiam.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wiam.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wiam.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wiam.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/wiam_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wiam_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wiam.tex" ),
    Asset( "ATLAS", "bigportraits/wiam.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wiam.tex" ),
	Asset( "ATLAS", "images/map_icons/wiam.xml" ),

    Asset( "IMAGE", "bigportraits/wanhi.tex" ),
    Asset( "ATLAS", "bigportraits/wanhi.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wanhi.tex" ),
	Asset( "ATLAS", "images/map_icons/wanhi.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_wiam.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_wiam.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_wiam.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_wiam.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_wiam.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_wiam.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_wanhi.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_wanhi.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_wanhi.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_wanhi.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_wanhi.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_wanhi.xml" ),
	
	
	Asset( "IMAGE", "images/names_wiam.tex" ),
    Asset( "ATLAS", "images/names_wiam.xml" ),
	
	Asset( "IMAGE", "images/names_gold_wiam.tex" ),
    Asset( "ATLAS", "images/names_gold_wiam.xml" ),

	Asset( "IMAGE", "images/names_gold_wanhi.tex" ),
    Asset( "ATLAS", "images/names_gold_wanhi.xml" ),
	
	Asset( "IMAGE", "images/wiam_goggles.tex" ),
    Asset( "ATLAS", "images/wiam_goggles.xml" ),
	
	Asset( "IMAGE", "images/blue_suit.tex" ),
    Asset( "ATLAS", "images/blue_suit.xml" ),

	Asset( "IMAGE", "images/green_suit.tex" ),
    Asset( "ATLAS", "images/green_suit.xml" ),

	Asset( "IMAGE", "images/yellow_suit.tex" ),
    Asset( "ATLAS", "images/yellow_suit.xml" ),

	Asset( "IMAGE", "images/red_suit.tex" ),
    Asset( "ATLAS", "images/red_suit.xml" ),

	
	Asset( "IMAGE", "images/oni_tab.tex" ),
    Asset( "ATLAS", "images/oni_tab.xml" ),
	
    Asset( "IMAGE", "bigportraits/wiam_none.tex" ),
    Asset( "ATLAS", "bigportraits/wiam_none.xml" ),

    Asset( "IMAGE", "bigportraits/wanhi_none.tex" ),
    Asset( "ATLAS", "bigportraits/wanhi_none.xml" ),
	
	--Asset("SOUNDPACKAGE", "sound/wiam.fev"),
    --Asset("SOUND", "sound/wiam.fsb"),
}
--[[
RemapSoundEvent( "dontstarve/characters/wiam/death_voice", "wiam/characters/wiam/death_voice" )
RemapSoundEvent( "dontstarve/characters/wiam/hurt", "wiam/characters/wiam/hurt" )
RemapSoundEvent( "dontstarve/characters/wiam/talk_LP", "wiam/characters/wiam/talk_LP" )
RemapSoundEvent( "dontstarve/characters/wiam/emote", "wiam/characters/wiam/emote" ) --dst
RemapSoundEvent( "dontstarve/characters/wiam/ghost_LP", "wiam/characters/wiam/ghost_LP" ) --dst
RemapSoundEvent( "dontstarve/characters/wiam/pose", "wiam/characters/wiam/pose" ) --dst
RemapSoundEvent( "dontstarve/characters/wiam/yawn", "wiam/characters/wiam/yawn" ) --dst
RemapSoundEvent( "dontstarve/characters/wiam/eye_rub_vo", "wiam/characters/wiam/eye_rub_vo" ) --dst
RemapSoundEvent( "dontstarve/characters/wiam/carol", "wiam/characters/wiam/carol" ) --dst
--]]
AddMinimapAtlas("images/map_icons/wiam.xml")
AddMinimapAtlas("images/map_icons/wanhi.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH

-- The character select screen lines
STRINGS.CHARACTER_TITLES.wiam = "Oxygen Not Included"
STRINGS.CHARACTER_NAMES.wiam = "Wiam"
STRINGS.CHARACTER_DESCRIPTIONS.wiam = "*Has Mycophobia \n*Has own goggles\n"
STRINGS.CHARACTER_QUOTES.wiam = "\"I will not get sick... by eating this?\""

STRINGS.CHARACTER_TITLES.wanhi = "Oxygen Not Included"
STRINGS.CHARACTER_NAMES.wanhi = "Wanhi"
STRINGS.CHARACTER_DESCRIPTIONS.wanhi = "*Has Mycophobia \n*Has own goggles\n"
STRINGS.CHARACTER_QUOTES.wanhi = "\"Don't click on this button!\""

-- Custom speech strings
STRINGS.CHARACTERS.WIAM = require "speech_wiam"
STRINGS.CHARACTERS.WANHI = require "speech_wanhi"

STRINGS.NAMES.WIAM = "Wiam"
STRINGS.NAMES.WIAM_NONE = "Default"
STRINGS.NAMES.WANHI = "Wanhi"
STRINGS.NAMES.WANHI_NONE = "Default"

GLOBAL.PREFAB_SKINS["wiam"] = {	"wiam_none"	}
GLOBAL.PREFAB_SKINS["wanhi"] = { "wanhi_none" }

AddModCharacter("wiam", "MALE")
AddModCharacter("wanhi", "FEMALE")

STRINGS.NAMES.WIAM_GOGGLES = "Wiam's Goggles"
STRINGS.NAMES.BLUE_SUIT = "Blue Suit"
STRINGS.NAMES.GREEN_SUIT = "Green Suit"
STRINGS.NAMES.RED_SUIT = "Red Suit"
STRINGS.NAMES.YELLOW_SUIT = "Yellow Suit"

STRINGS.RECIPE_DESC.WIAM_GOGGLES = "Wiam's Goggles"
STRINGS.RECIPE_DESC.BLUE_SUIT = "Blue Suit"
STRINGS.RECIPE_DESC.GREEN_SUIT = "Green Suit"
STRINGS.RECIPE_DESC.RED_SUIT = "Red Suit"
STRINGS.RECIPE_DESC.YELLOW_SUIT = "Yellow Suit"

local oni_tab = AddRecipeTab("Cosmic Tab", 5, "images/oni_tab.xml", "oni_tab.tex", "ONIeater")

local wiam_goggles_recipe = AddRecipe("wiam_goggles", {Ingredient("transistor", 1), Ingredient("pigskin", 1)}, oni_tab, TECH.NONE, nil, nil, nil, nil)
wiam_goggles_recipe.atlas = "images/wiam_goggles.xml"

local red_suit_recipe = AddRecipe("red_suit", {}, oni_tab, TECH.NONE, nil, nil, nil, nil)
red_suit_recipe.atlas = "images/red_suit.xml"

local yellow_suit_recipe = AddRecipe("yellow_suit", {}, oni_tab, TECH.NONE, nil, nil, nil, nil)
yellow_suit_recipe.atlas = "images/yellow_suit.xml"

local green_suit_recipe = AddRecipe("green_suit", {}, oni_tab, TECH.NONE, nil, nil, nil, nil)
green_suit_recipe.atlas = "images/green_suit.xml"

local blue_suit_recipe = AddRecipe("blue_suit", {}, oni_tab, TECH.NONE, nil, nil, nil, nil)
blue_suit_recipe.atlas = "images/blue_suit.xml"

local solar_panel_low_recipe = AddRecipe("solar_panel_low", {}, oni_tab, TECH.NONE, "solar_panel_low_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "ONIeater")
solar_panel_low_recipe.atlas = "images/blue_suit.xml"

local microbemusher_recipe = AddRecipe("microbemusher", {}, oni_tab, TECH.NONE, "microbemusher_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "ONIeater")
microbemusher_recipe.atlas = "images/blue_suit.xml"

local spaceheater_recipe = AddRecipe("spaceheater", {}, oni_tab, TECH.NONE, "spaceheater_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "ONIeater")
spaceheater_recipe.atlas = "images/blue_suit.xml"
