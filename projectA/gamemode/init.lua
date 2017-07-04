AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "player_meta.lua" )
AddCSLuaFile( "entity_meta.lua" )
--AddCSLuaFile( "sh_hooks.lua" )

include( "shared.lua" )
include( "player.lua" )
include( "sv_hooks.lua" )

function GM:InitPostEntity()  
	GAMEMODE:SetupMap()
end

function GM:GetGameDescription() 
	return "Antlion Survival" 
end