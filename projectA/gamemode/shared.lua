
GM.Name = "Antlion Survival"
GM.Author = "Samuel Seltzer-Johnston"
GM.Email = "geekwithalife@gmail.com"
GM.Website = "www.geekwithalife.com"
GM.TeamBased = true

DeriveGamemode( "base" )

TEAM_SURVIVOR = 1
TEAM_ANTLION = 2
TEAM_SEXY = 3 -- hehe :3

MEDIC_MODELS = {}
REBEL_MODELS = {}

ANTLION_NORMAL = 0
ANTLION_GUARD = 1
ANTLION_WORKER = 2
ANTLION_GUARDIAN = 3

include( "player_meta.lua" )
include( "entity_meta.lua" )
--include( "sh_hooks.lua" )

function GM:PrecacheContent()

	local path = "models/humans/group03/"
	local pathm = "models/humans/group03m/"
	local femaleStr, maleStr = "female_0", "male_0"
	
	-- There are 9 female rebels
	for i = 1, 9 do
		-- There are 7 female rebels
		if( i < 8 ) then
			if util.IsValidModel( path..femaleStr..i..".mdl" ) then
				table.insert( REBEL_MODELS, path..femaleStr..i..".mdl" )
			end
			if util.IsValidModel( pathm..femaleStr..i..".mdl" ) then
				table.insert( MEDIC_MODELS, pathm..femaleStr..i..".mdl" )
			end
		end
		if util.IsValidModel( path..maleStr..i..".mdl" ) then
			table.insert( REBEL_MODELS, path..maleStr..i..".mdl" )
		end
		if util.IsValidModel( pathm..maleStr..i..".mdl" ) then
			table.insert( MEDIC_MODELS, pathm..maleStr..i..".mdl" )
		end
	end
	
	-- Precache rebel models
	for k, v in pairs( REBEL_MODELS ) do
		util.PrecacheModel( v )
	end
	
	util.PrecacheModel("models/antlion.mdl")
	util.PrecacheModel("models/antlion_guard.mdl")
	util.PrecacheModel("models/antlion_worker.mdl")
	util.PrecacheModel("models/props_combine/CombineThumper001a.mdl")
	util.PrecacheModel("models/props_combine/CombineThumper002.mdl")
	
	-- Precache the antlion sounds from gamesounds.txt
	GAMEMODE.AntlionSounds = {
		BurrowIn = Sound("npc/antlion/digup1.wav"),
		BurrowOut = Sound("npc/antlion/digdown1.wav"),
		Rumble = Sound("npc/antlion/rumble1.wav"), -- Rumbling noise when antlions are moving around underground
		Distract = Sound("npc/antlion/distract1.wav"), -- That screaming sound made when antlions are called by bugbait
		Land = Sound("npc/antlion/land1.wav"),
		Fly = Sound("npc/antlion/fly1.wav"),
		Foot1 = Sound("npc/antlion/foot1.wav"),
		Foot2 = Sound("npc/antlion/foot2.wav"),
		Foot3 = Sound("npc/antlion/foot3.wav"),
		Foot4 = Sound("npc/antlion/foot4.wav"),
		Pain1 = Sound("npc/antlion/pain1.wav"),
		Pain2 = Sound("npc/antlion/pain2.wav"),
		SingleAttack1 = Sound("npc/antlion/attack_single1.wav"),
		SingleAttack2 = Sound("npc/antlion/attack_single2.wav"),
		SingleAttack3 = Sound("npc/antlion/attack_single3.wav"),
		DoubleAttack1 = Sound("npc/antlion/attack_double1.wav"),
		DoubleAttack2 = Sound("npc/antlion/attack_double2.wav"),
		DoubleAttack3 = Sound("npc/antlion/attack_double3.wav"),
		Swing1 = Sound("npc/vote/swing1.wav"),
		Swing2 = Sound("npc/vote/swing2.wav"),
		ClawStrike1 = Sound("npc/zombie/claw_strike1.wav"),
		ClawStrike2 = Sound("npc/zombie/claw_strike2.wav"),
		ClawStrike3 = Sound("npc/zombie/claw_strike3.wav"),
		ClawMiss1 = Sound("npc/zombie/claw_miss1.wav"),
		ClawMiss2 = Sound("npc/zombie/claw_miss2.wav"),
		ShellImpact1 = Sound("npc\antlion\shell_impact1.wav"),
		ShellImpact2 = Sound("npc\antlion\shell_impact2.wav"),
		ShellImpact3 = Sound("npc\antlion\shell_impact3.wav"),
		ShellImpact4 = Sound("npc\antlion\shell_impact4.wav")
	}
	
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard1.wav")
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard2.wav")
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard3.wav")
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard4.wav")
	
end

function GM:Initialize()
	GAMEMODE:PrecacheContent()
end

-- Returns a table of alive players, optionally from a specific team.
function GM:GetAlivePlayers( iTeam )
	local tPlayers = iTeam and team.GetPlayers( iTeam ) or player.GetAll()
	local tAlive = {}
	-- OPT: This has an O(n) time complexity and is being called from a Think hook.
	--		Use PlayerDeath/PlayerDisconnect and PlayerSpawn to update a global table instead.
	for i = 1, #tPlayers do
		if( tPlayers[i]:Alive() ) then
			table.insert( tAlive, tPlayers[i] )
		end
	end
	return tAlive
end

-- Think method for antlion players.
function GM:AntlionThink( ply )
	
	if( SERVER ) then
		if( ply:IsDrowning() ) then
			ply:TakeDrowningDamage( 1 )
		elseif( ply:GetAttackData() ) then
			-- They're attacking
			local tAttackData = ply:GetAttackData()
			bResetSequence = CurTime() - tAttackData.StartTime <= 0.5
			if( tAttackData.AttackTime >= CurTime() ) then
				-- Time to apply the attack
				ply:DispatchClawAttack()
			end
		end
	end
	
	--[[if( CLIENT and ply == LocalPlayer() ) then
		ply.ViewModel:SetPos( ply:GetPos() )
		ply.ViewModel:SetAngles( ply:GetAngles() )
		ply.ViewModel:SetRenderAngles( ply:GetAngles() )
		ply.ViewModel:SetPoseParameter( "move_yaw", ply:GetPoseParameter( "move_yaw" ) )
		ply.ViewModel:SetSequence( iSequence )
		ply.ViewModel:SetCycle( ply:GetCycle() )
		ply.ViewModel:DrawModel()
	end]]
	
end

function GM:Think()
	local tAntlions = GAMEMODE:GetAlivePlayers( TEAM_ANTLION )
	for i = 1, #tAntlions do
		gamemode.Call( "AntlionThink", tAntlions[i] )
	end
end

function GM:AntlionMove( ply, move )
	if( ply:GetAttackData() ) then
		-- Attacking
		move:SetVelocity( vector_origin )
	elseif( ply:IsDrowning() ) then
		-- Drowning
		move:SetVelocity( vector_origin )
	elseif( ply:GetFlightTime() > 0 ) then
		-- Flying
		local aimVec = ply:GetAimVector()
		move:SetVelocity( aimVec * ( math.abs( aimVec:Angle().pitch ) - ply:GetFlightTime() * 10 ) )
	else
		-- Walking/Running
		-- Implement thumpers
	end
	return move
end
--[[
function GM:CreateMove( ucmd )
	local ply = LocalPlayer()
	if( ply:IsSurvivor() ) then
		return ucmd
	end
	if( ply:GetAttackData() ) then
		
	end
end
]]
function GM:Move( ply, move )
	if( ply:IsAntlion() ) then
		return gamemode.Call( "AntlionMove", ply, move )
	end
	return self.BaseClass:Move( ply, move )
end

function GM:CreateTeams()

	team.SetUp( TEAM_SURVIVOR, "Survivor Team", Color( 255, 0, 0 ) )
	team.SetSpawnPoint( TEAM_SURVIVOR, "info_player_start" )
	
	team.SetUp( TEAM_ANTLION, "Antlion Team", Color( 0, 255, 0 ) )
	team.SetSpawnPoint( TEAM_ANTLION, "info_player_antlion" )
	
	team.SetUp( TEAM_SEXY, "Sexy Team", Color( 255, 150, 150 ) )
	team.SetSpawnPoint( TEAM_SEXY, "info_player_start" )
	
	team.SetSpawnPoint( TEAM_SPECTATOR, "info_player_start" ) 

end
