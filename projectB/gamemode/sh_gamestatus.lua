


GAME_STATUS_PREGAME = 0 -- Before players have joined
GAME_STATUS_WAITFORPLAYERS = 1 -- Waiting for players to spawn
GAME_STATUS_WAITFORSTART = 2 -- Before gameplay has started, but after the pregame timer has ended.
GAME_STATUS_INPROGRESS = 3 -- Gameplay is in progress.
GAME_STATUS_INBATTLE = 4 -- Gameplay is in progress, and it's a battle.
GAME_STATUS_GAMEOVER = 5 -- Gameplay has ended.
GAME_STATUS_RESTARTING = 6 -- Gameplay has ended.

GAME_TYPE_CAMPAIGN = 0
GAME_TYPE_SURVIVAL = 1
GAME_TYPE_SCAVENGE = 2
GAME_TYPE_EXTRACTION = 3

GM.GameTypeCVar = CreateConVar( "gm_antlion_mode", GAME_TYPE_CAMPAIGN,  FCVAR_REPLICATED|FCVAR_ARCHIVE )
GM.ThumperShakeCVar = CreateConVar( "gm_antlion_thumpershakescale", GM.ThumperShakeScale,  FCVAR_REPLICATED|FCVAR_ARCHIVE )

local GameTypeTranslation = {}
GameTypeTranslation[GAME_TYPE_CAMPAIGN] = "Campaign"
GameTypeTranslation[GAME_TYPE_SURVIVAL] = "Survival"
GameTypeTranslation[GAME_TYPE_SCAVENGE] = "Scavenge"
GameTypeTranslation[GAME_TYPE_EXTRACTION] = "Extraction"

local GameStatusTranslation = {}
GameStatusTranslation[GAME_STATUS_PREGAME] = "No Players"
GameStatusTranslation[GAME_STATUS_WAITFORSTART] = "Starting..."
GameStatusTranslation[GAME_STATUS_INPROGRESS] = "In Progress"
GameStatusTranslation[GAME_STATUS_GAMEOVER] = "Game Over"

local function GetStatusTranslation( enum )

	GameStatusTranslation[GAME_STATUS_WAITFORPLAYERS] = "Waiting for Players ("..string.ToMinutesSeconds(GetGlobalInt( "WaitForPlayersTimer", 0 ))..")"
	GameStatusTranslation[GAME_STATUS_INBATTLE] = "In Battle"..(GAMEMODE:GetCurrentBattle() and " ("..string.ToMinutesSeconds(GetGlobalInt( "BattleTimer_"..GAMEMODE:GetCurrentBattle():EntIndex(), 0 ))..")")
	GameStatusTranslation[GAME_STATUS_GAMEOVER] = GetGlobalString( "VICTORY_STATUS", "No Winner" )..( !GAMEMODE.IsLastRound and " - Restarting in ("..string.ToMinutesSeconds(GetGlobalInt( "RestartTimer", 0 ))..")" )
	GameStatusTranslation[GAME_STATUS_RESTARTING] = "Restarting in ("..string.ToMinutesSeconds(GetGlobalInt( "RestartTimer", 0 ))..")"
	
	return GameStatusTranslation[enum]
	
end

/*------------------------------------
	GetGameType
------------------------------------*/
function GM:GetGameType()

	return GetGlobalInt( "GetGameType", ( SERVER and GAMEMODE.GameTypeCVar:GetInt() ) or GAME_TYPE_CAMPAIGN )
	
end

/*------------------------------------
	SetGameType
------------------------------------*/
function GM:SetGameType( enum )

	SetGlobalInt( "GetGameType", enum )
	
	if !SERVER then return end
	
	RunConsoleCommand( "gm_antlion_mode", enum )
	
end

/*------------------------------------
	GetGameStatus
------------------------------------*/
function GM:GetGameStatus()

	return GetGlobalInt("GetGameStatus", GAME_STATUS_PREGAME)
	
end

/*------------------------------------
	SetGameStatus
------------------------------------*/
function GM:SetGameStatus( enum )

	print("Setting game status to "..enum)
	SetGlobalInt("GetGameStatus", enum)
	
end

/*------------------------------------
	CurrentBattle
------------------------------------*/
function GM:GetCurrentBattle( ply )
	
	if !ply then return GetGlobalEntity( "CurrentBattle", NULL ) end
	
	return ply:GetNWEntity( "CurrentBattle", NULL )
	
end

/*------------------------------------
	SetCurrentBattle
------------------------------------*/
function GM:SetCurrentBattle( ply, ent )
	
	if !ent then
		SetGlobalEntity( "CurrentBattle", ply )
	else
		ply:SetNWEntity( "CurrentBattle", ent )
	end
	
end

/*------------------------------------
	GetGameDescription
------------------------------------*/
function GM:GetGameDescription()

	return "Antlion "..GameTypeTranslation[GAMEMODE:GetGameType()]..": "..GetStatusTranslation( GAMEMODE:GetGameStatus() )
	
end



