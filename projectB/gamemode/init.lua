
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "config.lua" )
AddCSLuaFile( "lib_ext.lua" )
AddCSLuaFile( "enum.lua" )
AddCSLuaFile( "cl_player_events.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "sh_player_methods.lua" )
AddCSLuaFile( "sh_player_events.lua" )
AddCSLuaFile( "antlion_animations.lua" )
AddCSLuaFile( "sh_gamestatus.lua" )
AddCSLuaFile( "sh_entities.lua" )

include( 'shared.lua' ) -- The obligatory shared.lua file.
include( 'config.lua' ) -- Narwhal configurations.
include( 'lib_ext.lua' ) -- Miscellaneous library extensions (team, util, ents, etc.)
include( 'enum.lua' ) -- Hitbox enumerations for the player skeleton and antlion skeletons.
include( 'sh_entities.lua' ) -- Handles all gameplay related entities. Spawns, logic, etc.
include( 'gametype_campaign.lua' ) -- Handles gameplay logic for the gamepaign game type.
include( 'sv_player_events.lua' ) -- Handles serverside player hooks.
include( 'sv_player_methods.lua' ) -- Handles serverside player methods.
include( 'sh_player_events.lua' ) -- Handles shared player hooks.
include( 'sh_player_methods.lua' ) -- Handles shared player methods.
include( 'sh_gamestatus.lua' ) -- Handles our global game status enums and server list gamemode display.
include( 'antlion_animations.lua' ) -- Overrides Narwhal's animations system for antlions (in part).
include( 'player_spawning.lua' ) -- Handles player spawning, team requests, etc.
include( 'player_death.lua' ) -- Handles player death, damage, etc.
