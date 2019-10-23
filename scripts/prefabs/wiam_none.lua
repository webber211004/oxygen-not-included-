local assets =
{
	Asset( "ANIM", "anim/wiam.zip" ),
	Asset( "ANIM", "anim/ghost_wiam_build.zip" ),
}

local skins =
{
	normal_skin = "wiam",
	ghost_skin = "ghost_wiam_build",
}

return CreatePrefabSkin("wiam_none",
{
	base_prefab = "wiam",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"WIAM", "CHARACTER", "BASE"},
	build_name = "wiam",
	build_name_override = "wiam",
	rarity = "Character",
})
