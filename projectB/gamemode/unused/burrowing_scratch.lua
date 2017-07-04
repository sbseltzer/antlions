
local BurrowNodes = {}
local burrowPos = vector_origin
local currentIndex = 0
local function OnBurrowedIn( ply )
	
	BurrowNodes[ply] = {}
	currentIndex = 0
	burrowPos = ply:GetPos()
	timer.Create( "burrowedTimer", 1, 0, BurrowedMove, ply )
	
end
local function OnBurrowedOut( ply )
	
	BurrowNodes[ply] = {}
	currentIndex = 0
	burrowPos = ply:GetPos()
	timer.Remove( "burrowedTimer" )
	
end
local function BurrowedMove( ply )
	
	local pos = burrowPos
	local data = BurrowNodes[ply][currentIndex]
	local dist = (pos - data.Pos):Length()
	local timeDiff = data.Time - CurTime()
	
	if dist / timeDiff > ply:GetMaxSpeed() then
		burrowPos = data.Pos
	end
	
	currentIndex = currentIndex + 1
	BurrowNodes[ply][currentIndex] = {Pos = pos, Time = CurTime()}
	
end


///////////////////////////////////

SERVER

local BURROW_STOP = 0		-- Stop movement
local BURROW_CONTINUE = 1	-- Allow movement to continue
local BURROW_RETURN = 2		-- Return to last valid position

function GM:PlayerBurrowLogic( ply )
	
	ply.LastValidPos = ply.LastValidPos or ply:GetPos()
	
	local ground = ply:GroundMat() -- Ground material
	
	// See if we are on a valid surface
	if !ground or !GAMEMODE:IsConsideredSand( ground ) then
		
		-- our ground is invalid! we need go back to our last valid position!
		print( "Tread lightly, for these are hallowed grounds..." )
		
		return BURROW_RETURN
		
	end
	
	// Some locals we can reuse
	local pos = ply:LocalToWorld( ply:OBBCenter() )
	local fwd = ply:GetForward()
	local fwdMore = fwd * 100
	local dwn = vector_up * -100
	
	local filter = ents.GetAll() -- filter all but world
	for k, v in pairs( filter ) do
		if v:GetClass() == "worldspawn" then
			table.remove( filter, k )
		end
	end
	
	local traceFwd = util.QuickTrace( pos, pos + fwdMore, filter )
	
	if traceFwd.Hit and ( pos - traceFwd.HitPos ):LengthSqr() <= 16^2 then
		
		-- it's an obstacle! stop movement!
		print( "Something solid lies ahead... In fact, it's hitting you in the face!" )
		
		return BURROW_STOP
		
	end
	
	local traceDwn = util.QuickTrace( traceFwd.HitPos, traceFwd.HitPos + dwn, filter )
	
	local underPos = ply:GetPos() - vector_up * 5
	local underFilter = player.GetAll() -- filter players and world
	table.insert( underFilter, ents.FindByClass("worldspawn")[1] )
	
	local traceUnder = util.QuickTrace( undergroundPos, undergroundPos + fwdMore, underFilter )
	
	if traceUnder.Hit then
		
		-- there's probably a wall or prop that's partially underground! stop movement!
		print( "The gardeners were smart and made the wall go underground to keep you filthy wabbits out." )
		
		return BURROW_STOP
		
	end
	
	for i = 1, 10 do
	
		local fracPos = pos + fwd * i * 10
		local tr = util.QuickTrace( fracPos, fracPos + dwn, filter )
		
		if !tr.Hit or ( pos.z - tr.HitPos.z ) > i * 40 then
			
			-- it's probably a ledge!
			print( "Ledge ahead while looking for water!" )
			
			if ( ply:GetPos() - tr.HitPos ):Len2D() <= 16 then
				
				-- too close! stop movement!
				print( "Looks like searching for water paid off, but we found a nearby ledge instead!" )
				
				return BURROW_STOP
				
			end
			
		elseif util.PointContents( tr.HitPos ) == CONTENTS_WATER or util.PointContents( tr.HitPos + vector_up * 5 ) == CONTENTS_WATER then
			
			-- we're headed towards water!
			print( "Approaching water!" )
			
			if ( ply:GetPos() - tr.HitPos ):Len2D() <= 50 then
				
				-- too close! stop movement!
				print( "I hate water, so I'll just stop here before my feet get wet." )
				
				return BURROW_STOP
				
			end
			
		end
		
	end
	
	local traceDiag = util.QuickTrace( pos, pos + fwdMore + dwn, filter )
	
	if !traceDiag.Hit or ( pos.z - traceDiag.HitPos.z ) > 40 then
		
		-- it's a ledge! stop movement!
		print( "OMG IT IS A LEDGE!" )
		
		return BURROW_STOP
		
	end
	
	ply.LastValidPos = ply:GetPos()
	
	return BURROW_CONTINUE
	
end


function GM:PlayerBurrow





























