-- Valve C++ to Lua :pseudo:

AddCSLuaFile"shared.lua"

ENT.AutomaticFrameAdvance = true
ENT.Type = "anim"

/*class CPropThumper : public CBaseAnimating
{
public:
	DECLARE_CLASS( CPropThumper, CBaseAnimating )
	DECLARE_DATADESC()

	virtual function Spawn()
	virtual function Precache()
	virtual function Think ()
	virtual function HandleAnimEvent( animevent_t *pEvent )
	virtual function StopLoopingSounds()

	void	InputDisable( inputdata_t &inputdata )
	void	InputEnable( inputdata_t &inputdata )

	void	InitMotorSound()

	void	HandleState()

	void	Thump()

private:
	
	bool m_bEnabled
	int m_iHammerAttachment
	CSoundPatch* m_sndMotor
	EHANDLE m_hRepellantEnt
	int m_iDustScale
	
	COutputEvent	m_OnThumped	// Fired when thumper goes off

	int m_iEffectRadius
}

LINK_ENTITY_TO_CLASS( prop_thumper, CPropThumper )

//-----------------------------------------------------------------------------
// Save/load 
//-----------------------------------------------------------------------------
BEGIN_DATADESC( CPropThumper )
	DEFINE_FIELD( m_bEnabled, FIELD_BOOLEAN ),
	DEFINE_FIELD( m_hRepellantEnt, FIELD_EHANDLE ),
	DEFINE_FIELD( m_iHammerAttachment, FIELD_INTEGER ),
	DEFINE_KEYFIELD( m_iDustScale, FIELD_INTEGER, "dustscale" ),
#if HL2_EPISODIC
	DEFINE_KEYFIELD( m_iEffectRadius, FIELD_INTEGER, "EffectRadius" ),
#endif
	DEFINE_SOUNDPATCH( m_sndMotor ),
	DEFINE_THINKFUNC( Think ),
	DEFINE_INPUTFUNC( FIELD_VOID, "Disable", InputDisable ),
	DEFINE_INPUTFUNC( FIELD_VOID, "Enable", InputEnable ),

	DEFINE_OUTPUT( m_OnThumped, "OnThumped" ),
END_DATADESC()*/

function ENT:IsEnabled()
	return self:GetNWBool("Enabled",self.m_bEnabled)
end
function ENT:SetEnabled( b )
	self.m_bEnabled = b
	self:SetNWBool("Enabled",self.m_bEnabled)
end
function ENT:GetRadius()
	return self:GetNWInt("Radius",self.m_iEffectRadius)
end
function ENT:SetRadius( i )
	self.m_iEffectRadius = i
	self:SetNWInt("Radius",self.m_iEffectRadius)
end


function ENT:Initialize()
	self.m_sModel = self.m_sModel or "models/props_combine/CombineThumper002.mdl"
	if self:GetModel() == "" then
		self:SetModel( self.m_sModel )
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)

	self.m_bEnabled = self.m_bEnabled or true
	self:SetNWBool("Enabled",self.m_bEnabled)
	
	self:NextThink(CurTime())

	local iSequence = self:LookupSequence( "idle" )

	if iSequence != ACT_INVALID then
		self:SetSequence(iSequence)
		self:ResetSequence(iSequence)
		//Do this so we get the nice ramp-up effect.
		self:SetPlaybackRate(math.Rand(0, 1))
		timer.Simple(1, function()
			if ValidEntity(self) then
				self:SetPlaybackRate(1)
			end
		end)
	end

	self.m_iHammerAttachment = self:LookupAttachment( "hammer" )
	
	/*CAntlionRepellant *pRepellant = (CAntlionRepellant*)CreateEntityByName( "point_antlion_repellant" )

	if ( pRepellant )
	{
		pRepellant->Spawn()
		pRepellant->SetAbsOrigin( GetAbsOrigin() )
		pRepellant->SetRadius( self.m_iEffectRadius )

		m_hRepellantEnt = pRepellant
	}*/

	self.m_iDustScale = self.m_iDustScale or 128
	self.m_iEffectRadius = self.m_iEffectRadius or 1000
	self:SetNWInt("Radius",self.m_iEffectRadius)
	--PrintTable(self:GetTable())
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


