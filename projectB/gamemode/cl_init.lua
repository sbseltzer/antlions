
include( 'shared.lua' ) -- Our obligatory shared.lua file.
include( 'config.lua' ) -- Narwhal configurations.
include( 'lib_ext.lua' ) -- Miscellaneous library extensions (team, util, ents, etc.)
include( 'enum.lua' ) -- Hitbox enumerations for the player skeleton and antlion skeletons.
include( 'cl_player_events.lua' ) -- Handles client player hooks.
include( 'cl_hud.lua' ) -- Handles client player hooks.
include( 'antlion_animations.lua' ) -- Overrides Narwhal's animations system for antlions (in part).
include( 'sh_player_events.lua' ) -- Handles shared player hooks.
include( 'sh_player_methods.lua' ) -- Handles shared player methods.
include( 'sh_entities.lua' ) -- Handles all gameplay related entities. Spawns, logic, etc.
include( 'sh_gamestatus.lua' ) -- Handles our global game status enums and server list gamemode display.

local function UMSG_SandMats( um )
	local mats = string.Explode( " ", um:ReadString() )
	for k, v in pairs( mats ) do
		mats[k] = _E[v]
	end
	GAMEMODE.SandMats = mats
end
usermessage.Hook( "SendSandMats", UMSG_SandMats )

local function UMSG_AntlionModel( um )
	local ply, mdl, skin = um:ReadEntity(), um:ReadString(), um:ReadShort()
	print("recieved:", ply, mdl, skin)
	if !ply.AntlionModel then
		GAMEMODE:CreateAntlionModel( ply, mdl, skin )
	else
		GAMEMODE:AdjustAntlionModel( ply, mdl, skin )
	end
end
usermessage.Hook( "UpdateAntlionModel", UMSG_AntlionModel )

local function UMSG_AntlionModelRemove( um )
	GAMEMODE:RemoveAntlionModel( um:ReadEntity() )
end
usermessage.Hook( "RemoveAntlionModel", UMSG_AntlionModelRemove )

local function UMSG_UpdateRagdollProperties( um )
	local ply = um:ReadEntity()
	print( "Preparing to update ragdoll properties for ", ply )
	if !ply then return end
	local ragdoll = ply:GetRagdollEntity()
	print( "Preparing to update ragdoll", ragdoll )
	if !ragdoll then return end
	print( ply:GetSkin(), ragdoll:GetSkin() )
	ragdoll:SetSkin( ply:GetSkin() )
	print( ply:GetSkin(), ragdoll:GetSkin() )
	--ragdoll:SetBloodColor( ply:GetBloodColor() )
end
usermessage.Hook( "UpdateRagdollProperties", UMSG_UpdateRagdollProperties )