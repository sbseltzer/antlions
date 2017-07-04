Trace forward 100 units.
if the forward trace hits then
	move as usual. we'll collide with it anyway.
end
Trace down along that trace for every 10 units.
if the down trace mattype isnt sand then
	stop when youre 16 units away from the downward traces hitpos.
end
if the down trace doesnt hit or the difference between the height of the previous downward trace and the hitpos of this one is more than 40 units then
	stop when youre 16 xy units away from the current trace hitpos
end
if the down trace hitpos is in water or the point that is 5 units above the hitpos is in water then
	stop when youre 16 xy units away from the hitpos
end

local DownwardTraces = {}
local ValidPositions = {}
local DIST_STOP = 16
local DIST_TRACE = 100
local DIST_LEDGE = 40
local DIST_WATER = 5
local DIST_UNDER = 32
local DIST_LASTPOS = 32
local DIST_CENTEROFFSET = 32
local NUM_DOWNTRACES = 10

local function PlayerBurrowLogic( ply )
	
	DownwardTraces[ply] = {}
	
	local pos = ply:GetPos()
	local ground = ply:GroundMat()
	
	ply.LastValidPos = ply.LastValidPos or pos
	
	if !ground or !GAMEMODE:IsConsideredSand( ground ) then
		
		return BURROW_RETURN
		
	end
	
	// Vectors
	local center = pos + vector_up * DIST_CENTEROFFSET
	local forward = ply:GetForward()
	
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
	
	-- First trace - Forward
	local tr = {}
	tr.start = center
	tr.endpos = tr.start + forward * DIST_TRACE
	tr.filter = filterSurfaceEntities
	local traceForward = util.TraceLine( tr )
	
	local traceDownward = {}
	local vDiff, fLen -- vDiff will be our vector difference for length comparisons, and fLen will be the length between them
	
	for i = 1, NUM_DOWNTRACES do
		
		-- Our Downward Trace
		tr = {}
		tr.start = traceForward.StartPos + traceForward.Normal * i
		tr.endpos = tr.Start - vector_up * DIST_TRACE
		tr.filter = filterSurfaceEntities
		
		DownwardTraces[ply][i] = util.TraceLine( tr )
		traceDownward = DownwardTraces[ply][i]
		
		-- We're on one of the first 3 traces
		if i <= 3 and  then
			
			
		end
		
		vDiff = ( traceDownward.HitPos - pos )
		fLen = vDiff:Length2DSqr()
		
		-- the material type isnt sand.
		if !GAMEMODE:IsConsideredSand( traceDownward.MatType ) then
			
			fLen = vDiff:LengthSqr()
			
		-- the current downward trace is a lot lower down than the previous downward trace
		elseif ( !traceDownward.Hit or ( i > 1 and DownwardTraces[ply][i-1].HitPos.z - traceDownward.HitPos.z >= DIST_LEDGE ) ) then
			
			fLen = vDiff:Length2DSqr()
			
		-- the trace goes into water
		elseif util.PointContents( traceDownward.HitPos + vector_up ) == CONTENTS_WATER then
			
			fLen = vDiff:Length2DSqr()
			
		end
		
		-- We're within stopping distance
		if fLen <= DIST_STOP^2 then
		
			return BURROW_STOP
			
		end
		
	end
	
	vDiff = nil
	
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
	if traceUnder.FractionLeftSolid and traceUnder.FractionLeftSolid > 0 then
		
		vDiff = ( ( traceUnder.StartPos + traceUnder.Normal * ( traceUnder.FractionLeftSolid * DIST_TRACE ) ) - pos )
		
	-- the trace hit something, and it wasn't the world!
	elseif traceUnder.Entity and traceUnder.Entity != filterWorld then
		
		vDiff = ( traceUnder.HitPos - traceUnder.StartPos )
		
	end
	
	-- We have a difference and we're within stopping distance
	if vDiff and vDiff:Length2DSqr() <= DIST_STOP^2 then
		
		return BURROW_STOP
		
	end
	
	-- We don't have a last valid position or our distance from our last valid position is within 
	if !ply.LastValidPos or ( pos - ply.LastValidPos ):Length2D() > DIST_LASTPOS^2 then
		
		ply.LastValidPos = pos
		
	end
	
	return BURROW_CONTINUE
	
end







