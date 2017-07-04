
local META = FindMetaTable( "Player" )
assert( META )

-- I'm too sexy for my shirt, too sexy for my shirt, so sexy it hurts...
function META:IsTooSexyForTheirShirt()
	return self:Team() == TEAM_SEXY
end

function META:IsDrowning()
	return self:WaterLevel() > 1
end

function META:CanClawAttack()
	return ( self:IsAntlion() and self:Alive() and ValidEntity( self:GetGroundEntity() ) and not self:IsDrowning() )
end

function META:StartFlying()
	self.WingOpenSound = CreateSound( "NPC_Antlion.WingsOpen" )
	self.WingOpenSound:Play()
	self:SetNWFloat( "m_fFlightStart", CurTime() )
	self:SetVelocity( ( self:GetAimVector() + vector_up ) * 100 )
end

function META:GetFlightTime()
	return CurTime() - self:GetNWFloat( "m_fFlightStart", CurTime() )
end

function META:StopFlying()
	self.WingOpenSound:Stop()
	self.WingOpenSound = nil
	self:SetNWFloat( "m_fFlightStart", nil )
end

-- Set the time that a claw attack is meant to be applied.
function META:GetAttackData()
	if( not self:CanClawAttack() ) then return end
	
	-- If the attack is completely over return nil.
	if( self:GetNWFloat( "m_fAttackEndTime" ) < CurTime() ) then
		return
	end
	
	-- This block is just to be sure the table exists on the client for proper prediction.
	self.m_tAttackData = self.m_tAttackData or {}
	self.m_tAttackData.Sequence = self:GetNWString( "m_sAttackSequence" )
	self.m_tAttackData.StartTime = self:GetNWFloat( "m_fAttackStartTime" )
	self.m_tAttackData.EndTime = self:GetNWFloat( "m_fAttackEndTime" )
	self.m_tAttackData.AttackTime = self:GetNWFloat( "m_fAttackTime" )
	
	-- If the attack has been applied, drop refrences to the Trace and Damage info.
	if( SERVER and self:GetNWFloat( "m_fAttackTime" ) < CurTime() ) then
		self.m_tAttackData.Trace = nil
		self.m_tAttackData.Damage = nil
	end
	
	return self.m_tAttackData
end

if not SERVER then return end

function META:TakeDrowningDamage( iDamage )
	-- if( CurTime() - self.m_fLastTakeDrowningDamage < 1.5 ) then return end
	-- self.m_fLastTakeDrowningDamage = CurTime()
	local dmginfo = DamageInfo()
	dmginfo:SetDamage( iDamage )
	dmginfo:SetDamageType( DMG_DROWN )
	dmginfo:SetAttacker( player.GetAll()[1] )
	dmginfo:SetDamageForce( vector_up * -10 )
	self:TakeDamageInfo( dmginfo )
end

function META:SetAntlionType( iAntlionType )
	self:SetNWInt( "antlion_type", iAntlionType )
end

-- Set the time that a claw attack is meant to be applied.
function META:SetAttackData( sSequence, fAttackDelay, fAttackDuration, iMaxDamage, iDistance, iHullSize )
	if( not self:CanClawAttack() ) then return end
	
	iMaxDamage = iMaxDamage or 15
	iDistance = iDistance or 100
	
	self:SetNWString( "m_sAttackSequence", sSequence )
	self:SetNWFloat( "m_fAttackStartTime", CurTime() + fAttackDuration )
	self:SetNWFloat( "m_fAttackEndTime", CurTime() + fAttackDuration )
	self:SetNWFloat( "m_fAttackTime", CurTime() + fAttackDelay )
	
	self.m_tAttackData = self.m_tAttackData or {}
	self.m_tAttackData.Sequence = self:GetNWString( "m_sAttackSequence" )
	self.m_tAttackData.StartTime = self:GetNWFloat( "m_fAttackStartTime" )
	self.m_tAttackData.EndTime = self:GetNWFloat( "m_fAttackEndTime" )
	self.m_tAttackData.AttackTime = self:GetNWFloat( "m_fAttackTime" )
	self.m_tAttackData.MaxDamage = iMaxDamage
	self.m_tAttackData.Distance = iDistance
	self.m_tAttackData.HullSize = iHullSize
end

-- Apply the attack data
function META:DispatchClawAttack()
	if( not self:CanClawAttack() ) then return end
	local tAttackData = self:GetAttackData()
	
	local tracedata = {}
	tracedata.start = self:GetPos() + self:OBBCenter()
	tracedata.endpos = tracedata.start + self:GetForward() * tAttackData.Distance
	tracedata.filter = team.GetPlayers( TEAM_ANTLION )
	
	local trace
	if( tAttackData.HullSize or tAttackData.HullSize <= 0 ) then
		local hullSize = Vector( tAttackData.HullSize, tAttackData.HullSize, tAttackData.HullSize )
		tracedata.mins = hullSize * -0.5
		tracedata.maxs = hullSize * 0.5
		trace = util.TraceHull( tracedata )
	else
		trace = util.TraceLine( tracedata )
	end
	
	if( not trace.Hit or trace.HitWorld ) then return end
	
	local fForceMultiplier = ( 1 / trace.Fraction ) * tAttackData.Distance
	
	local dmginfo = DamageInfo()
	dmginfo:SetMaxDamage( iMaxDamage )
	dmginfo:SetAttacker( self )
	dmginfo:SetInflictor( self )
	dmginfo:SetDamagePosition( trace.HitPos ) -- We may want to change this.
	dmginfo:SetDamageForce( self:GetAimVector() * fForceMultiplier )
	dmginfo:SetDamageType( DMG_SLASH )
	
	self:DispatchTraceAttack( tAttackData.Damage, tAttackData.Trace.StartPos, tAttackData.Trace.HitPos )
end

