// get metatable
local Player = FindMetaTable( "Player" );
assert( Player );

// accessors
AccessorFuncNW( Player, "attacktime", "AttackTime", FORCE_NUMBER );
AccessorFuncNW( Player, "attackanimation", "AttackAnimation", FORCE_STRING );
AccessorFuncNW( Player, "stamina", "Stamina", 0, FORCE_NUMBER );
AccessorFuncNW( Player, "viewmode", "ViewMode", 0, FORCE_NUMBER );
AccessorFuncNW( Player, "isspectating", "Spectating", false, FORCE_BOOL );
AccessorFuncNW( Player, "drawbody", "DrawBody", false, FORCE_BOOL );
AccessorFuncNW( Player, "attackhold", "AttackHold", 0, FORCE_NUMBER );
AccessorFuncNW( Player, "flipped", "Flipped", 0, FORCE_NUMBER );
AccessorFuncNW( Player, "pinned", "Pinned", 0, FORCE_NUMBER );

AccessorFuncNW( Player, "burrowingin", "BurrowingIn", 0, FORCE_NUMBER );
AccessorFuncNW( Player, "burrowingout", "BurrowingOut", 0, FORCE_NUMBER );

/*------------------------------------
	IsRebel
------------------------------------*/
function Player:IsRebel()

	return self:Team() == TEAM_REBEL
	
end

/*------------------------------------
	IsAntlion
------------------------------------*/
function Player:IsAntlion()

	return self:Team() == TEAM_ANTLION
	
end


/*------------------------------------
	IsMedic
------------------------------------*/
function Player:IsMedic()

	return self:IsRebel() and self:GetNWBool( "ismedic" )
	
end

/*------------------------------------
	MakeMedic
------------------------------------*/
function Player:MakeMedic()

	if self:IsRebel() then
	
		self:SetNWBool( "ismedic", true )
		
	end
	
end


/*------------------------------------
	IsAntlionWorker
------------------------------------*/
function Player:IsAntlionWorker()

	return self:IsAntlion() and self:GetNWBool( "isantlionworker" )
	
end

/*------------------------------------
	MakeAntlionWorker
------------------------------------*/
function Player:MakeAntlionWorker()

	if self:IsAntlion() then
	
		self:SetNWBool( "isantlionworker", true )
		
	end
	
end


/*------------------------------------
	IsAntlionGuard
------------------------------------*/
function Player:IsAntlionGuard()

	return self:IsAntlion() and self:GetNWBool( "isantlionguard" )
	
end

/*------------------------------------
	MakeAntlionGuard
------------------------------------*/
function Player:MakeAntlionGuard()

	if self:IsAntlion() then
	
		self:SetNWBool( "isantlionguard", true )
		
	end
	
end


/*------------------------------------
	IsAntlionGuardian
------------------------------------*/
function Player:IsAntlionGuardian()

	return self:IsAntlion() and self:GetNWBool( "isantlionguardian" )
	
end

/*------------------------------------
	MakeAntlionGuardian
------------------------------------*/
function Player:MakeAntlionGuardian()

	if self:IsAntlion() then
	
		self:SetNWBool( "isantlionguardian", true )
		
	end
	
end


/*------------------------------------
	CanBurrowIn
------------------------------------*/
function Player:CanBurrowIn()
	
	if GAMEMODE:PlayerNearThumper( ply ) then return false end
	if !GAMEMODE:IsConsideredSand( self:GroundMat() ) then return false end
	if !self:Alive() then return false end
	if !self:IsAntlion() or self:IsAntlionGuard() or self:IsAntlionGuardian() then return false end
	if self:IsBurrowed() then return false end
	if self:GetBurrowingIn() > CurTime() or self:GetBurrowingOut() > CurTime() or self:GetNextBurrowTime() > CurTime() then return false end
	
	return true
	
end

/*------------------------------------
	CanBurrowOut
------------------------------------*/
function Player:CanBurrowOut()
	
	if !GAMEMODE:IsConsideredSand( self:GroundMat() ) then return false end
	if !self:Alive() then return false end
	if !self:IsAntlion() or self:IsAntlionGuard() or self:IsAntlionGuardian() then return false end
	if !self:IsBurrowed() then return false end
	if self:GetBurrowingIn() > CurTime() or self:GetBurrowingOut() > CurTime() or self:GetNextBurrowTime() > CurTime() then return false end
	
	return true
	
end

/*------------------------------------
	IsBurrowed
------------------------------------*/
function Player:IsBurrowed()

	return self:IsAntlion() and self:GetNWBool( "burrowedin", false )
	
end


/*------------------------------------
	IsSprinting
------------------------------------*/
function Player:IsSprinting( )

	// get movement speed
	local speed = self:GetVelocity():Length();

	return ( self:KeyDown( IN_SPEED ) and speed > 100 );

end


/*------------------------------------
	GroundMat
------------------------------------*/
function Player:GroundMat()

	if !self:OnGround() then return end
	
	return GAMEMODE:GetGroundMat( self:GetPos(), 50 )
	
end

/*------------------------------------
	IsOnSand
------------------------------------*/
function Player:IsOnSand()
	
	if !ply:OnGround() then return false end
	
	local mat = self:GroundMat()
	
	return mat and ( GAMEMODE:IsConsideredSand( mat ) or mat == MAT_SAND or mat == MAT_DIRT )
	
end
Player.OnSand = Player.IsOnSand

/*------------------------------------
	TeamSpeaking
------------------------------------*/
function Player:TeamSpeaking()

	return self:FetchNWBool( "player_IsTeamSpeaking", false )
	
end

/*
local function TranslateGroundMat( enum )
	for k, v in pairs( _E ) do
		if k:find("MAT_") and v == enum then
			return k
		end
	end
end
*/

