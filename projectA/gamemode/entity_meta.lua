
local META = FindMetaTable( "Entity" )
assert( META )

-- Returns true if player is survivor
function META:IsSurvivor()
	return self:IsPlayer() and self:Team() == TEAM_SURVIVOR or self:GetClass() == "npc_citizen" and self:GetNWBool( "m_bIsActingAsPlayer" )
end

-- Returns true if player is antlion
function META:IsAntlion()
	return self:IsPlayer() and self:Team() == TEAM_ANTLION or self:GetClass() == "npc_antlion" and self:GetNWBool( "m_bIsActingAsPlayer" )
end

function META:GetAntlionType()
	return self:GetNWInt( "antlion_type", ANTLION_NORMAL )
end

-- Returns true if the entity is less than fHeight units above the ground. Entity:OnGround() doesn't appear to work in come cases.
function META:IsAboveGround( fHeight )
	local pos = self:GetPos()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos - ( vector_up * fHeight )
	tracedata.filter = self
	local trace = util.TraceLine( tracedata )
	return trace.Hit
end