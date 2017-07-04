
GM.WaitTime = 60
GM.MinPlayers = 2
GM.SpawnDelay = {
	[TEAM_SURVIVOR] = 15,
	[TEAM_ANTLION] = 3
}

GM.GameManager = NULL

GM.CurrentCheckpoint = 0
GM.NumPlayersFinished = 0
GM.Checkpoints = {}

GM.Waiting = false
GM.PreStart = false 
GM.InProgress = false 
GM.GameOver = false

-- Sets up map entities.
function GM:SetupMap()
	GAMEMODE.GameManager = ents.FindByClass( "info_gamemanager" )[1]
	local tCheckpoints = ents.FindByClass( "trigger_checkpoint" )
	for i = 1, #tCheckpoints do
		GAMEMODE.Checkpoints[ tCheckpoints[i].CheckpointID ] = tCheckpoints[i]
	end
	if( not ValidEntity( GAMEMODE.GameManager ) ) then
		print( "WARNING: No game manager entity present" )
	end
end

function GM:GameManagerInput( sOutput, activator, inflictor, vParam )
	if( not ValidEntity( GAMEMODE.GameManager ) ) then return end
	GAMEMODE.GameManager:Input( sOutput, activator, inflictor, vParam )
end

function GM:GameManagerOutput( sOutput, activator )
	if( not ValidEntity( GAMEMODE.GameManager ) ) then return end
	GAMEMODE.GameManager:TriggerOutput( sOutput, activator or GetWorldEntity() )
end

-- Called to tell the game to wait for players.
function GM:StartWaiting()
	GAMEMODE.Waiting = true
	GAMEMODE.StopWaitTime = CurTime() + GAMEMODE.WaitTime
	GAMEMODE:GameManagerOutput( "OnStartWaiting" )
end

-- Called to force the game to stop waiting, allowing the game to start.
function GM:StopWaiting()
	GAMEMODE.Waiting = false
	GAMEMODE.PreStart = true
	GAMEMODE:GameManagerOutput( "OnStopWaiting" )
	gamemode.Call( "OnGamePreStart" )
end

-- Called to force the game to start.
function GM:StartGame()
	GAMEMODE.PreStart = false
	GAMEMODE.InProgress = true
	GAMEMODE:GameManagerOutput( "OnGameStart" )
	gamemode.Call( "OnGameStart" )
end

-- Called to force the game to end with the iResult team as the winner.
function GM:EndGame( iResult )
	GAMEMODE.InProgress = false
	GAMEMODE.GameOver = true
	GAMEMODE:GameManagerOutput( "OnGameOver" )
	gamemode.Call( "OnGameOver", iResult )
end

-- Called to see if the game should end or not.
function GM:CheckEndGame()
	local tLivingSurvivors = GAMEMODE:GetAlivePlayers( TEAM_SURVIVOR )
	local fRatioDead = #tLivingSurvivors / #team.GetPlayers( TEAM_SURVIVOR )
	local fRatioFinished = GAMEMODE.NumPlayersFinished / #tLivingSurvivors
	if( fRatioDead == 1 ) then
		GAMEMODE:EndGame( TEAM_ANTLION )
	elseif( fRatioFinished == 1 ) then
		GAMEMODE:EndGame( TEAM_SURVIVOR )
	end
end

-- Gets the total number of checkpoints.
function GM:GetNumCheckpoints()
	return #GAMEMODE.Checkpoints
end

-- Returns the current checkpoint.
function GM:GetCurrentCheckpoint()
	return GAMEMODE.CurrentCheckpoint
end

-- Called when a player enters the final checkpoint.
function GM:PlayerEnterFinish( ply )
	GAMEMODE.NumPlayersFinished = GAMEMODE.NumPlayersFinished + 1
	timer.Simple( 5, GAMEMODE.CheckEndGame, GAMEMODE )
	gamemode.Call( "OnPlayerEnterFinish", ply )
end

-- Called when a player leaves the final checkpoint.
function GM:PlayerLeaveFinish( ply )
	GAMEMODE.NumPlayersFinished = GAMEMODE.NumPlayersFinished - 1
	gamemode.Call( "OnPlayerLeaveFinish", ply )
end

-- Called when a player enters/exits a checkpoint.
function GM:PlayerCheckpoint( ply, iCheckpoint, bEndTouch )
	if( iCheckpoint == 1 and not bEndTouch) then
		GAMEMODE:StartGame()
		return
	elseif( iCheckpoint == GAMEMODE:GetNumCheckpoints() ) then
		if( bEndTouch ) then
			GAMEMODE:PlayerLeaveFinish( ply )
		else
			GAMEMODE:PlayerEnterFinish( ply )
		end
		return
	end
	if( not bEndTouch ) then
		GAMEMODE.CurrentCheckpoint = iCheckpoint
		gamemode.Call( "OnCheckpointPassed", iCheckpoint )
	end
end
