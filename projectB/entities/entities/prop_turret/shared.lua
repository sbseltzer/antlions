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
	self:GetNWEntity("User",e)
end

function ENT:Initialize()

	self:SetModel( "models/props_combine/bunker_gun01.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)

	self:NextThink(CurTime())

	local iSequence = self:LookupSequence( "idle_inactive" )

	if iSequence != ACT_INVALID then
		self:SetSequence(iSequence)
		self:ResetSequence(iSequence)
	end
	
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
	
	self.Flash1 = self:LookupBone( "Bunker_Gun.Flash1" )
	self.Flash2 = self:LookupBone( "Bunker_Gun.Flash2" )
	self.Flash3 = self:LookupBone( "Bunker_Gun.Flash3" )
	
end

local pitchLimit = 30
local yawLimit = 60
local ENABLE_TIME = 35/30
local DISABLE_TIME = 41/30

function ENT:Use( activator, caller )
	
	if !activator:IsPlayer() then return end
	
	local iSeq = 0
	
	if !self:IsEnabled() then
		
		iSeq = self:LookupSequence( "activate" )
		
		self:SetUser( activator )
		self:SetChanging( CurTime() + ENABLE_TIME )
		self:SetEnabled( true )
		
	elseif activator == self:GetUser() then
	
		iSeq = self:LookupSequence( "retract" )
		
		self:SetUser( NULL )
		self:SetChanging( CurTime() + DISABLE_TIME )
		self:SetEnabled( false )
		
	end
	
	self:SetSequence( iSeq )
	self:ResetSequence( iSeq )
	
end

function ENT:Think()
	
	local user = self:GetUser()
	
	local iSeq = self:LookupSequence( "idle" )
	
	if user then
		
		if self:GetChanging() > CurTime() then
			iSeq = self:LookupSequence( "activate" )
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
				--self:EmitSound("")
				self:ShootBullet()
			end
			
			iSeq = self:LookupSequence( "fire" )
			
		end
		
		self:SetSequence( iSeq )
		
		local aim = user:GetViewAngles()
		self:UpdatePoseParameters( aim.pitch, aim.yaw )
		
	else
	
		if self:GetChanging() > CurTime() then
			iSeq = self:LookupSequence( "idle_inactive" )
			self:SetSequence( iSeq )
			self:ResetSequence( iSeq )
		end
		
	end
	
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

function ENT:GetAimVector()

	return (self:GetAngles() + Angle( self.LastPitch, self.LastYaw, 0 )):Forward()
	
end

function ENT:GetShootPos()
	
	return self:GetBonePosition( self.Flash1 ) + self:GetAimVector() * 50
	
end

function ENT:ShootBullet()
	
	if !self:IsEnabled() or !self:GetUser() or self:GetNextShootTime() > CurTime() then return end
	
	local poses = {}
	poses[1] = self:GetBonePosition( self.Flash1 )
	poses[2] = self:GetBonePosition( self.Flash2 )
	poses[3] = self:GetBonePosition( self.Flash3 )
	
	local MuzzleEffect = EffectData() -- AirboatMuzzleFlash
	MuzzleEffect:SetStart( poses[ math.random( 1, 3 ) ] )
	MuzzleEffect:SetOrigin( poses[ math.random( 1, 3 ) ] )
	MuzzleEffect:SetScale( math.Rand( 0, 1 ) )
	MuzzleEffect:SetMagnitude( math.Rand( 10, 15 ) )
	util.Effect( "AirboatMuzzleFlash", MuzzleEffect )
	
	local TracerEffect = EffectData() -- AR2Tracer
	TracerEffect:SetStart( poses[1] )
	TracerEffect:SetOrigin( poses[1] )
	TracerEffect:SetScale( math.Rand( 0, 1 ) )
	TracerEffect:SetMagnitude( math.Rand( 10, 15 ) )
	util.Effect( "AR2Tracer", TracerEffect )
	
	local bullet = {}
	bullet.Src			= self:GetShootPos()
	bullet.Attacker 	= self:GetUser()
	bullet.Dir			= self:GetAimVector()
	bullet.Spread		= Vector( 0.01, 0.01, 0 )
	bullet.Num			= 1
	bullet.Damage		= 1
	bullet.Force		= 2
	bullet.Tracer		= 1	
	bullet.TracerName	= "Tracer"
	bullet.Callback	= function ( attacker, tr, dmginfo )
		if !tr.Hit then return end
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
	util.PrecacheModel "models/props_combine/CombineThumper001a.mdl"
	util.PrecacheModel "models/props_combine/CombineThumper002.mdl"
	util.PrecacheSound "coast.thumper_hit"
	util.PrecacheSound "coast.thumper_ambient"
	util.PrecacheSound "coast.thumper_dust"
	util.PrecacheSound "coast.thumper_startup"
	util.PrecacheSound "coast.thumper_shutdown"
	util.PrecacheSound "coast.thumper_large_hit"
end

function ENT:InitMotorSound()
	self.m_sndMotor = CreateSound(self, "coast.thumper_ambient")

	self.m_sndMotor:PlayEx(1, 100)
end

function ENT:HandleState()
	if !self.m_bEnabled then
		self:SetPlaybackRate(math.max(self:GetPlaybackRate() - 0.005, 0))
	else
 		self:SetPlaybackRate(math.min(self:GetPlaybackRate() + 0.02, 1))
	end

	//(CSoundEnvelopeController::GetController()).Play( m_sndMotor, 1, self:GetPlaybackRate() * 100 )
end

function ENT:Think()
	self:NextThink(CurTime())
	if self:GetCycle() < (self.LastCycle or 0) and self:GetPlaybackRate() > 0.2 then
		self:Thump()
	end
	self.LastCycle = self:GetCycle()

	if !self.m_sndMotor then
		self:InitMotorSound()
	else
		self:HandleState()
	end
	return true
end

function ENT:Thump()
	if self.m_iHammerAttachment then
		local pos = self:GetAttachment(self.m_iHammerAttachment).Pos
		local data = EffectData()
		data:SetEntity(self)
		data:SetOrigin(pos)
		data:SetScale(self.m_iDustScale * self:GetPlaybackRate())
		util.Effect("ThumperDust", data)
		util.ScreenShake(pos, GAMEMODE.ThumperShakeScale * self:GetPlaybackRate(), self:GetPlaybackRate(), self:GetPlaybackRate() / 2, self.m_iEffectRadius * self:GetPlaybackRate())
	end

	self:EmitSound "coast.thumper_dust"
	//CSoundEnt::InsertSound ( SOUND_THUMPER, GetAbsOrigin(), self.m_iEffectRadius * self:GetPlaybackRate(), 1.5, this )

	if self:GetPlaybackRate() < 0.7 then return end

	if self.m_iDustScale == 128 then
		self:EmitSound "coast.thumper_hit"
	else
		self:EmitSound "coast.thumper_large_hit"
	end
	gamemode.Call( "OnThumperThumped", self )
end

function ENT:OnRemove()
	self:StopLoopingSounds()
end

//-----------------------------------------------------------------------------
// Shuts down sounds
//-----------------------------------------------------------------------------
function ENT:StopLoopingSounds()
	if self.m_sndMotor then
		self.m_sndMotor:Stop()
	end
end

/*function ENT:InputDisable( inputdata_t &inputdata )
	m_bEnabled = false
	
	EmitSound( "coast.thumper_shutdown" )
	
	if ( m_hRepellantEnt )
	{
		variant_t emptyVariant
		m_hRepellantEnt->AcceptInput( "Disable", this, this, emptyVariant, 0 )
	}
end

function ENT:InputEnable( inputdata_t &inputdata )
	m_bEnabled = true

	EmitSound( "coast.thumper_startup" )

	if ( m_hRepellantEnt )
	{
		variant_t emptyVariant
		m_hRepellantEnt->AcceptInput( "Enable", this, this, emptyVariant, 0 )
	}
end*/

function ENT:AcceptInput(name)
	if name == "Enable" then 
		self.m_bEnabled = true
		self:SetNWBool("Enabled",self.m_bEnabled)
	elseif name == "Disable" then 
		self.m_bEnabled = false
		self:SetNWBool("Enabled",self.m_bEnabled)
	elseif name == "Toggle" then 
		self.m_bEnabled = !self.m_bEnabled
		self:SetNWBool("Enabled",self.m_bEnabled)
	end
end
function ENT:KeyValue(key,value)
	if key == "model" then
		if self.m_sModel then
			self:SetModel(value)
			self:PhysicsInit(SOLID_VPHYSICS)
		end
		self.m_sModel = value
	elseif key == "dustscale" then
		self.i_mDustScale = value
	elseif key == "EffectRadius" then
		self.i_mEffectRadius = value
		self:SetNWInt("Radius",self.m_iEffectRadius)
	elseif key == "angles" then
		self:SetAngles( Angle( unpack( string.Explode( " ", value ) ) ) )
	end
end


