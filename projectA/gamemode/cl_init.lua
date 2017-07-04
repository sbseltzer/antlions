
include( "shared.lua" )

function GM:PlayerBindPress( ply, bind, pressed )
	-- No flashlight for you!
	if( ply:IsAntlion() and string.find( bind, "impulse 100" ) ) then return true end
end

local ANTLION_LEG_BONES = {
	25, -- Antlion.LegL1_Bone
	26, -- Antlion.LegL2_Bone
	27, -- Antlion.LegL3_Bone
	29, -- Antlion.LegR1_Bone
	30, -- Antlion.LegR2_Bone
	31  -- Antlion.LegR3_Bone
}

function GM:OnEntityCreated( ent )
	if( ValidEntity( ent ) ) then
		if( ent:GetClass() == "class C_HL2MPRagdoll" and ValidEntity( ent:GetOwner() ) ) then
			ent:SetSkin( ent:GetOwner():GetSkin() )
		end
	end
end

local function isLegBone( iBone )
	return ( iBone >= 25 and iBone <= 27 ) or ( iBone >= 29 and iBone <= 31 )
end

function GM:RemoveAntlionViewModel()
	local ply = LocalPlayer()
	if( ply.ViewModel ) then
		SafeRemoveEntity( ply.ViewModel )
		ply.ViewModel = nil
	end
end

function GM:SpawnAntlionViewModel()
	local ply = LocalPlayer()
	GAMEMODE:RemoveAntlionViewModel()
	
	-- ClientsideModel is garbage collected, so we need to keep a reference to it.
	ply.ViewModel = ClientsideModel( "models/antlion.mdl", RENDERGROUP_BOTH )
	ply.ViewModel:SetPos( ply:GetPos() )
	ply.ViewModel:SetAngles( ply:GetAngles() )
	--ply.ViewModel:SetParent( ply )
	--ply.ViewModel:AddEffects( EF_BONEMERGE )
	
	-- Define a BuildBonePositions function for it so we can hide everything but the front legs.
	ply.ViewModel.BuildBonePositions = function( self, iNumBones, iNumPhysBones )
		for iBone = 0, iNumBones do
			if( not isLegBone( iBone ) ) then
				local vMatrix = self:GetBoneMatrix( iBone )
				if( vMatrix ) then
					vMatrix:Scale( Vector( 0, 0, 0 ) )
					self:SetBoneMatrix( iBone, vMatrix )
				end
			end
		end
	end
	ply.BuildBonePositions = function( self, iNumBones, iNumPhysBones )
		for iBone = 0, iNumBones do
			if( not isLegBone( iBone ) ) then
				local vMatrix = self:GetBoneMatrix( iBone )
				if( vMatrix ) then
					vMatrix:Scale( Vector( 0, 0, 0 ) )
					self:SetBoneMatrix( iBone, vMatrix )
				end
			end
		end
	end
end

function GM:RenderAntlionViewModel( ply )
	local model = ply.ViewModel
	model:SetRenderAngles( ply:GetRenderAngles() or ply:GetAngles() )
	model:SetRenderOrigin( ply:GetRenderOrigin() or ply:GetPos() )
	model:SetSequence( ply.CalcSeqOverride )
end

function GM:PostPlayerDraw( ply )
	if ply == LocalPlayer() and ply:IsAntlion() and ply:Alive() then
		--render.SetBlend( 1 )
		--gamemode.Call( "PlayerDrawAntlion", ply, ply.ViewModel )
		gamemode.Call( "RenderAntlionViewModel", ply )
		return
	end
	return self.BaseClass:PostPlayerDraw( ply )
end

function GM:ShouldDrawLocalPlayer()
	return LocalPlayer():IsAntlion()
end

--[[
local drawException
function GM:PlayerDrawAntlion( ply, model )
	if !IsValid( model ) or ply != GetViewEntity() or ply:GetDrawBody() or !ply:Alive() then
		return
	end
	-- I was getting a C Stack Overflow by using DrawModel. This prevents it.
	if drawException then return end
	drawException = true
	model:SetRenderAngles( ply:GetRenderAngles() or ply:GetAngles() )
	model:SetRenderOrigin( ply:GetRenderOrigin() or ply:GetPos() )
	model:DrawModel()
	drawException = nil
end

-- Hide your own body
function GM:PrePlayerDraw( ply )
	-- We don't want our player model to draw.
	if ply == LocalPlayer() and ply:IsAntlion() and ply:Alive() then
		render.SetBlend( 0.00001 )
		return
	end
	return self.BaseClass:PrePlayerDraw( ply )
end

]]

-- Storage
local fWalkTimer = 0;
local fVelSmooth = 0;
local LastStrafeRoll = 0;
local VIEW_BONE = 1 -- The chest bone

function GM:CalcView( ply, origin, angle, fov )

	if( ply:IsAntlion() ) then
		fov = 90
	end
	
	if( !ply:IsAntlion() or !ply:Alive() ) then
		return self.BaseClass:CalcView( ply, origin, angle, fov )
	end
	
	local vel = ply:GetVelocity()
	local ang = ply:EyeAngles()
	
	-- Calculate velocity smoothing
	fVelSmooth = math.Clamp( fVelSmooth * 0.9 + vel:Length() * 0.1, 0, 700 )
	
	-- Update timer
	fWalkTimer = fWalkTimer + fVelSmooth * FrameTime() * 0.03
	
	-- Roll on strafe
	LastStrafeRoll = ( LastStrafeRoll * 3 ) + ( ang:Right():DotProduct( vel ) * 0.0001 * fVelSmooth * 0.3 )
	LastStrafeRoll = LastStrafeRoll * 0.25
	angle.roll = angle.roll + LastStrafeRoll
	
	-- Step bobbing
	if( ply:GetGroundEntity() != NULL ) then	
	
		-- Adjust angle
		angle.roll = angle.roll + math.sin( fWalkTimer ) * fVelSmooth * 0.000002 * fVelSmooth
		angle.pitch = angle.pitch + math.cos( fWalkTimer * 0.6 ) * fVelSmooth * 0.000004 * fVelSmooth
		angle.yaw = angle.yaw + math.cos( fWalkTimer ) * fVelSmooth * 0.000002 * fVelSmooth
		
	end
	
	ply.HeadPosition = ply:GetBonePosition( VIEW_BONE )
	ply.HeadPosition = ply.HeadPosition - ply:GetForward() * 15
	
	origin = Vector( ply.HeadPosition.x, ply.HeadPosition.y, origin.z )
	
	return self.BaseClass:CalcView( ply, origin, angle, fov )

end

--[[
function GM:HUDShouldDraw( sName )
end

function GM:HUDDrawTargetID()
end
]]
