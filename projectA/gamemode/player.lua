local AnimTranslateTable = {}
AnimTranslateTable[ PLAYER_RELOAD ] 	= ACT_HL2MP_GESTURE_RELOAD
AnimTranslateTable[ PLAYER_JUMP ] 		= ACT_HL2MP_JUMP
AnimTranslateTable[ PLAYER_ATTACK1 ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK

/*---------------------------------------------------------
   Name: gamemode:SetPlayerAnimation( )
   Desc: Sets a player's animation
---------------------------------------------------------*/
function GM:SetPlayerAnimation( ply, anim )
	
	if( ply:IsSurvivor() ) then
		return self.BaseClass:SetPlayerAnimation( ply, anim )
	end
	
	local act = ACT_HL2MP_IDLE
	local Speed = ply:GetVelocity():Length()
	local OnGround = ply:OnGround()
	
	-- If it's in the translate table then just straight translate it
	if ( AnimTranslateTable[ anim ] != nil ) then
	
		act = AnimTranslateTable[ anim ]
		
	else
	
		if (Speed > 210) then
		
			act = ACT_HL2MP_RUN
			
		elseif (Speed > 0) then
		
			act = ACT_HL2MP_WALK
			
		end
	
	end
	
	// Attacking/Reloading is handled by the RestartGesture function
	if ( act == ACT_HL2MP_GESTURE_RANGE_ATTACK || 
		 act == ACT_HL2MP_GESTURE_RELOAD ) then

		ply:RestartGesture( ply:Weapon_TranslateActivity( act ) )
		
		// If this was an attack send the anim to the weapon model
		if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK) then
		
			ply:Weapon_SetActivity( ply:Weapon_TranslateActivity( ACT_RANGE_ATTACK1 ), 0 );
			
		end
		
		return
		
	end
	
	// Always play the jump anim if we're in the air
	if ( !OnGround ) then
		
		act = ACT_HL2MP_JUMP
	
	end
	
	// Ask the weapon to translate the animation and get the sequence
	// ( ACT_HL2MP_JUMP becomes ACT_HL2MP_JUMP_AR2 for example)
	local seq = ply:SelectWeightedSequence( ply:Weapon_TranslateActivity( act ) )
	
	// If the weapon didn't return a translated sequence just set 
	//	the activity directly.
	if (seq == -1) then 
	
		// Hack.. If we don't have a weapon and we're jumping we
		// use the SLAM animation (prevents the reference anim from showing)
		if (act == ACT_HL2MP_JUMP) then
	
			act = ACT_HL2MP_JUMP_SLAM
		
		end
	
		seq = ply:SelectWeightedSequence( act ) 
		
	end
	
	// Don't keep switching sequences if we're already playing the one we want.
	if (ply:GetSequence() == seq) then return end
	
	// Set and reset the sequence
	ply:SetPlaybackRate( 1.0 )
	ply:ResetSequence( seq )
	ply:SetCycle( 0 )

end

-- Spawn player as a survivor.
function GM:SpawnAsSurvivor( ply, bIsMedic )
	ply:SetTeam( TEAM_SURVIVOR )
	ply:SetMedic( bIsMedic != nil and bIsMedic or ply:IsMedic() )
	ply:Spawn()
end

-- Spawn player as an antlion.
function GM:SpawnAsAntlion( ply, iAntlionType )
	ply:SetTeam( TEAM_ANTLION )
	ply:SetAntlionType( iAntlionType or ply:GetAntlionType() )
	ply:Spawn()
end

-- PlayerInitialSpawn
function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	if( #player.GetHumans() == 1 ) then
		if( !GAMEMODE.Waiting and !GAMEMODE.PreStart ) then
			GAMEMODE:StartWaiting()
		end
	elseif( GAMEMODE.GameOver ) then
		GAMEMODE:PlayerSpawnAsSpectator( ply ) -- Doublecheck this
	elseif( GAMEMODE.InProgress ) then
		-- spawn at latest checkpoint
	else
		-- spawn at start
	end
end

-- PlayerSpawn
function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )
	if( ply:IsSurvivor() ) then
		GAMEMODE:SetPlayerSpeed( ply, 250, 480 )
		ply:SetCanZoom( true )
		ply:SetBloodColor( BLOOD_COLOR_RED )
		if( ply:IsMedic() ) then
			ply:SetModel( table.Random( MEDIC_MODELS ) )
		else
			ply:SetModel( table.Random( REBEL_MODELS ) )
		end
		ply:SendLua( "GAMEMODE:RemoveAntlionViewModel()" )
	elseif( ply:IsAntlion() ) then
		GAMEMODE:SetPlayerSpeed( ply, 450, 600 )
		ply:SetCanZoom( false )
		ply:EmitSound( "NPC_Antlion.Distracted" )
		ply:SetBloodColor( BLOOD_COLOR_ANTLION )
		ply:SetModel( "models/antlion.mdl" )
		ply:SetSkin( math.random( 0, 3 ) )
		ply:SendLua( "GAMEMODE:SpawnAntlionViewModel()" )
		--[[local iAntlionType = ply:GetAntlionType()
		-- Spawning as a normal antlion
		if( iAntlionType == ANTLION_NORMAL ) then
		-- Spawning as an antlion guard
		elseif( iAntlionType == ANTLION_GUARD ) then
			ply:SetBloodColor( BLOOD_COLOR_ANTLION )
			ply:SetModel( "models/antlion_guard.mdl" )
			ply:SetSkin( 0 )
		-- Spawning as an antlion worker
		elseif( iAntlionType == ANTLION_WORKER ) then
			ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )
			ply:SetModel( "models/antlion_worker.mdl" )
			ply:SetSkin( 0 )
		-- Spawning as an antlion guardian
		elseif( iAntlionType == ANTLION_GUARDIAN ) then
			ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )
			ply:SetModel( "models/antlion_guard.mdl" )
			ply:SetSkin( 1 )
		end]]
	end
end

function GM:PlayerLoadout( ply )
	if( ply:IsAntlion() ) then return end
	ply:Give( "weapon_smg1" )
	ply:Give( "weapon_crowbar" )
	ply:Give( "weapon_grenade" )
	ply:GiveAmmo( 100, "SMG1" )
end

function GM:PlayerSelectTeamSpawn( teamid, ply )
	local teamSpawns = team.GetSpawnPoints( teamid )
	local validSpawns = {}
	for i = 1, #teamSpawns do
		if( GAMEMODE:IsSpawnpointSuitable( ply, teamSpawns[i], false ) ) then
			table.insert( validSpawns, teamSpawns[i] )
		end
	end
	return table.Random( validSpawns )
end

function GM:IsSpawnpointSuitable( ply, spawn, bMakeSuitable )
	return spawn.Enabled and spawn.CheckpointID == GAMEMODE.CurrentCheckpoint and self.BaseClass:IsSpawnpointSuitable( ply, spawn, bMakeSuitable )
end

function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	if ( !ValidEntity( ent ) or !ent:IsPlayer() ) then
		return
	end
	
	if( ent:IsPlayer() and ent:IsAntlion() ) then
		if( CurTime() > ( ent.NextPainSound or 0 ) ) then
			ent.NextPainSound = CurTime() + 0.5
			ent:EmitSound( Sound( "NPC_Antlion.Pain" ) )
		end
		if( dmginfo:GetDamageType() == DMG_BULLET ) then
			ent:EmitSound( Sound( "FX_AntlionImpact.ShellImpact" ) )
		end
	elseif ply:IsRebel() then
		ent.NextPainSound = CurTime() + 0.5
		ent:EmitSound( Sound( "NPC_Citizen.Pain" ) )
	end

end

function GM:GetFallDamage( ply, fallSpeed )
	if ply:IsAntlion() then
		return 0
	else
		return self.BaseClass:GetFallDamage( ply, fallSpeed )
	end
end

function GM:OnPlayerHitGround( ply, bInWater, bOnFloater, fFallSpeed )
	if( bInWater or bOnFloater ) then return end
	local traceDown = util.QuickTrace( ply:GetPos() + vector_up, vector_up * -10, ply )
	if( traceDown.HitNonWorld and ValidEntity( traceDown.Entity ) ) then
		if( fFallSpeed > 500 ) then
			traceDown.Entity:Input( "Break", ply, ply )
		end
	end
end

function GM:PlayerDeathSound( ply )
	if ply:IsAntlion() then
		if ply:GetAntlionType() == ANTLION_GUARD or ply:GetAntlionType() == ANTLION_GUARDIAN then
			ply:EmitSound( "NPC_AntlionGuard.Die" )
		else
			ply:StopSound( "NPC_Antlion.WingsOpen" )
			ply:EmitSound( "NPC_Antlion.Pain" )
		end
	elseif ply:IsSurvivor() then
		ply:EmitSound( "NPC_Citizen.Die" )
	end
	return true
end

function GM:PlayerDeath( ply, inflictor, attacker )
	ply.NextSpawnTime = CurTime() + ( GAMEMODE.SpawnDelay[ply:Team()] or 0 )
	if( ply:IsSurvivor() ) then
		GAMEMODE:CheckEndGame()
	elseif ply:IsAntlion() then
		local rag = ply:GetRagdollEntity()
		rag:SetBloodColor( BLOOD_COLOR_ANTLION )
		rag:SetSkin( ply:GetSkin() )
		rag:SetOwner( ply )
		
		-- Apparently our ragdoll entity doesn't exist on the client quite yet... :|
		timer.Simple( 0.1, function()
			-- Gmod 13 compatibility
			if( net ) then
				net.Start( "UpdateRagdollProperties" )
					net.WriteEntity( ply )
				net.Send( player.GetAll() )
			else
				umsg.Start( "UpdateRagdollProperties", player.GetAll() )
					umsg.Entity( ply )
				umsg.End()
			end
		end )
	end
end

function GM:PlayerDeathThink( ply )
	if( ply.NextSpawnTime and ply.NextSpawnTime > CurTime() ) then return end
	if( ply:KeyPressed( IN_ATTACK ) or ply:KeyPressed( IN_ATTACK2 ) or ply:KeyPressed( IN_JUMP ) ) then
		if( ply:IsSurvivor() ) then
			GAMEMODE:SpawnAsSurvivor( ply )
		elseif( ply:IsAntlion() ) then
			GAMEMODE:SpawnAsAntlion( ply )
		end
	end
end

function GM:PlayerSwitchFlashlight( ply, SwitchOn )
	return ply:IsSurvivor()
end
function GM:PlayerCanPickupWeapon( ply, weapon )
	return ply:IsSurvivor()
end
function GM:PlayerCanPickupItem( ply, item )
	return ply:IsSurvivor()
end
function GM:AllowPlayerPickup( ply, ent )
	return ply:IsSurvivor()
end
function GM:PlayerUse( ply, ent )
	return ply:IsSurvivor()
end

-------------------------------------------
-- BELOW IS CODE TO BE IMPLEMENTED LATER --
-------------------------------------------

-- Picks a player from TEAM_ANTLION at random and respawns them as an Antlion Guard.
--[[function GM:SpawnAntlionGuard()
	local tAntlions = team.GetPlayers( TEAM_ANTLION )
	local ply = tAntlions[ math.random( 1, #tAntlions ) ]
	GAMEMODE:SpawnAsAntlion( ply, ANTLION_GUARD )
end]]

-- Picks a player from TEAM_ANTLION at random and respawns them as an Antlion Guardian.
--[[function GM:SpawnAntlionGuardian()
	local tAntlions = team.GetPlayers( TEAM_ANTLION )
	local ply = tAntlions[ math.random( 1, #tAntlions ) ]
	GAMEMODE:SpawnAsAntlion( ply, ANTLION_GUARDIAN )
end]]

-- PlayerDisconnected
--[[function GM:PlayerDisconnected( ply )
	
	-- If there are no players left just restart the game.
	local iNumPlayers = #player.GetAll()
	if( iNumPlayers == 0 ) then
		game.ConsoleCommand( "changelevel " .. game.GetMap() )
		return
	end
	
	-- There can be one survivor vs npc antlions
	-- There can't be 0 survivors
	-- What if players want a campaign just against antlions?
	
	-- If team ratio is more than 2:1 do an autobalance
	local iNumAntlions = team.NumPlayers( TEAM_ANTLION )
	local iNumSurvivors = team.NumPlayers( TEAM_SURVIVOR )
	if( iNumAntlions == 0 and iNumSurvivors >= 2 and GAMEMODE.BalanceTeams ) then
		gamemode.Call( "BalanceTeams" )
	elseif( iNumSurvivors == 0 ) then
		if ( iNumAntlions / iNumSurvivors ) > 2 ) then
		gamemode.Call( "BalanceTeams" )
	end
	if( ply:IsAntlion() ) then
		-- if player was a guard or guardian, replace them
		-- if no antlions left
	elseif( ply:IsSurvivor() ) then
		-- if no survivors left move an antlion over
	end
	
end]]

-- Balance teams
--[[function GM:BalanceTeams()

	local iNumAntlions = team.NumPlayers( TEAM_ANTLION )
	local iNumSurvivors = team.NumPlayers( TEAM_SURVIVOR )
	local iMovePlayers = math.abs( iNumAntlions - iNumSurvivors )
	
	-- If teams are already equal don't bother.
	if( iMovePlayers == 0 ) then return end
	
	local tMoveCandidates = {}
	local lesserTeam = TEAM_SEXY
	
	if( iNumAntlions > iNumSurvivors ) then
		tMoveCandidates = team.GetPlayers( TEAM_ANTLION )
		lesserTeam = TEAM_SURVIVOR
	else
		tMoveCandidates = team.GetPlayers( TEAM_SURVIVOR )
		lesserTeam = TEAM_ANTLION
	end
	
	-- ATTN: Check to be sure we're sorting it right.
	table.sort( tMoveCandidates, function( a, b ) return a:TimeConnected() < b:TimeConnected() end )
	for i = 1, iMovePlayers do
		if( lesserTeam == TEAM_SURVIVOR ) then
			GAMEMODE:SpawnAsSurvivor( tMoveCandidates[i] )
		else
			GAMEMODE:SpawnAsAntlion( tMoveCandidates[i] )
		end
	end
	
end]]

-- PlayerRequestTeam
--[[function GM:PlayerRequestTeam( ply, teamid )
	if teamid == ply:Team() then
		return false
	end
	local iOppositeTeam = ( teamid == TEAM_ANTLION and TEAM_REBEL or TEAM_ANTLION )
	local iNumRequested = team.NumPlayers( teamid )
	local iNumOpposing = team.NumPlayers( iOppositeTeam )
	local iTotalPlayers = iNumRequested + iNumOpposing
	-- Make sure the team ratio isn't more than 2:1
	if( iNumRequested == 0 or ( iNumRequested / iTotalPlayers ) <= 0.5 ) then
		return true
	end
	return self.BaseClass:PlayerRequestTeam( ply, teamid )
end]]

--[[function GM:DoPlayerDeath( ply, attacker, dmg )
	self.BaseClass:DoPlayerDeath( ply, attacker, dmg )
end]]