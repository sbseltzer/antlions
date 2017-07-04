
local function Approximate( num, test, offset )
	
	return (num <= test + offset and num >= test - offset) and num
	
end


/*------------------------------------
	UpdateAnimation
------------------------------------*/
function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed ) -- This handles everything about how sequences run, the framerate, boneparameters, everything.

	if !ply:IsAntlion() then return self.BaseClass:HandlePlayerJumping( ply ) end

	local eye = ply:EyeAngles()
	ply:SetLocalAngles( eye )
	ply:SetEyeTarget( ply:EyePos( ) )

	if CLIENT then
		local ang = eye
		if !ply:OnGround() then
			ang.roll = ply.FlightRoll or 0
		end
		ply:SetRenderAngles( ang )
	end
	
	local estyaw = math.Clamp( math.atan2( velocity.y, velocity.x ) * 180 / 3.141592, -180, 180 )
	local myaw = math.NormalizeAngle( math.NormalizeAngle( eye.y ) - estyaw )
	
	local fMaxSpeed = ply:GetMaxSpeed()
	local len2d = velocity:Length2D() --Velocity in the x and y axis
	local rate = 1.0
	
	// We're doing this afterward so moveyaw detects everything correctly
	ply:SetPoseParameter( "move_yaw", myaw * -1 )
	--This huge set of boneparameters are all set to 0 to avoid having the engine setting them to something else, thus resulting in awkwardly twisted models
	ply:SetPoseParameter( "head_pitch", 0 )
	ply:SetPoseParameter( "head_yaw", 0 )
	
	--if len2d > 0.5 then
	--	rate = ( ( len2d * 0.8 ) / ( maxseqgroundspeed * 2 ) )
	--end
	
	// Making playback rates match up was tricky. I had to manually adjust them.
	if len2d > 0.5 then
		if ( fMaxSpeed <= 100 ) then 
			rate = 0.9 -- walking slowly
		elseif ( fMaxSpeed <= 300 ) then 
			rate = 1.6 -- walking
		else 
			rate = 1.9 -- running
		end
	end
	
	if ply:OnGround() then
		if ply:KeyDown( IN_MOVERIGHT ) or ply:KeyDown( IN_MOVELEFT ) then
			if ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_BACK ) then
				--rate = 0.9 -- walking at a forward angle
				if ( fMaxSpeed <= 100 ) then 
					rate = 0.92 -- walking slowly
				elseif ( fMaxSpeed <= 300 ) then 
					rate = 1.2 -- walking
				else 
					rate = 1.5 -- running
				end
			elseif ply:KeyDown( IN_BACK ) and !ply:KeyDown( IN_FORWARD ) then
				--rate = 1.61 -- walking at a backward angle
				if ( fMaxSpeed <= 100 ) then 
					rate = 1.0 -- walking slowly *
				elseif ( fMaxSpeed <= 300 ) then 
					rate = 1.61 -- walking
				else 
					rate = 1.83 -- running
				end
			else
				--rate = 1.4 -- walking sideways
				if ( fMaxSpeed <= 100 ) then 
					rate = 0.86 -- walking slowly *
				elseif ( fMaxSpeed <= 300 ) then 
					rate = 1.15 -- walking
				else 
					rate = 1.55 -- running *
				end
			end
		elseif ply:KeyDown( IN_BACK ) and !ply:KeyDown( IN_FORWARD ) then
			--rate = 1.42 -- walking backwards
			if ( fMaxSpeed <= 100 ) then 
				rate = 1.05 -- walking slowly *
			elseif ( fMaxSpeed <= 300 ) then 
				rate = 1.42 -- walking
			else 
				rate = 1.6 -- running *
			end
		end
	end
	
	--rate = math.Clamp( rate, 0, 2 )
	
	ply:SetPlaybackRate( rate )
	
end


local ANTLION_IDLEANIMS = {"DistractIdle2","DistractIdle3","DistractIdle4","DistractIdle2","Idle"}

/*------------------------------------
	CalcMainActivity
------------------------------------*/
function GM:CalcMainActivity( ply, velocity )

	if !ply:IsAntlion() then return self.BaseClass:CalcMainActivity( ply, velocity ) end
	
	// The following code is modified from foszor's grub gamemode
	
	// default to idle
	local act = "NIL";
	
	// get movement speed
	local speed = ply:GetVelocity():Length2D();
	
	// on ground?
	if ( ply:OnGround() ) then
		
		if ( speed > 0 ) then
		
			act = "walk_all";
			
		elseif ( speed > 300 ) then
		
			if ( ply:Health() < 50 ) then
				
				act = "runagitated";
				
			else
				
				act = "run_all";
				
			end
			
		end
		
	else
	
		// glide
		act = "jump_glide";
		
	end
	
	// check attacking
	if ( ( ply:GetAttackTime() or 0 ) > CurTime() ) then
		
		ply.WasAttacking = true;
		act = ply:GetAttackAnimation();
		ply:SetPlaybackRate( 1.0 )
	
	end
	
	// flipped
	if ( ply:GetFlipped() > CurTime() ) then
	
		act = "Flip1";
	
	end
	
	// burrowing
	if ply:IsBurrowed() then
	
		act = "digidle";
		
	elseif ply:GetBurrowingIn() > CurTime() then
	
		act = "digin";
		ply:SetPlaybackRate( 0.5 )
		
	elseif ply:GetBurrowingOut() > CurTime()  then
	
		act = "digout";
		ply:SetPlaybackRate( 0.5 )
		
	end
	
	// drowning?
	if ( ply:WaterLevel() > 1 ) then
	
		// on noes!
		act = "drown";
	
	end
	
	if act == "NIL" then
		
		if !ply.LastIdleEvent then
			
			ply.LastIdleEvent = table.Random( ANTLION_IDLEANIMS )
			act = ply.LastIdleEvent
			--print(act)
			
		end
		
	else
		
		if ply.LastIdleEvent then
			
			ply.LastIdleEvent = nil
			
		end
		
	end
	
	// find sequence
	local seq = ply:LookupSequence( act );
	
	
	
	return seq, seq
	
end


/*------------------------------------
	HandlePlayerJumping
------------------------------------*/
function GM:HandlePlayerJumping( ply ) --Handles jumping

	if !ply:IsAntlion() then return self.BaseClass:HandlePlayerJumping( ply ) end
	
	print( "jump" )
	
end


/*------------------------------------
	HandlePlayerDucking
------------------------------------*/
function GM:HandlePlayerDucking( ply, velocity ) --Handles crouching

	if !ply:IsAntlion() then return self.BaseClass:HandlePlayerDucking( ply, velocity ) end

	print( "duck" )
	
end


/*------------------------------------
	HandlePlayerSwimming
------------------------------------*/
function GM:HandlePlayerSwimming( ply ) --Handles swimming.

	if !ply:IsAntlion() then return self.BaseClass:HandlePlayerSwimming( ply ) end
	
	print( "swim" )
	
end
 

/*------------------------------------
	HandlePlayerDriving
------------------------------------*/
function GM:HandlePlayerDriving( ply ) --Handles sequences while in vehicles.
 
	if !ply:IsAntlion() then return self.BaseClass:HandlePlayerDriving( ply ) end
	
	print( "drive" )
	
end


/*------------------------------------
	HandleExtraActivities
------------------------------------*/
function GM:HandleExtraActivities( ply ) --Drop in here everything additional you need checks for.

	if !ply:IsAntlion() then return self.BaseClass:HandleExtraActivities( ply ) end
	
	print( "xtra" )
	
end


/*------------------------------------
	DoAnimationEvent
------------------------------------*/
function GM:DoAnimationEvent( ply, event, data ) -- This is for gestures.

	if !ply:IsAntlion() then return self.BaseClass:DoAnimationEvent( ply, event, data ) end
	
	--print( "EVENT",!ply:IsAntlion() )
	
end


