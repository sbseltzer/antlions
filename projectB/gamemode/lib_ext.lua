function team.GetAlivePlayers( teamID )
	local alive = {}
	for k, v in pairs( team.GetPlayers( teamID ) ) do
		if IsValid(v) and v:Alive() then
			table.insert(alive, v)
		end
	end
	return alive
end

function team.FlipPlayers( teamID1, teamID2, teamDefault, bKill )
	for _, ply in pairs( player.GetAll() ) do
		if IsValid(ply) then
			local couldKill = true
			if teamDefault then
				ply:SetTeam( teamDefault )
			elseif ply:Team() == teamID1 then
				ply:SetTeam( teamID2 )
			elseif ply:Team() == teamID2 then
				ply:SetTeam( teamID1 )
			else
				couldKill = false
			end
			if bKill and couldKill and ply:Alive() then
				ply:KillSilent()
			end
		end
	end
end

function ents.FindClassInSphere( class, pos, rad )
	local tr
	local entities = {}
	for k, v in pairs( ents.FindByClass( class ) ) do
		if ( pos - v:GetPos() ):LengthSqr() <= rad^2 then
			table.insert( entities )
		end
	end
	/*for k, v in pairs( ents.FindByClass( class ) ) do
		tr = util.QuickTrace( pos, v:GetPos(), filter )
		if (hitstop and !tr.Hit) or !hitstop then
			if tr.Entity == v and ( pos - v:GetPos() ):LengthSqr() <= rad^2 then
				table.insert( entities )
			end
		end
	end*/
	return entities
end

function util.PrecacheTableRecursive( t )
	for k, v in pairs( t ) do
		if type(v) == "table" then
			util.PrecacheTableRecursive( v )
		elseif type(v) == "string" then
			local ext = v:sub( -4 )
			local isValidSound = (ext == ".wav" or ext == ".mp3")
			local isValidModel = (ext == ".mdl" and util.IsValidModel(v))
			if isValidSound then
				util.PrecacheSound( v )
			elseif isValidModel then
				util.PrecacheModel( v )
			else
				print( "Attempted to precache '"..tostring(v).."' which is not a valid "..((isValidSound and "sound") or (isValidModel and "model"))..". Skipping..." )
			end
		else
			print( "Attempted to precache '"..tostring(v).."' which is not a valid string. Skipping..." )
		end
	end
end

function util.QuickTraceHull( startPos, endPos, mins, maxs, filter )
	local tr = {}
	tr.start = startPos
	tr.endpos = endPos
	tr.mins = mins
	tr.maxs = maxs
	tr.filter = filter
	return util.TraceHull(tr)
end

// Our own little library for movement
movement = {}

function movement.CalcSpeedToDest( ply, vDestination )

	if !vDestination then return 0, 0 end
	
	local maxspeed = ply:GetMaxSpeed()
	
	// The following code is with the assumption that we're moving backwards towards our destination
	local dest = ply:WorldToLocal(vDestination)
	local dir = dest:Normalize()
	
	// Holy shit this works! 
	local forward, side = dest.x * maxspeed, dest.y * maxspeed * -1
	local big = ( math.abs(forward) > math.abs(side) and forward ) or side
	local frac = math.abs(maxspeed/big)
	
	forward = math.Clamp( forward * frac, -maxspeed, maxspeed )
	side = math.Clamp( side * frac, -maxspeed, maxspeed )
	
	if dir.y < 0.05 and dir.y > -0.05  then
	
		side = 0
		
	end
	
	if dir.x < 0.05 and dir.x > -0.05  then
	
		forward = 0
		
	end
	
	return forward, side
	
end

function movement.MoveTowardsVector( ply, move, pos, resist )
	
	if !move then return true end
	
	local fwd, side = movement.CalcSpeedToDest( ply, pos )
	
	if resist then
		move:SetForwardSpeed( move:GetForwardSpeed() + fwd )
		move:SetSideSpeed( move:GetSideSpeed() + side )
	else
		move:SetForwardSpeed( fwd )
		move:SetSideSpeed( side )
	end
	
	return move
	
end

function movement.StopMovement( move )

	move:SetForwardSpeed( 0 )
	move:SetSideSpeed( 0 )
	move:SetUpSpeed( 0 )
	
	return move
	
end

























