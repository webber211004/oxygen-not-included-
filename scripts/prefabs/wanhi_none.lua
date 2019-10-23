local assets =
{
	Asset( "ANIM", "anim/wanhi.zip" ),
	Asset( "ANIM", "anim/ghost_wiam_build.zip" ),
}

local skins =
{
	normal_skin = "wanhi",
	ghost_skin = "ghost_wiam_build",
}

return CreatePrefabSkin("wanhi_none",
{
	base_prefab = "wanhi",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"WANHI", "CHARACTER", "BASE"},
	build_name = "wanhi",
	build_name_override = "wanhi",
	rarity = "Character",
})
