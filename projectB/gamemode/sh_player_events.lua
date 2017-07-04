
function GM:PlayerNoClip( ply )

	return ply:IsAdmin()
	
end

function GM:GravGunPunt( ply, ent )
	
	if ent:IsPlayer() and ent:IsAntlion() and ent:GetFlipped() < CurTime() then
		
		if ( CurTime() > ( ply.NextPunt or 0 ) ) then
			
			ply.NextPunt = CurTime() + 1
			ent:Flip()
			print( ply, ent )
			return true
			
		end
		
		return false
		
	end
	
	return self.BaseClass:GravGunPunt( ply,  ent )
	
end


function GM:PlayerNearThumper( ply )

	if !IsValid(ply) or !ply:GetGroundEntity() or !GAMEMODE:IsConsideredSand( ply:GroundMat() ) then return end
	
	local rad, dist, buffer
	
	for k, v in pairs( ents.FindByClass( ENTITY_THUMPER_CLASS ) ) do
	
		if v:GetNWBool("Enabled") then
			
			rad = v:GetNWInt("Radius")
			dist = (ply:GetPos() - v:GetPos()):LengthSqr()
			buffer = rad^2 / 5
			
			if dist <= (rad^2 - buffer) then
				
				-- as we get closer, we want the push to be more powerful
				return v, (v:GetPos() - ply:GetPos()):Normalize() * -(rad/dist)
				
			end
			
		end
		
	end
	
	return false
	
end


local BURROW_STOP = 0		-- Stop movement
local BURROW_CONTINUE = 1	-- Allow movement to continue
local BURROW_RETURN = 2		-- Return to last valid position

local DownwardTraces = {}
local DIST_STOP = 16
local DIST_TRACE = 100
local DIST_LEDGE = 40
local DIST_WATER = 5
local DIST_UNDER = 16
local DIST_LASTPOS = 10
local DIST_CENTEROFFSET = 32
local NUM_DOWNTRACES = 10

local function PlayerBurrowLogic( ply )
	
	DownwardTraces[ply] = {}
	
	local pos = ply:GetPos()
	local ground = ply:GroundMat()
	local Continue = true
	
	ply.LastValidPos = ply.LastValidPos or pos
	
	if !ground then
		
		--print(ply,"No ground ahead:",ground,"Returning to ",ply.LastValidPos)
		return BURROW_RETURN
		
	elseif !GAMEMODE:IsConsideredSand( ground ) then
		
		--print(ply,"Invalid sand material:",ground,"Returning to ",ply.LastValidPos)
		return BURROW_RETURN
		
	elseif ply:WaterLevel() > 0 then
		
		--print(ply,"Water ahead:","Returning to ",ply.LastValidPos)
		return BURROW_RETURN
		
	end
	
	// Vectors
	local center = pos + vector_up * DIST_CENTEROFFSET
	local forward = ply:GetVelocity():Normalize() --GetForward()
	
	// Tables/entities
	local filter = {}
	local filterWorld = ents.FindByClass( "worldspawn" )[1]
	local filterProps = ents.FindByClass( "prop_*" )
	local filterItems = ents.FindByClass( "item_*" )
	local filterNPCs = ents.FindByClass( "npc_*" )
	local filterWeapons = ents.FindByClass( "weapon_*" )
	local filterPlayers = player.GetAll()
	
	local filterSurfaceEntities = { unpack( filterPlayers ), unpack( filterProps ), unpack( filterItems ), unpack( filterNPCs ), unpack( filterWeapons ) }
	local filterUndergroundEntities = { filterWorld, unpack( filterPlayers ) }
	
	-- If we're on the client, we want to filter our antlion model just in case.
	if CLIENT and ply == LocalPlayer() then
		
		table.insert( filterSurfaceEntities, ply.AntlionModel )
		table.insert( filterUndergroundEntities, ply.AntlionModel )
		
	end
	
	if ply:KeyReleased( IN_USE ) then
		
		MsgN( "Surface:" )
		PrintTable( filterSurfaceEntities )
		MsgN( "\nUnderground:" )
		PrintTable( filterUndergroundEntities )
		
	end
	
	-- First trace - Forward
	local tr = {}
	tr.start = center
	tr.endpos = tr.start + forward * DIST_TRACE
	tr.filter = filterSurfaceEntities
	local traceForward = util.TraceLine( tr )
	
	local traceDownward = {}
	local vDiff, fLen, sDecision
	local str = "No Reason"
	
	for i = 1, NUM_DOWNTRACES do
		
		local d = i * 10
		if ( i < 6 ) then -- less than 50 units away
			
			ground = GAMEMODE:GetGroundMat( traceForward.StartPos + traceForward.Normal * d, d + DIST_CENTEROFFSET )
			
			if !GAMEMODE:IsConsideredSand( ground ) then
			
				if ply:KeyReleased( IN_USE ) then
					print( "found no sand ahead - stopping", ground )
				end
				
				return BURROW_STOP
				
			end
			
		end
		
		-- Our Downward Trace
		tr = {}
		tr.start = traceForward.StartPos + traceForward.Normal * i
		tr.endpos = tr.start - vector_up * DIST_TRACE
		tr.filter = filterSurfaceEntities
		traceDownward = util.TraceLine( tr )
		DownwardTraces[ply][i] = traceDownward
		
		vDiff = ( pos - traceDownward.HitPos )
		fLen = vDiff:Length2DSqr()
		sDecision = BURROW_STOP
		
		-- the current downward trace is a lot lower down than the previous downward trace
		if ( !traceDownward.Hit or ( i > 1 and DownwardTraces[ply][i-1].HitPos.z - traceDownward.HitPos.z >= DIST_LEDGE ) ) then
			
			fLen = vDiff:Length2DSqr()
			Continue = false
			str = "Ledge"
			
			if ply:KeyReleased( IN_USE ) then
				print(ply,i,vDiff,"Too close to ledge?")
			end
			
			return BURROW_RETURN
			
		-- the trace goes into water
		elseif util.PointContents( traceDownward.HitPos + vector_up ) == CONTENTS_WATER then
			
			fLen = vDiff:Length2DSqr()
			Continue = false
			sDecision = BURROW_RETURN
			
			if ply:KeyReleased( IN_USE ) then
				print(ply,i,vDiff,"Too close to water?")
			end
			
			str = "Water"
			
			return BURROW_RETURN
			
		end
		
		-- We're within stopping distance
		if !Continue and fLen <= DIST_STOP^2 then
			
			--print("HitPos:", "Vector("..traceDownward.HitPos.x..", "..traceDownward.HitPos.y..", "..traceDownward.HitPos.z..")", "Vector("..pos.x..", "..pos.y..", "..pos.z..")")
			--print("fLen:", fLen, DIST_STOP^2)
			--print("Down:",unpack(str))
			
			if ply:KeyReleased( IN_USE ) then
				print(ply,"Downward trace",str,i,vDiff,"Decision: "..((sDecision==BURROW_RETURN and "Return") or "Stop"))
			end
			
			return sDecision
			
		end
		
	end
	
	vDiff = nil
	Continue = true
	
	-- Our Underground Trace
	tr = {}
	tr.start = pos - vector_up * DIST_UNDER
	tr.endpos = tr.start + forward * DIST_TRACE
	tr.filter = filterUndergroundEntities
	local traceUnder = util.TraceLine( tr )
	
	-- First we should be sure we aren't burrowing through a surface.
	-- Omg - If the surface isn't thick enough, you can burrow right through to the other side.
	-- Maybe have a highlight showing if you can burrow through
	
	--[[local traceUp = util.QuickTrace( traceUnder.StartPos, traceUnder.StartPos + vector_up * DIST_TRACE )
	if util.PointContents( traceUnder.StartPos ) == CONTENTS_EMPTY then
		
		-- maybe we shouldnt have burrowed?
		
	end]]
	
	-- the trace left the world, which probably means a cliff is ahead
	--[[if traceUnder.FractionLeftSolid and traceUnder.FractionLeftSolid > 0 then
		
		vDiff = ( ( traceUnder.StartPos + traceUnder.Normal * ( traceUnder.FractionLeftSolid * DIST_TRACE ) ) - pos )
		str = {  "Tracing underground:", "Checking for: Cliffs you could exit from.", "Distance from cliff: "..vDiff:Length2DSqr(), "HitPos: "..tostring( traceUnder.HitPos ), "Decision: BURROW_STOP" }
		
	-- the trace hit something, and it wasn't the world!
	elseif traceUnder.Entity and traceUnder.Entity != filterWorld then
		
		vDiff = ( traceUnder.HitPos - traceUnder.StartPos )
		str = { "Tracing underground:", "Checking for: Underground obstacles.", "Distance from object: "..vDiff:Length2DSqr(), "HitPos: "..tostring( traceUnder.HitPos ), "Decision: BURROW_STOP" }
		
	end
	
	-- We have a difference and we're within stopping distance
	if vDiff and vDiff:Length2DSqr() <= DIST_STOP^2 then
		
		print("Under:",unpack(str))
		return BURROW_STOP
		
	end]]
	
	if GAMEMODE:PlayerNearThumper( ply ) then
		
		return BURROW_RETURN
		
	end
	
	-- We don't have a last valid position or our distance from our last valid position is within 
	if Continue and !ply.LastValidPos or ( pos - ply.LastValidPos ):Length2D() > DIST_LASTPOS^2 then
		
		ply.LastValidPos = pos
		
	end
	
	return BURROW_CONTINUE
	
end

local function BurrowedMove( ply, move )
	
	local burrowDecision = PlayerBurrowLogic( ply )
	
	if burrowDecision == BURROW_STOP then
		
		if ply:KeyReleased( IN_USE ) then
			MsgN("Decision: Stop")
		end
		return movement.StopMovement( move )
		
	elseif burrowDecision == BURROW_RETURN then
	
		if ply:KeyReleased( IN_USE ) then
			MsgN("Decision: Return")
		end
		return movement.MoveTowardsVector( ply, move, ply.LastValidPos )
		
	elseif burrowDecision == BURROW_CONTINUE then
	
		if GAMEMODE:PlayerNearThumper( ply ) then
			
			if ply:KeyReleased( IN_USE ) then
				MsgN("Decision: Thumper Stop")
			end
			return movement.MoveTowardsVector( ply, move, ply.LastValidPos )
			
		else
		
			if ply:KeyReleased( IN_USE ) then
				MsgN("Decision: Continue")
			end
			return move
			
		end
		
	else
		
		if ply:KeyReleased( IN_USE ) then
			MsgN("Decision: nil")
		end
		return move
		
	end
	
end


/*------------------------------------
	Move
------------------------------------*/
function GM:Move( ply, move )
	
	if !ply:IsAntlion() then return end
	
	// burrowing
	if ply:IsBurrowed() or ply:GetBurrowingOut() > CurTime() or ply:GetBurrowingIn() > CurTime() then
		
		// speed multiplier
		local mul = 0.7;
		
		// slow them down
		if ply:GetBurrowingIn() > CurTime() then
		
			mul = 0
			
		elseif ply:GetBurrowingOut() > CurTime() then
		
			mul = 0.1
			
		end
		
		move:SetForwardSpeed( move:GetForwardSpeed() * mul );
		move:SetSideSpeed( 0 );
		move:SetUpSpeed( 0 );
		
		return BurrowedMove( ply, move )
		
	end
	
	local thumper, direction = GAMEMODE:PlayerNearThumper( ply )
	
	if thumper and ply:GroundMat() == GAMEMODE:GetGroundMat( thumper:GetPos(), 100 ) then
		
		local fwd, side = movement.CalcSpeedToDest( ply, thumper:GetPos() - direction )
		local dist = (ply:GetPos() - thumper:GetPos()):Length()
		local mul = 1
		
		-- as we get closer to the thumper, we want the fwd/side speeds to become larger, but not stronger than our own speeds.
		-- however, we want them to be stronger when you don't go into it fast enough
		
		local subFwd = fwd - (fwd*(fwd/dist))
		local subSide = side - (side*(side/dist))
		
		--print(dist,subFwd,subSide)
		
		move:SetUpSpeed( 0 ) -- dont jump you little fucker.
		move:SetForwardSpeed( ( move:GetForwardSpeed() - subFwd ) ) -- + ( fwd )
		move:SetSideSpeed( ( move:GetSideSpeed() - subSide ) ) -- + ( side )
		
		return move
		
		--return movement.MoveTowardsVector( ply, move, thumper:GetPos() - direction )
		
	end
	
	// stop for attack?
	if ( ply:GetAttackHold() > CurTime() or ply:GetFlipped() > CurTime() or ply:GetPinned() > CurTime() or ply:GetBurrowingIn() > CurTime() or ply:GetBurrowingOut() > CurTime() ) then
		
		// stop!! in the name of looove!
		move:SetForwardSpeed( 0 );
		move:SetSideSpeed( 0 );
		move:SetUpSpeed( 0 );
	
	end

	// get current velocity & angle
	local vel = move:GetVelocity();
	
	// drowning?
	if ( ply:WaterLevel() > 1 ) then
	
		// speed multiplier
		local mul = 0.3;
		
		// slow them down
		move:SetForwardSpeed( move:GetForwardSpeed() * mul );
		move:SetSideSpeed( move:GetSideSpeed() * mul );
		move:SetUpSpeed( 0 );
		
		// wet the wings
		self.WetWings = CurTime() + 1;
		return;
	
	end
	
	// flying	
	if ( !ply:OnGround() ) then
	
		// flying up
		if ( ply:KeyDown( IN_JUMP ) && ply:GetStamina() > 0 && CurTime() > ( self.WetWings or 0 ) ) then
		
			// server only
			if ( SERVER ) then
			
				// update sound
				ply:SetWingSound( true );
				
			end
			
			// calculate multiplier
			local mul = ( vel.z > 40 ) && 9 || 13; // 9 - 13
			
			if ( isDedicatedServer() ) then
			
				mul = mul * 2;
			
			end
			
			// give upward speed
			vel = vel + ( vector_up * mul );
			
		else
		
			// server only
			if ( SERVER ) then
			
				// update sound
				ply:SetWingSound( false );
				
			end
			
			// set multiplier
			local mul = 8;
			
			if ( isDedicatedServer() ) then
			
				mul = mul * 2;
			
			end
		
			// float down
			vel = vel + ( vector_up * 2 );
			
		end
		
	else
	
		// server only
		if ( SERVER ) then
		
			// update sound
			ply:SetWingSound( false );
			
		end
		
	end
	
	// clamp their speed
	vel = ( vel:GetNormal() * math.min( vel:Length(), 800 ) );
	
	// update velocity
	move:SetVelocity( vel );
	
	return move
	
end

local filterclasses = {"prop_*","item_*","npc_*","weapon_*"}
function GM:ShouldCollide( ent1, ent2 )

	// Tables/entities
	/*local filter = {}
	local filterWorld = ents.FindByClass( "worldspawn" )[1]
	local filterProps = ents.FindByClass( "prop_*" )
	local filterItems = ents.FindByClass( "item_*" )
	local filterNPCs = ents.FindByClass( "npc_*" )
	local filterWeapons = ents.FindByClass( "weapon_*" )
	local filterPlayers = player.GetAll()
	
	local filterSurfaceEntities = { unpack( filterPlayers ), unpack( filterProps ), unpack( filterItems ), unpack( filterNPCs ), unpack( filterWeapons ) }
	local filterUndergroundEntities = { filterWorld, unpack( filterPlayers ) }*/
	--print("checking for collision on ",ent1,ent2)
	if ent1:IsPlayer() then
		if ( ent1:IsBurrowed() and ent2:GetClass() != "worldspawn" ) then
			--print("Don't collide",ent1,"with",ent2)
			return false
		end
	end
	
	return self.BaseClass:ShouldCollide( ent1, ent2 )
	
end

/*------------------------------------
	PlayerShouldTakeDamage
------------------------------------*/
function GM:PlayerShouldTakeDamage( ply, attacker )

	if ply:IsBurrowed() then return false end
	
	return self.BaseClass:PlayerShouldTakeDamage( ply, attacker )
	
end


/*------------------------------------
	PlayerFootstep
------------------------------------*/
function GM:PlayerFootstep( ply, pos, foot, sound, vol, filter )

	if CLIENT then
		
		return true
		
	end
	
	if ply:IsAntlion() then
		
		if ply:IsBurrowed() then
			
			return true
			
		end
		
		sound = "NPC_Antlion.Footstep"
		
		--[[local health, speed = ply:Health(), ply:GetVelocity():Length()
		local healthFraction = health/100
		
		if speed <= ANTLION_WALKSPEED then
		
			sound = "NPC_Antlion.FootstepSoft"
			
		else
		
			sound = "NPC_Antlion.Footstep"
			
		end
		
		if healthFraction <= 0.25 then
		
			sound = "NPC_Antlion.Footstep"
			
		elseif healthFraction <= 0.75 then
		
			sound = "NPC_Antlion.FootstepHeavy"
			
		end]]
		
		if SERVER then
		
			ply:EmitSound( sound, vol*100 )
			return true
			
		end
		
	end
	
	self.BaseClass:PlayerFootstep( ply, pos, foot, sound, vol, filter )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerStepSoundTime( ply, iType, bWalking )
   Desc: Return the time between footsteps
---------------------------------------------------------*/
function GM:PlayerStepSoundTime( ply, iType, bWalking )
	
	if ply:IsAntlion() then
		
		local fStepTime = 350
		local fMaxSpeed = ply:GetMaxSpeed()
		
		if ( fMaxSpeed <= 100 ) then 
			fStepTime = 350 -- walking
		elseif ( fMaxSpeed <= 300 ) then
			fStepTime = 240 -- not running
		else 
			fStepTime = 180 -- running
		end
		--print( fMaxSpeed, fStepTime, bWalking )
		
		// Step slower if crouching
		if ( ply:Crouching() ) then
			fStepTime = fStepTime + 50
		end
		
		--fStepTime = fStepTime * ( ply:GetPlaybackRate() / 2 )
		return fStepTime
		
	end
	
	return self.BaseClass:PlayerStepSoundTime( ply, iType, bWalking )
	
end