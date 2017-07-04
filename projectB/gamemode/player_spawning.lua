
function GM:PlayerRequestTeam( ply, teamid )

	if teamid == ply:Team() or team.NumPlayers( teamid ) > team.NumPlayers( (teamid == TEAM_ANTLION and TEAM_REBEL) or TEAM_ANTLION ) then
	
		return false
		
	end
	
	return self.BaseClass:PlayerRequestTeam( ply, teamid )
	
end

function GM:IsSpawnpointSuitable( ply, spawn, force )

	return spawn.Enabled and !spawn.Player and self.BaseClass:IsSpawnpointSuitable( ply, spawn, force )
	
end

// We want rebels spawning near large groups of their teammates
local function FindLargestRebelSquadOrigin()

	local ply, largest
	
	for k, v in pairs( team.GetPlayers( TEAM_REBEL ) ) do
	
		local group = ents.FindInSphere( v:GetPos(), 1000 )
		local playersonly = {}
	
		for i, e in pairs(group) do
		
			if e:IsPlayer() and e:Team() == TEAM_REBEL then
			
				table.insert( playersonly, e )
				
			end
			
		end
		
		if !largest or #playersonly > #largest then
		
			ply = v
			
		end
		
	end
	
	return ply
	
end

// We want antlions spawning near small groups of rebels - right?
local function FindSmallestRebelSquadOrigin()

	local ply, smallest
	
	for k, v in pairs( team.GetPlayers( TEAM_REBEL ) ) do
	
		local group = ents.FindInSphere( v:GetPos(), 1000 )
		local playersonly = {}
		
		for i, e in pairs(group) do
		
			if e:IsPlayer() and e:Team() == TEAM_REBEL then
			
				table.insert( playersonly, e )
				
			end
			
		end
		
		if !smallest or #playersonly < #smallest then
		
			ply = v
			
		end
		
	end
	
	return ply
	
end

// Returns the best spawn depending on the team
function GM:GetClosestAvailableSpawn( teamID, ply )

	local closest, targetPos, spawns
	
	if teamID == TEAM_ANTLION then
	
		targetPos = FindSmallestRebelSquadOrigin()
		
		if targetPos and targetPos != ply then
		
			targetPos = targetPos:GetPos()
			
		end
		
		spawns = ANTLION_SPAWNS
		
	elseif teamID == TEAM_REBEL then
	
		targetPos = FindLargestRebelSquadOrigin()
		
		if targetPos and targetPos != ply then
		
			targetPos = targetPos:GetPos()
			
		end
		
		spawns = REBEL_PROGRESS_SPAWNS
		
	end
	
	if !spawns then return end
	
	if !targetPos then
	
		local highestID, progressSpawns = 0, {}
		
		for k, v in pairs(spawns) do
		
			if v.ProgressID > highestID then
			
				highestID = v.ProgressID
				
			end
			
		end
		
		for k, v in pairs(spawns) do
		
			if v.ProgressID == highestID then
			
				table.insert(progressSpawns, v)
				
			end
			
		end
		
		return table.Random(progressSpawns)
		
	end
	
	for k, v in pairs( spawns ) do
	
		if GAMEMODE:IsSpawnpointSuitable( ply, v, false ) then
		
			if !closest or v:GetPos():Distance( targetPos ) < closest:GetPos():Distance( targetPos ) then
			
				closest = v
				
			end
			
		end
		
	end
	
	return closest
	
end

function GM:PlayerSelectTeamSpawn( teamID, ply )

	local status = GAMEMODE:GetGameStatus()
	
	if teamID == TEAM_ANTLION then
	
		if GAME_EVENTS.GuardSpawn and ply:IsAntlionGuard() then
		
			local spawn = GAME_EVENTS.GuardSpawn
			GAME_EVENTS.GuardSpawn = NULL
			
			return spawn
			
		end
		
		if status == GAME_STATUS_INPROGRESS then
		
			return GAMEMODE:GetClosestAvailableSpawn( teamID, ply )
			
		elseif status == GAME_STATUS_INBATTLE then
		
			return table.Random( ANTLION_BATTLE_SPAWNS[GAMEMODE:GetCurrentBattle()] ) -- we want to return battle spawns of the currently active battle.
			
		else
		
			return table.Random( ANTLION_SPAWNS ) -- don't spawn?
			
		end
		
	elseif teamID == TEAM_REBEL then
	
		if status < GAME_STATUS_INPROGRESS then
		
			return table.Random( REBEL_INITIAL_SPAWNS )
			
		elseif status == GAME_STATUS_INPROGRESS then
		
			return GAMEMODE:GetClosestAvailableSpawn( teamID, ply )
			
		else
		
			return table.Random( REBEL_PROGRESS_SPAWNS ) -- don't spawn?
			
		end
		
	end
	
	return self.BaseClass:PlayerSelectTeamSpawn( teamID, ply )
	
end


function GM:PlayerSetModel( ply )
	
	if ply:IsAntlion() then
	
		//ply:AddEffects( EF_NODRAW ) -- We want to use a different entity for our model
		
		local function SetUpAntlion()
			
			ply:SetViewOffset( vector_up * 24 )
			
			if ply:IsAntlionWorker() then
			
				ply:SetModel("models/antlion_worker.mdl")
				ply:SetSkin( 0 )
				ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )
				
			else
			
				ply:SetModel("models/antlion.mdl")
				ply:SetSkin( math.random( 0, 3 ) )
				ply:SetBloodColor( BLOOD_COLOR_ANTLION )
				
			end
			
		end
		
		local function SetUpGuard()
		
			ply:SetModel("models/antlion_guard.mdl")
			ply:SetJumpPower( 0 )
			
			if ply:IsAntlionGuardian() then
			
				ply:SetSkin( 1 )
				ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )
				
			else
			
				ply:SetSkin( 0 )
				ply:SetBloodColor( BLOOD_COLOR_ANTLION )
				
			end
			
		end
		
		if ply:IsAntlionGuard() or ply:IsAntlionGuardian() then
		
			SetUpGuard()
			
		else
		
			SetUpAntlion()
			
		end
		
		ply:SetCanZoom( false )
		--ply:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		GAMEMODE:CreateAntlionModel( ply, ply:GetModel(), ply:GetSkin() )
		
	elseif ply:IsRebel() then
	
		local mdl = table.Random( REBEL_MODELS )
		
		if REBEL_MODELS and !util.IsValidModel( mdl ) then
			
			while( !util.IsValidModel( mdl ) ) do
			
				print( ply, "had invalid model",mdl," Starting while loop." )
				mdl = table.Random( REBEL_MODELS )
				
			end
			
		end
		
		ply:SetAnimGroup( "Male" )
		
		if mdl:find("group03m") then
		
			ply:MakeMedic()
			
		end
		
		GAMEMODE:CreatePlayerBody( ply, mdl )
		
		ply:SetBloodColor( BLOOD_COLOR_RED )
		ply:SetJumpPower( 200 )
		ply:SetCanZoom( true )
		ply:SetViewOffset( vector_up * 64 )
		
	else
	
		self.BaseClass:PlayerSetModel( ply )
		
	end
	
end

function GM:PlayerLoadout( ply )

	if ply:IsRebel() then
	
		ply:Give( "weapon_physcannon" )
		ply:Give( "weapon_smg1" )
		ply:Give( "weapon_shotgun" )
		ply:Give( "weapon_pistol" )
		ply:Give( "weapon_crowbar" )
		
		if ply:IsMedic() then
		
			ply:Give( "weapon_als_medkit" )
			
		end
		
	else
	
		self.BaseClass:PlayerLoadout( ply )
		
	end
	
end

function GM:PlayerInitialSpawn( ply )

	if ply:IsBot() then
	
		ply:SetTeam( math.random( 1, 2 ) )
		
		return
		
	end
	
	// Send the client our official 'sand' materials
	umsg.Start( "SendSandMats", ply )
		umsg.String( GAME_EVENTS.SandMats ) -- or GAME_RULES.SandMats -- We want to be sending the string
	umsg.End()
	
	self.BaseClass:PlayerInitialSpawn( ply )
	
end

function GM:PlayerSpawn( ply )
	
	// defaults
	ply:SetStamina( 100 );
	ply:SetNoCollideWithTeammates( true )
	ply:SetAvoidPlayers( true )
	
	if GAMEMODE:GetGameStatus() == GAME_STATUS_PREGAME then
	
		if ply:Team() == TEAM_REBEL or ply:Team() == TEAM_ANTLION then
		
			GAME_EVENTS:Fire( "WaitForPlayers" )
			
		end
		
	end
	
	ply.SpawnDelay = nil
	
	if ply:Team() == TEAM_REBEL then
		ply:SetPinned( 0 );
	elseif ply:Team() == TEAM_ANTLION then
		ply:SetAttackTime( 0 );
		ply:SetNextAttackTime( 0 );
		ply:SetNextRangeAttackTime( 0 );
		ply:SetFlipped( 0 );
		ply:SetBurrowingIn( 0 )
		ply:SetBurrowingOut( 0 )
		ply:SetNextBurrowTime( 0 )
		ply:SetNWBool( "burrowedin", false )
	end
	
	self.BaseClass:PlayerSpawn( ply )
	
end

function GM:PlayerDeathThink( ply )

	/*
	local status = GAMEMODE:GetGameStatus()
	if ply:Team() == TEAM_REBEL then
		if status < GAME_STATUS_INPROGRESS then
			if ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_JUMP) then
				ply:Spawn()
			end
		elseif status < GAME_STATUS_INBATTLE then
			if ply.SpawnDelay then
				if ply.SpawnDelay <= CurTime() then
					if ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_JUMP) then
						ply:Spawn()
					end
				end
			else
				ply.SpawnDelay = CurTime() + GAMEMODE.RebelSpawnDelay
			end
		elseif status > GAME_STATUS_INPROGRESS then
			return
		end
	elseif ply:Team() == TEAM_ANTLION then
		if status < GAME_STATUS_INPROGRESS then
			return
		elseif status < GAME_STATUS_GAMEOVER then
			if ply.SpawnDelay then
				if ply.SpawnDelay <= CurTime() then
					if ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_JUMP) then
						ply:Spawn()
					end
				end
			else
				ply.SpawnDelay = CurTime() + GAMEMODE.RebelSpawnDelay
			end
		end
	end*/
	
	self.BaseClass:PlayerDeathThink( ply )
	
end



