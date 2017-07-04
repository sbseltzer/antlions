
// Most of the following is taken from foszor's grub gamemode

// get metatable
local Player = FindMetaTable( "Player" );
assert( Player );

// accessors
AccessorFunc( Player, "nextattacktime", "NextAttackTime", FORCE_NUMBER );
AccessorFunc( Player, "nextrangeattacktime", "NextRangeAttackTime", FORCE_NUMBER );
AccessorFunc( Player, "nextburrowtime", "NextBurrowTime", FORCE_NUMBER );


local function AntlionStaminaThink( self )

	// get ground status
	local onground = self:OnGround()
	
	// stamina usage
	local stamina = 0;
	
	// check for flying
	if ( self:KeyDown( IN_JUMP ) and !onground ) then
	
		// consume
		stamina = 0.8;
	
	// check sprinting
	elseif ( self:IsSprinting() and onground ) then
	
		// consume
		stamina = 0.1;
	
	end

	// not consuming any?
	if ( stamina == 0 ) then
		
		// check delay
		if ( CurTime() > ( self.StaminaDelay or 0 ) ) then
		
			// get movement speed
			local speed = self:GetVelocity():Length();
		
			// recharge
			self:AdjustStamina( ( ( speed == 0 ) and 3 ) or 2 );
			
		end
		
	else
	
		// use stamage
		self:AdjustStamina( -stamina );
		
		// add delay
		self.StaminaDelay = CurTime() + ( ( self:GetStamina() > 0 ) and 1 or 2 );
	
	end
	
	// update movement speeds
	self:UpdateSpeeds();

end

local function RebelStaminaThink( self )

	// get ground status
	local onground = self:OnGround()
	
	// stamina usage
	local stamina = 0;
	
	// check for jumping
	if ( !onground ) then
	
		if self:KeyDown( IN_JUMP ) and !self.LostStaminaOnJump then
			
			// consume
			stamina = 5.0 + ( ( self:IsSprinting() and 5 ) or 0 );
			self.LostStaminaOnJump = true
			
		end
		
	else
		
		// check sprinting
		if ( self:IsSprinting() ) then
	
			// consume
			stamina = 0.5;
			
		end
		
		self.LostStaminaOnJump = false
	
	end

	// not consuming any?
	if ( stamina == 0 ) then
		
		// check delay
		if ( CurTime() > ( self.StaminaDelay or 0 ) ) then
		
			// get movement speed
			local speed = self:GetVelocity():Length();
		
			// recharge
			self:AdjustStamina( ( ( speed == 0 ) and 3 ) or 2 );
			
		end
		
	else
	
		// use stamage
		self:AdjustStamina( -stamina );
		
		// add delay
		self.StaminaDelay = CurTime() + ( ( self:GetStamina() > 0 ) and 1 or 2 );
	
	end
	
	// update movement speeds
	self:UpdateSpeeds();

end


local function PlayerThinkAntlion( self )

	// reset animation time?
	if ( CurTime() > self:GetAttackTime() and self.WasAttacking ) then
	
		// reset it
		self.WasAttacking = false;
		self:ResetSequence( self:LookupSequence( self:GetAttackAnimation() ) )
		self:SetCycle(0)
		--GAMEMODE:SetPlayerAnimation( self, 1 );
	
	end
	
	// get water level
	local waterlevel = self:WaterLevel();
	
	// are we getting wet?
	if ( waterlevel > 1 ) then
	
		// pain... AGONY!
		self:TakeDamage( ( waterlevel == 2 ) and 1 or 2, self, self )
		return;
	
	end
	
	if ( self:IsBurrowed() ) then
		
		return;
		
	end
	
	// get ground status
	local onground = self:OnGround();
	
	if ( onground ) then
		
		// have they been in air long enough?
		if ( CurTime() - ( self.LastOnGround or 0 ) > 0.5 ) then
		
			// play landing sound
			WorldSound( "NPC_Antlion.Land", self:GetPos(), 100, 100 );
		
		end
		
		// store on ground time
		self.LastOnGround = CurTime();
		
	end
	
	// attacking?
	if ( self.AttackKey and CurTime() > self:GetNextAttackTime() and waterlevel < 2 and CurTime() > self:GetFlipped() ) then
		
		// check ground
		if ( onground ) then
		
			// power?
			if ( self:KeyDown( IN_SPEED ) ) then
		
				// power attack
				self:MeleeAttack2();
				
			else
				
				// regular attack
				self:MeleeAttack1();
				
			end
			
		else
		
			// regular attack
			self:AirMelee();
			
		end
		
	end
	
	// attacking?
	if ( self.RangeAttackKey and CurTime() > self:GetNextRangeAttackTime() and waterlevel < 2 ) then
		
		self:RangeAttack();
	
	end
	
	AntlionStaminaThink( self )
	
end

local function PlayerThinkRebel( self )
	
	RebelStaminaThink( self )
	
end

/*------------------------------------
	Think - by foszor
------------------------------------*/
function Player:Think( )

	// validate player
	if ( self:Alive() ) then
		
		if self:IsAntlion() then
			
			PlayerThinkAntlion( self )
			
		elseif self:IsRebel() then
			
			PlayerThinkRebel( self )
			
		end
		
	end

end


local function Approximate( num, test, offset )
	
	return (num <= test + offset and num >= test - offset) and num
	
end

/*------------------------------------
	UpdateSpeeds
------------------------------------*/
function Player:UpdateSpeeds( )

	// set speeds
	local walk_speed = 300;
	local run_speed = 450;
	
	if self:IsRebel() then
	
		walk_speed = 200;
		run_speed = 350;
		
	end
	
	/*if self:OnGround() then
	
		local moveyaw = self:GetPoseParameter( "move_yaw" )
		local offset = 30
		if Approximate( moveyaw, -180, offset ) then -- backward
			
			walk_speed = 100
			run_speed = 150
			
		elseif Approximate( moveyaw, 45, offset ) or Approximate( moveyaw, -45, offset ) then -- forward + left or forward + right
			
			walk_speed = 200
			run_speed = 250
			
		elseif Approximate( moveyaw, 90, offset ) or Approximate( moveyaw, -90, offset ) then -- left or right
			
			walk_speed = 100
			run_speed = 150
			
		elseif Approximate( moveyaw, 135, offset ) or  Approximate( moveyaw, -135, offset ) then -- backward + left or backward + right
			
			walk_speed = 100
			run_speed = 150
			
		end
		
	end*/
	
	// call update function
	GAMEMODE:SetPlayerSpeed( self, walk_speed, ( self:GetStamina() > 0 ) and run_speed or walk_speed );
	
end


/*------------------------------------
	SetWingSound
------------------------------------*/
function Player:SetWingSound( bool )

	// verify sound
	if ( !self.WingSound ) then
	
		// create sound
		self.WingSound = CreateSound( self, "NPC_Antlion.WingsOpen" );
	
	end
	
	// needs to be on, but is stopped
	if ( bool and !self.WingSoundOn ) then
	
		// play sound & flag
		self.WingSound:Play();
		self.WingSoundOn = true;
		self:SetBodygroup( 1, 1 );
		--GAMEMODE:SetPlayerAnimation( self, 2 );
		
	// needs to be off, but is playing
	elseif ( !bool and self.WingSoundOn ) then
	
		// stop sound & flag
		self.WingSound:Stop();
		self.WingSoundOn = false;
		self:SetBodygroup( 1, 0 );
		--GAMEMODE:SetPlayerAnimation( self, 1 );
	
	end

end


/*------------------------------------
	AdjustStamina
------------------------------------*/
function Player:AdjustStamina( amt )

	// adjust stamina and clamp
	self:SetStamina( math.Clamp( self:GetStamina() + amt, 0, 100 ) );

end

--[[
/*------------------------------------
	GoSpectate
------------------------------------*/
function Player:GoSpectate( )

	// start spectating
	self:SetSpectating( true );
	self:SetTeam( TEAM_SPECTATOR );
	
end


/*------------------------------------
	GoTeam
------------------------------------*/
function Player:GoTeam( num )

	// setup player
	self:SetTeam( num );
	self:SetSpectating( false );
	self:Spectate( OBS_MODE_NONE );
	self:Spawn();
	
	// make sure its closed
	self:ConCommand( "menu_team close\n" );

end
]]

function Player:HandleMeleeAttack( id )
	
	local delay = 0;
	
	if id == 1 then
		
	elseif id == 2 then
	
		delay = 1.2;
		
		self:EmitSound( Sound( "NPC_Antlion.MeleeAttackSingle" ), 140 );
		self:SetAttackTime( CurTime() + delay );
		self:SetNextAttackTime( CurTime() + delay + 0.2 );
		self:SetAttackHold( CurTime() + delay );
		self:SetAttackAnimation( "attack2" );
		--GAMEMODE:SetPlayerAnimation( self, 2 );
		
		self:ClawAttack( 0.6, 35, math.random( 35, 45 ), 200 );
		
	elseif id == 3 then
		
	elseif id == 4 then
		
	elseif id == 5 then
		
	elseif id == 6 then
		
	end
	
end

/*------------------------------------
	MeleeAttack1
------------------------------------*/
function Player:MeleeAttack1( )

	local delay = 0.55;

	self:EmitSound( Sound( "NPC_Vortigaunt.Swing" ), 140 );
	self:SetAttackTime( CurTime() + delay );
	self:SetNextAttackTime( CurTime() + delay + 0.2 );
	self:SetAttackHold( CurTime() + delay - 0.25 );
	self:SetAttackAnimation( "charge_end" );
	--GAMEMODE:SetPlayerAnimation( self, 2 );
	self:ResetSequence( self:LookupSequence( self:GetAttackAnimation() ) )
	self:SetCycle(0)
	
	self:ClawAttack( 0.2, 35, math.random( 15, 25 ), 100 );

end


/*------------------------------------
	MeleeAttack2
------------------------------------*/
function Player:MeleeAttack2( )

	local delay = 1.2;

	self:EmitSound( Sound( "NPC_Antlion.MeleeAttackSingle" ), 140 );
	self:SetAttackTime( CurTime() + delay );
	self:SetNextAttackTime( CurTime() + delay + 0.2 );
	self:SetAttackHold( CurTime() + delay );
	self:SetAttackAnimation( "attack2" );
	--GAMEMODE:SetPlayerAnimation( self, 2 );
	self:ResetSequence( self:LookupSequence( self:GetAttackAnimation() ) )
	self:SetCycle(0)
	
	self:ClawAttack( 0.6, 35, math.random( 35, 45 ), 200 );

end


/*------------------------------------
	ChargeAttackEnd
------------------------------------*/
function Player:ChargeAttackEnd( )

	local delay = 0.55;
	
	self:EmitSound( Sound( "NPC_Vortigaunt.Swing" ), 140 );
	self:SetAttackTime( CurTime() + delay );
	self:SetNextAttackTime( CurTime() + delay + 0.2 );
	self:SetAttackAnimation( "charge_end" );
	--GAMEMODE:SetPlayerAnimation( self, 2 );
	
	self:ClawAttack( 0.2, 35, math.random( 15, 25 ), 100 );
	
end

/*------------------------------------
	ChargeAttack
------------------------------------*/
function Player:ChargeAttackThink( )
	
	local tr = self:GetEyeTrace()
	
	if tr.Hit and tr.StartPos:Distance( tr.HitPos ) < 50 then
		self:ChargeAttackEnd( )
	end
	
end

/*------------------------------------
	PounceAttack
------------------------------------*/
function Player:PounceAttack( )


end

/*------------------------------------
	AmbushAttack
------------------------------------*/
function Player:AmbushAttack( )


end


/*------------------------------------
	RangeAttack
------------------------------------*/
function Player:RangeAttack( )

	// setup trace
	/*local pos = self:GetPos() + Vector( 0, 0, 20 );
	local dir = self:GetAimVector();
	
	local ent = ents.Create( "grubs_projectile" );
	ent:SetPos( pos );
	ent:SetOwner( self );
	ent:SetAngles( dir:Angle() );
	ent:Spawn();
	ent:Activate();
	ent:SetVelocity( dir * 1000 );
	ent:SetGravity( 0.7 );
	
	self:SetNextRangeAttackTime( CurTime() + 0.7 );
	*/
	
end


/*------------------------------------
	AirMelee
------------------------------------*/
function Player:AirMelee( )

	local delay = 0.3;

	self:EmitSound( Sound( "NPC_Vortigaunt.Swing" ), 140 );
	self:SetAttackTime( CurTime() + delay );
	self:SetNextAttackTime( CurTime() + delay + 0.2 );
	self:SetAttackAnimation( "jump_start" );
	--GAMEMODE:SetPlayerAnimation( self, 2 );
	self:ResetSequence( self:LookupSequence( self:GetAttackAnimation() ) )
	self:SetCycle(0)
	
	self:ClawAttack( 0.1, 0, math.random( 15, 25 ), 200 );

end


local IMPACT_ATTACK_RADIUS = 250
/*------------------------------------
	ImpactAttack
	Called when an antlion lands.
------------------------------------*/
function Player:ImpactAttack( )

	local count = 0;
	
	local dist
	for _, ply in pairs( player.GetAll() ) do
	
		if ( ValidEntity( ply ) and ply:Alive() ) then
		
			if ( ply:Team() != self:Team() and ply:OnGround() ) then
			
				dist = ( self:GetPos() - ply:GetPos() ):Length();
				
				if ( dist < IMPACT_ATTACK_RADIUS ) then
				
					ply:Pin( self )
				
				end
			
			end
		
		end
	
	end
	
	if ( count > 0 ) then
	
		self:EmitSound( Sound( "NPC_Antlion.Distracted" ) );
		util.ScreenShake( self:GetPos(), 20, 10, 3, 300 );
		
	else
	
		util.ScreenShake( self:GetPos(), 10, 5, 1, 150 );
		
	end

end


/*------------------------------------
	Flip
------------------------------------*/
function Player:Flip( )

	if ( self:GetFlipped() > CurTime() ) then
	
		return false;
	
	end

	self:SetFlipped( CurTime() + 3 );
	self:EmitSound( Sound( "NPC_Antlion.Pain" ) );
	
	return true;

end


/*------------------------------------
	Pin
------------------------------------*/
function Player:Pin( antlion )

	if ( self:GetPinned() > CurTime() ) then
	
		return false;
	
	end
	
	self:SetPinned( CurTime() + 3 );
	self:EmitSound( Sound( "NPC_Citizen.Pain" ) );
	self:TakeDamage( 15, antlion, antlion )
	
	return true;

end


/*------------------------------------
	ClawAttackDispatch
	Makes a customized claw attack.
		Player ply
		Number height
		Number damage
		Number distance
		Vector dir
------------------------------------*/
local function ClawAttackDispatch( ply, height, damage, distance, dir )

	// validate player
	if ( !ValidEntity( ply ) or !ply:IsPlayer() or !ply:Alive() --[[or ply:GetSpectating()]] ) then
	
		return;
		
	end
	
	// setup trace
	local pos = ply:GetPos() + Vector( 0, 0, height );
	local dir = ply:GetAimVector();

	// build trace
	local trace = {};
	trace.start = pos;
	trace.endpos = pos + ( dir * distance );
	trace.filter = ply;
	local tr = util.TraceEntityHull( trace, ply );
	
	// validate
	if ( ValidEntity( tr.Entity ) ) then
	
		// play landing sound
		WorldSound( Sound( "Bounce.Flesh" ), tr.HitPos, 100, 100 );
		if tr.Entity:IsPlayer() and tr.Entity:IsRebel() then
			local effectdata = EffectData() 
				effectdata:SetOrigin( tr.HitPos );
				effectdata:SetScale( 10 );
				effectdata:SetMagnitude( 10 );
			util.Effect( "BloodImpact", effectdata, true, true );
		end
		
		local dmginfo = DamageInfo();
		dmginfo:SetInflictor( ply );
		dmginfo:SetAttacker( ply );
		dmginfo:SetDamage( damage );
		tr.Entity:DispatchTraceAttack( dmginfo, pos, tr.HitPos );
		
	end

end


/*------------------------------------
	ClawAttack
	Calls ClawAttackDispatch.
		Number delay
		Number height
		Number damage
		Number distance
------------------------------------*/
function Player:ClawAttack( delay, height, damage, distance )

	timer.Simple( delay, ClawAttackDispatch, self, height, damage, distance );

end

// The following is not by foszor.

--[[
// OPENSPACE EMPTY SMALL BRIGHT - min parameters
130

// OPENSPACE EMPTY HUGE DULL - max parameters
131

// OPENSPACE DIFFUSE SMALL BRIGHT - min parameters
132

// OPENSPACE DIFFUSE HUGE DULL - max parameters
133
]]
local BURROWED_DSP = 130

local function Burrowed(ply)
	
	ply:SetDSP( BURROWED_DSP )
	--ply:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	ply:SetBloodColor( BLOOD_COLOR_NONE )
	ply:AddEffects( EF_NODRAW )
	
	ply:SetNWBool( "burrowedin", true )
	
end
local function Unburrowed(ply)

	ply:SetDSP( 0 )
	--ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	ply:RemoveEffects( EF_NODRAW | EF_NOSHADOW )
	
	if ply:IsAntlionWorker() then
		
		ply:SetBloodColor( BLOOD_COLOR_ANTLION_WORKER )
		
	else
		
		ply:SetBloodColor( BLOOD_COLOR_ANTLION )
		
	end
	
	ply:SetNWBool( "burrowedin", false )
	ply:EmitSound( "NPC_Antlion.BurrowOut" )
	
end
	
/*------------------------------------
	BurrowIn
------------------------------------*/
function Player:BurrowIn()
	
	if ( !self:CanBurrowIn() ) then
		print("dont burrow in")
		return
	end
	
	self:EmitSound( "NPC_Antlion.BurrowIn" )
	self:AddEffects( EF_NOSHADOW )
	self:SetStepSize( 9 )
	self:ResetSequence( self:LookupSequence( "digin" ) )
	self:SetCycle( 0 )
	
	self:SetBurrowingIn( CurTime() + 2 )
	self:SetNextBurrowTime( self:GetBurrowingIn() + 2 )
	
	timer.Simple( 1.8, Burrowed, self )
	
end

/*------------------------------------
	BurrowOut
------------------------------------*/
function Player:BurrowOut()

	if ( !self:CanBurrowOut() ) then -- already burrowing out?
		print("dont burrow out")
		return
	end
	
	--local effectdata = EffectData()
	--effectdata:SetStart( self:GetPos() )
	--effectdata:SetNormal( self:GetAimVector():Normalize() )
	--util.Effect( "unburrow", effectdata )
	
	self:SetStepSize( 18 )
	self:ResetSequence( self:LookupSequence( "digout" ) )
	self:SetCycle( 15 )
	
	self:SetBurrowingOut( CurTime() + 2 )
	self:SetNextBurrowTime( self:GetBurrowingOut() + 3 )
	
	timer.Simple( 0.5, Unburrowed, self )
	
end

function Player:FlipTeam()

	if self:IsAntlion() then
	
		self:SetTeam(TEAM_REBEL)
		
	elseif self:IsRebel() then
	
		self:SetTeam(TEAM_ANTLION)
		
	else
	
		self:SetTeam(TEAM_ANTLION)
		
	end
	
end

