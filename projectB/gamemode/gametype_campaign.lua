
// ply = player who hit trigger
// trigger = trigger entity

local GAMEEVENT = "GAME EVENT:"


// Called when there are no players.
function GM:OnPreGame( activator, ent )

	print(GAMEEVENT,"Starting Pre-Game")
	
	GAMEMODE:SetGameStatus( GAME_STATUS_PREGAME )
	
end

// Called when the game starts waiting for players
function GM:OnWaitForPlayers( activator, ent )

	print("Waiting for players")
	
	GAMEMODE:SetGameStatus( GAME_STATUS_WAITFORPLAYERS )
	
	local time = 0
	
	timer.Create( "WaitTimer", 1, GAMEMODE.PreGameTime, function()
	
		if !player.GetAll()[1] then -- shit... no players.
		
			timer.Remove( "WaitTimer" )
			
			GAMEMODE:SetGameStatus( GAME_STATUS_PREGAME )
			time = GAMEMODE.PreGameTime
			
			return
			
		end
		
		time = time + 1
		
		SetGlobalInt( "WaitForPlayersTimer", GAMEMODE.PreGameTime - time )
		
		if time == GAMEMODE.PreGameTime then
		
			GAME_EVENTS:Fire( "WaitForStart" )
			
			return
			
		end
		
	end )
	
end

// Called when the game stops waiting for players and allows rebels to start the game
function GM:OnWaitForStart( activator, ent )

	print(GAMEEVENT,"Waiting for start")
	
	GAMEMODE:SetGameStatus( GAME_STATUS_WAITFORSTART )
	
	if timer.IsTimer( "WaitTimer" ) then
	
		timer.Remove( "WaitTimer" )
		
	end
	
end

// Called when the game start is triggered
function GM:OnStartGame( activator, ent )

	print(GAMEEVENT,"Game has started")
	
	GAMEMODE:SetGameStatus( GAME_STATUS_INPROGRESS )
	
	timer.Create("CheckForRebelsDead", 1, 0, gamemode.Call, "CheckGameEnd" )
	
end

function GM:CheckGameEnd()
	
	if #team.GetPlayers( TEAM_REBEL ) >= 1 and #team.GetPlayers( TEAM_ANTLION ) >= 1 and table.Count( team.GetAlivePlayers( TEAM_REBEL ) ) == 0 then
	
		GAME_EVENTS:Fire( "EndGame", TEAM_ANTLION )
		
	end
	
end

// Called when the game end is triggered
function GM:OnEndGame( activator, ent )

	print(GAMEEVENT,"Game has ended")
	
	GAMEMODE:SetGameStatus( GAME_STATUS_GAMEOVER )
	
	local function BeginRestartTimer()
	
		local time = 0
		
		timer.Create( "RestartTimer", 1, GAMEMODE.RestartDelay, function()
		
			if !player.GetAll()[1] then -- shit... no players.
			
				timer.Remove( "RestartTimer" )
				
				GAMEMODE:SetGameStatus( GAME_STATUS_PREGAME )
				GAME_EVENTS:Fire( "RestartGame" )
				
				return
				
			end
			
			time = time + 1
			
			SetGlobalInt( "RestartTimer", GAMEMODE.RestartDelay - time )
			
			if time >= GAMEMODE.RestartDelay - (GAMEMODE.RestartDelay/3) and GAMEMODE:GetGameStatus() != GAME_STATUS_RESTARTING then
			
				GAMEMODE:SetGameStatus( GAME_STATUS_RESTARTING )
				
			elseif time == GAMEMODE.RestartDelay then
			
				GAME_EVENTS:Fire( "RestartGame" )
				
			end
			
		end )
		
	end
	
	BeginRestartTimer()
	
	for k, v in pairs( player.GetAll() ) do
	
		v:ConCommand("antlion_showresults") -- display results
		
	end
	
end

// Called to restart the game and flip teams
function GM:OnRestartGame()

	print(GAMEEVENT,"Game restarted")
	
	game.CleanUpMap( false, NO_CLEANUP_ENTS )
	team.FlipPlayers( TEAM_REBEL, TEAM_ANTLION, TEAM_ANTLION, true )
	
	GAME_EVENTS:Fire( "WaitForStart" )
	GAMEMODE:ResetMapEntities()
	
end

// Called when a battle start is triggered
function GM:OnStartBattle( activator, ent )

	print(GAMEEVENT,"Battle has started")
	
	GAMEMODE:SetCurrentBattle( ent )
	GAMEMODE:SetGameStatus( GAME_STATUS_INBATTLE )
	
	for k, v in pairs( ANTLION_BATTLE_SPAWNS[ent] ) do
	
		v:Fire("Enable")
		
	end
	
	local MODE_TIMER, MODE_TRIGGER, MODE_EITHER_AND, MODE_EITHER_OR = 0, 1, 2, 3
	local time = 0
	
	if ent.Mode == MODE_TIMER then
	
		timer.Create( "BattleTimer_"..ent:EntIndex(), 1, ent.TimeLimit, function()
		
			time = time + 1
			
			SetGlobalInt( "BattleTimer_"..ent:EntIndex(), ent.TimeLimit - time )
			
			if time == ent.TimeLimit then
			
				ent:Fire( "EndBattle" )
				GAME_EVENTS:Fire( "EndBattle", ent.targetname )
				
			end
			
		end )
		
	elseif ent.Mode == MODE_TRIGGER then
	
		--?
		
	elseif ent.Mode == MODE_EITHER_AND then
	
		timer.Create( "BattleTimer_"..ent:EntIndex(), 1, ent.TimeLimit, function()
		
			time = time + 1
			
			SetGlobalInt( "BattleTimer_"..ent:EntIndex(), time )
			
			if time == ent.TimeLimit then
			
				ent:Fire( "EndBattle" )
				GAME_EVENTS:Fire( "EndBattle", ent.targetname )
				
			end
			
		end )
		
	elseif ent.Mode == MODE_EITHER_OR then
	
		timer.Create( "BattleTimer_"..ent:EntIndex(), 1, ent.TimeLimit, function()
		
			time = time + 1
			
			SetGlobalInt( "BattleTimer_"..ent:EntIndex(), time )
			
			if time == ent.TimeLimit then
			
				ent:Fire( "EndBattle" )
				GAME_EVENTS:Fire( "EndBattle", ent.targetname )
				
			end
			
		end )
		
	end
	
end

function GM:PlayerCheckBattleEnd( ply, battle, iType )
	
	
	
end

// Called when a battle end is triggered
function GM:OnEndBattle( activator, ent )

	print(GAMEEVENT,"Game has ended")
	
	GAMEMODE:SetGameStatus( GAME_STATUS_INPROGRESS )
	GAMEMODE:SetCurrentBattle( NULL )
	
	if timer.IsTimer( "BattleTimer_"..ent:EntIndex() ) then
	
		timer.Remove( "BattleTimer_"..ent:EntIndex() )
		
	end
	
end

function GM:OnEnterBattleZone( ply, battle )


end

// Called when a guard is released
function GM:OnReleaseAntlionGuard( activator, ent )

	print(GAMEEVENT,"Antlion Guard released")
	
	timer.Simple( 5, function()
	
		local ply = table.Random( team.GetPlayers( TEAM_ANTLION ) )
		ply:MakeAntlionGuard( true )
		ply:KillSilent()
		ply:Spawn()
		
	end )
	
end

// Called when a guard is defeated
function GM:OnAntlionGuardDefeated( activator, ent )

	print(GAMEEVENT,"Antlion Guard defeated")
	
end

// Called when a guardian is released
function GM:OnReleaseAntlionGuardian( activator, ent )

	print(GAMEEVENT,"Antlion Guardian released")
	
	timer.Simple( 5, function()
		
		local ply = table.Random( team.GetPlayers( TEAM_ANTLION ) )
		ply:MakeAntlionGuardian()
		ply:KillSilent()
		ply:Spawn()
		
	end )
	
end

// Called when a guardian is defeated
function GM:OnAntlionGuardianDefeated( activator, ent )

	print(GAMEEVENT,"Antlion Guardian defeated")
	
end




