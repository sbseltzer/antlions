
function h(a,t) -- hat... lol
	return -16 * t^2 + 64 * t * math.sin(a)
end

function s(a,n,d) -- sand... lol
	-- a - amplitude multiplier
	-- n - number of antlions
	-- d - average distance between all the antlions and a given origin
	return n * ( ( 300 + ( n * 40 ) ) / d ) * a
end

local DEFAULT_MID = 300
function CalcShake( t, pos, amp )
	
	local n = 0
	local totalDist = 0
	
	for _, v in pairs( t ) do
	
		if IsValid( v ) then
		
			n = n + 1
			
			totalDist = totalDist + ( pos - v:GetPos() ):Length()
			
		end
		
	end
	
	if n == 0 then return n end
	
	local m = DEFAULT_MID + ( n * 40 )
	local d = totalDist / n
	amp = amp or 1
	
	return n * ( m / d ) * amp
	
end

function DoShake( ply, t, pos, amp )
	
	local shake = CalcShake( t, pos, amp )
	local origin = ply:GetPos()
	local totalVec = vector_origin
	local furthest = NULL
	local n = 0
	
	for k, v in pairs( t ) do
		
		if IsValid( v ) then
			
			n = n + 1
			
			totalVec = totalVec + v:GetPos()
			
			if !furthest or ( v:GetPos() - ply:GetPos() ):LengthSqr() < ( furthest:GetPos() - ply:GetPos() ):LengthSqr() then
				
				furthest = v
				
			end
			
		end
		
	end
	
	origin = totalVec / n
	
	util.ScreenShake( origin, shake, shake, 0.1, ( furthest:GetPos() - ply:GetPos() ):LengthSqr() )

end







