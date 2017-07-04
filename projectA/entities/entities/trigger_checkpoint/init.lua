
ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:PassesTriggerFilters( ent )
	if( not ValidEntity( ent ) or not ent:IsMelon() ) then return end
	local owner = ent:GetOwner()
	return ValidEntity( owner ) and owner:IsPlayer() and owner:IsConnected() and ( not owner:HasFinished() )
end

function ENT:StartTouch( ent )
	
	if( not self.CheckpointID or not self:PassesTriggerFilters( ent ) ) then return end
	
	GAMEMODE:PlayerCheckpoint( ent:GetOwner(), self.CheckpointID )
	
end

function ENT:KeyValue( key, value )
	if( key == "checkpoint" ) then
		self.CheckpointID = tonumber( value )
	end
end
