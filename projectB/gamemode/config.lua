
/*---------------------------------------------------------

	Developer's Notes:
	
	Configurations for the entire gamemode.
	This file is still under construction.

---------------------------------------------------------*/


// Feature toggling
NARWHAL.Config["UseModules"]				= true	-- Toggle Module Loading.
NARWHAL.Config["UseThemes"]					= true	-- Toggle Theme Loading
NARWHAL.Config["UseAnims"]					= true	-- Toggle the player NPC animations.
NARWHAL.Config["UseMySQL"]					= false	-- Toggle MySQL Interfaces.
NARWHAL.Config["UseCurrency"]				= false	-- Toggle the money system.
NARWHAL.Config["UseStore"]					= false	-- Toggle the gobal store platform.
NARWHAL.Config["UseAchievements"] 			= false	-- Toggle the achievements system.


// Use this to set antlion related vars.
if !SERVER then return end

--NARWHAL.Config.Commands = { sk_antlion_health = 100, sk_antlion_jump_damage = 5, sk_antlion_swipe_damage = 15, sk_antlion_air_attack_dmg = 30 }











