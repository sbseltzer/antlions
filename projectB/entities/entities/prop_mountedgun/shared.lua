-- Valve C++ to Lua :pseudo:

AddCSLuaFile"shared.lua"

ENT.AutomaticFrameAdvance = true
ENT.Type = "anim"

function ENT:GetNextShootTime()
	return self:GetNWInt("NextShoot",0)
end
function ENT:SetNextShootTime(i)
	self:SetNWInt("NextShoot",i)
end

function ENT:GetChanging()
	return self:GetNWInt("Changing",0)
end
function ENT:SetChanging( i )
	self:SetNWInt("Changing",i)
end

function ENT:IsEnabled()
	return self:GetNWBool("Enabled",false)
end
function ENT:SetEnabled( b )
	self:SetNWBool("Enabled",b)
end

function ENT:GetUser()
	return self:GetNWEntity("User",NULL)
end
function ENT:SetUser( e )
	if !e:IsPlayer() then return end
	self:GetNWEntity("User",e)
end

--[[
// Just an idea
ENT.TranslateKeyValues = {}
ENT.TranslateKeyValues["num"] = function(ent,key,value)
	
end
]]

function ENT:GetAimVector()

	return (self:GetAngles() + Angle( self.LastPitch, self.LastYaw, 0 )):Forward()
	
end

function ENT:GetShootPos()
	
	return self:GetBonePosition( self.Flash1 ) + self:GetAimVector() * 50
	
end

function ENT:Initialize()

	self:SetModel( "models/props_combine/bunker_gun01.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)

	self:NextThink(CurTime())
	
	self.SequenceID = {}
	self.SequenceID.idle = self:LookupSequence( "idle" )
	self.SequenceID.idle_inactive = self:LookupSequence( "idle_inactive" )
	self.SequenceID.activate = self:LookupSequence( "activate" )
	self.SequenceID.retract = self:LookupSequence( "retract" )
	self.SequenceID.fire = self:LookupSequence( "fire" )
	
	self.LastYaw = 0
	self.LastPitch = 0
	
	self.Flash1 = self:LookupBone( "Bunker_Gun.Flash1" )
	self.Flash2 = self:LookupBone( "Bunker_Gun.Flash2" )
	self.Flash3 = self:LookupBone( "Bunker_Gun.Flash3" )
	
	if self.SequenceID.idle_inactive != ACT_INVALID then
		self:SetSequence( self.SequenceID.idle_inactive )
		self:ResetSequence( self.SequenceID.idle_inactive )
	end
	
	if self.attachsprites == 0 then
	
		local sprite1, sprite2 = ents.Create( "env_sprite" ), ents.Create( "env_sprite" )
		
		sprite1:SetParent( self )
		sprite1:Fire( "SetParentAttachment", "light" )
		sprite1:SetKeyValue( "renderamt", 200 )
		sprite1:SetKeyValue( "rendermode", 5 )
		sprite1:SetKeyValue( "scale", 1 )
		sprite1:SetKeyValue( "model", "materials/Sprites/blueflare1.vmt" )
		sprite1:SetKeyValue( "disablereceiveshadows", 1 )
		
		sprite2:SetParent( self )
		sprite2:Fire( "SetParentAttachment", "light" )
		sprite2:SetKeyValue( "renderamt", 75 )
		sprite2:SetKeyValue( "rendermode", 5 )
		sprite2:SetKeyValue( "scale", 0.25 )
		sprite2:SetKeyValue( "model", "materials/Sprites/blueflare1.vmt" )
		sprite2:SetKeyValue( "disablereceiveshadows", 1 )
		
		self.Sprite1 = sprite1
		self.Sprite2 = sprite2
		
	end
	
	if self.attachspot == 0 then
	
		local spotlight = ents.Create( "point_spotlight" )
		spotlight:SetPos( self:GetShootPos() )
		spotlight:SetAngles( self:GetAimVector():Angle() )
		spotlight:SetParent( self )
		spotlight:Fire( "SetParentAttachment", "light" )
		spotlight:SetKeyValue( "rendercolor", "147 226 240" )
		spotlight:SetKeyValue( "spawnflags", "2" )
		spotlight:SetKeyValue( "spotlightlength", "1024" )
		spotlight:SetKeyValue( "spotlightwidth", "100" )
		
		self.Spotlight = spotlight
	
	end
	
end

local pitchLimit = 30
local yawLimit = 60
local ENABLE_TIME = 35/30
local DISABLE_TIME = 41/30

function ENT:Use( activator, caller )
	
	if !activator:IsPlayer() then return end
	
	local iSeq = 0
	
	if !self:IsEnabled() then return end
	
	if !self:GetUser() then
		
		iSeq = self.SequenceID.activate
		
		self:SetUser( activator )
		self:SetChanging( CurTime() + ENABLE_TIME )
		self:SetEnabled( true )
		
	elseif activator == self:GetUser() then
	
		iSeq = self.SequenceID.retract
		
		self:SetUser( NULL )
		self:SetChanging( CurTime() + DISABLE_TIME )
		self:SetEnabled( false )
		
	end
	
	self:SetSequence( iSeq )
	self:ResetSequence( iSeq )
	
end

function ENT:Think()
	
	if !self:IsEnabled() then return end
	
	local user = self:GetUser()
	
	local iSeq = self.SequenceID.idle
	
	if user then
		
		if self:GetChanging() > CurTime() then
			iSeq = self.SequenceID.activate
			self:SetSequence( iSeq )
			return
		end
		
		if ( user:GetPos() - self:GetPos() ):Length() > 100 then
		
			self:SetUser( NULL )
			self:SetChanging( CurTime() + DISABLE_TIME )
			self:SetEnabled( false )
			return
			
		end
		
		if user:KeyDown( IN_ATTACK ) then
			
			if self:GetNextShootTime() < CurTime() then
				self:SetNextShootTime( CurTime() + 1 )
				self:ShootBullet()
			end
			
			iSeq = self.SequenceID.fire
			
		end
		
		self:SetSequence( iSeq )
		
		local aim = user:GetViewAngles() --user:GetAimVector():Angle() --user:WorldToLocalAngles( )
		self:UpdatePoseParameters( aim.pitch, aim.yaw )
		
	else
	
		if self:GetChanging() > CurTime() then
			iSeq = self.SequenceID.idle_inactive
			self:SetSequence( iSeq )
			self:ResetSequence( iSeq )
		end
		
	end
	
	return true
	
end

function ENT:UpdatePoseParameters( pitch, yaw )
	
	self.LastPitch = self.LastPitch or self:GetPoseParameter( "aim_pitch" )
	self.LastYaw = self.LastYaw or self:GetPoseParameter( "aim_yaw" )
	
	local newPitch = math.Clamp( Lerp( 0.25, self.LastPitch, pitch ), -pitchLimit, pitchLimit )
	local newYaw = math.Clamp( Lerp( 0.25, self.LastYaw, yaw ), -yawLimit, yawLimit ) 
	
	self.LastPitch = newPitch
	self.LastYaw = newYaw
	
	self:SetPoseParameter( "aim_pitch", newPitch )
	self:SetPoseParameter( "aim_yaw", newYaw )
	
end

function ENT:GetFlashPos( i )
	
	return self:GetBonePosition( self["Flash"..i] )
	
end

function ENT:MuzzleFlash()
	
	local MuzzleEffect = EffectData() -- AirboatMuzzleFlash
	MuzzleEffect:SetStart( self:GetFlashPos( math.random( 1, 3 ) ) )
	MuzzleEffect:SetOrigin( self:GetFlashPos( math.random( 1, 3 ) ) )
	MuzzleEffect:SetScale( math.Rand( 0, 1 ) )
	MuzzleEffect:SetMagnitude( math.Rand( 10, 15 ) )
	util.Effect( "AirboatMuzzleFlash", MuzzleEffect )
	
end

--[[
function ENT:ShootTracer()
	
	local TracerEffect = EffectData() -- AR2Tracer
	TracerEffect:SetStart( self:GetFlashPos( 1 ) )
	TracerEffect:SetOrigin( self:GetFlashPos( 1 ) )
	TracerEffect:SetScale( math.Rand( 0, 1 ) )
	TracerEffect:SetMagnitude( math.Rand( 10, 15 ) )
	util.Effect( "AR2Tracer", TracerEffect )
	
end
]]

function ENT:ShootBullet()
	
	if !self:IsEnabled() or !self:GetUser() or self:GetNextShootTime() > CurTime() then return end
	
	self:MuzzleFlash()
	--self:ShootTracer()
	--self:EmitSound( "???" )
	
	local bullet = {}
	bullet.Src			= self:GetShootPos()
	bullet.Attacker 	= self:GetUser()
	bullet.Dir			= self:GetAimVector()
	bullet.Spread		= Vector( unpack( string.Explode( " ", self.spread ) ) ) or Vector( 0.01, 0.01, 0 )
	bullet.Num			= self.num or 1
	bullet.Damage		= self.damage or math.Rand(1,3)
	bullet.Force		= self.force or 2
	bullet.Tracer		= self.num or 1
	bullet.TracerName	= self.tracer or "AR2Tracer"
	bullet.Callback	= function ( attacker, tr, dmginfo )
		if !tr.Hit or tr.HitSky or tr.HitNoDraw then return end
		local ImpactEffect = EffectData() -- AR2Impact
		ImpactEffect:SetStart( tr.HitPos )
		ImpactEffect:SetOrigin( tr.HitPos )
		ImpactEffect:SetScale( math.Rand( 0, 1 ) )
		ImpactEffect:SetMagnitude( math.Rand( 10, 15 ) )
		ImpactEffect:SetNormal( tr.HitNormal )
		util.Effect( "AR2Impact", ImpactEffect )
	end
	
end

function ENT:Precache()
	util.PrecacheModel "models/props_combine/bunker_gun01.mdl"
	---util.PrecacheSound "???"
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Sprite1)
	SafeRemoveEntity(self.Sprite2)
	SafeRemoveEntity(self.Spotlight)
end

function ENT:AcceptInput(name)
	if name == "Enable" then 
		self:SetEnabled( true )
	elseif name == "Disable" then 
		self:SetEnabled( false )
	elseif name == "Toggle" then 
		self:SetEnabled( !self:IsEnabled() )
	end
end
function ENT:KeyValue(key,value)
	if key == "attachsprites" or key == "attachspot" or key == "damage" or key == "tracer" or key == "num" or key == "force" or key == "spread" then
		self[key] = value
	end
end


