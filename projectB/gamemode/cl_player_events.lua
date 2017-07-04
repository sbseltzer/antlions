
/*------------------------------------
	CreateMove
------------------------------------*/
function GM:CreateMove( cmd )
	
	
end


/*------------------------------------
	PlayerBindPress
------------------------------------*/
function GM:PlayerBindPress( ply, bind, pressed )
	
	// using context menu?
	if ( bind:find( "+menu_context" ) ) then
		
		// do team speak
		RunConsoleCommand( ( ( pressed and "+" ) or "-" ) .. "antlion_teamspeak" );
		
		// block
		return true;
		
	// rebel?
	elseif ( ply:IsRebel() ) then
		
		// jumping?
		if ( ( bind:find( "+jump" ) or bind:find( "+speed" ) ) and pressed and ( ply:GetStamina() == 0 ) ) then
			
			// block
			return true;
			
		// attacking
		elseif ( bind:find( "+attack" ) and pressed ) then
			
			// while sprinting or falling or pinned down
			if ( ply:IsSprinting() ) or ( !ply:OnGround() ) or ( CurTime() < ply:GetPinned() ) then
			
				// block shooting
				return true;
			
			end
			
		end
		
	// antlion?
	elseif ( ply:IsAntlion() ) then
		
		// sprinting?
		if ( ply:IsBurrowed() and bind:find( "+speed" ) and pressed ) then
			
			return true;
			
		// ducking?
		elseif ( bind:find( "+duck" ) and pressed and !GAMEMODE:PlayerNearThumper( ply ) ) then
			
			// do burrowing
			RunConsoleCommand( "antlion_burrow" );
			
			// get out of ducking
			RunConsoleCommand( "-duck" );
			
			// block
			return true;
		
		// using zoom?
		elseif ( bind:find( "+zoom" ) and pressed ) then
		
			// do vision
			RunConsoleCommand( ( ( pressed and "+" ) or "-" ) .. "antlion_vision" );
			
			// block
			return true;
		
		// jumping?
		elseif ( bind:find( "+jump" ) and pressed ) then
		
			// No jumping while burrowing or while near a thumper.
			if ( ply:IsBurrowed() or ply:GetFlipped() > CurTime() or ply:GetBurrowingIn() > CurTime() or ply:GetBurrowingOut() > CurTime() ) then
			
				// block
				return true;
				
			end
			local thumper = GAMEMODE:PlayerNearThumper( ply )
			if thumper and thumper:IsEnabled() then
				
				if ( ply:GetPos() - thumper:GetPos() ):Length() <= thumper:GetRadius() - ( thumper:GetRadius() / 5 ) then
					
					return true
					
				end
				
			end
			
		// walking?
		elseif ( ( bind:find( "+moveleft" ) or bind:find( "+moveright" ) or bind:find( "+back" ) ) and pressed ) and ( ply:IsBurrowed() or ply:GetBurrowingIn() > CurTime() or ply:GetBurrowingOut() > CurTime() ) then
			
			// Only forward movement is allowed when burrowing.
			
			// block
			return true;
			
		end
		
	end

end


/*------------------------------------
	PlayerStartVoice
------------------------------------*/
function GM:PlayerStartVoice( ply )

end


/*------------------------------------
	PlayerEndVoice
------------------------------------*/
function GM:PlayerEndVoice( ply )

end

--[[
// Draw antlion body model
function GM:DrawAntlionModel( ply, ent )
	
	if ent:GetSequence() != ply:GetSequence() then
		
		ent:SetSequence( ply:GetSequence() )
		
	end
	
	if ent:GetModel() != ply:GetModel() then
		
		ent:SetModel( ply:GetModel() )
		
	end
		
	if ent:GetRenderOrigin() != ply:GetRenderOrigin() then
	
		ent:SetRenderOrigin( ply:GetRenderOrigin() )
		
	end
	
	if ent:GetRenderAngles() != ply:GetRenderAngles() then
		
		ent:SetRenderAngles( ply:GetRenderAngles() )
		
	end
	
end
]]

// Thanks ralle for helping me with this tricky rendering!
local drawException
function GM:PlayerDrawAntlion( ply, model )
	if !IsValid( model ) or ply != GetViewEntity() or ply:GetDrawBody() or !ply:Alive() or ply:IsBurrowed() then
		return
	end
	// I was getting a C Stack Overflow by using DrawModel. This prevents it.
	if drawException then return end
	drawException = true
	--model:SetSequence( ply:GetSequence() )
	--model:SetPlaybackRate( ply:GetPlaybackRate() )
	--model:SetPoseParameter( "move_yaw", ply:GetPoseParameter( "move_yaw" ) )
	model:SetRenderAngles( ply:GetRenderAngles() or ply:GetAngles() )
	model:SetRenderOrigin( ply:GetRenderOrigin() or ply:GetPos() )
	model:DrawModel()
	drawException = nil
	// This will cut off drawing at the ground when burrowing in and out
	if ply:GetBurrowingIn() > CurTime() or ply:GetBurrowingOut() > CurTime() then
		local boundsMin, boundsMax = unpack( model.Bounds )
		model:SetRenderBoundsWS( ply:GetPos() + Vector( boundsMin.x, boundsMin.y, ply:GetPos().z ), ply:GetPos() + boundsMax )
	--else
		--model:SetRenderBounds( unpack( model.Bounds ) )
	end
end


/*------------------------------------
	ShouldDrawLocalPlayer
------------------------------------*/
function GM:ShouldDrawLocalPlayer()
	
	// This will allow our shadow to draw. We'll stop the model from showing up in a different hook.
	// BUGBUG: This makes decals visible on the player's mesh. Do we have a way of disabling this?
	return LocalPlayer():IsAntlion()
	
end

/*------------------------------------
	PrePlayerDraw
------------------------------------*/
function GM:PrePlayerDraw( ply )
	
	// We don't want our player model to draw.
	if ply:IsAntlion() and ply == LocalPlayer() and ply == GetViewEntity() and !ply:GetDrawBody() and ply:Alive() and !ply:IsBurrowed() then
		
		render.SetBlend( 0.00001 )
		
		return
		
	end
	
	return self.BaseClass:PrePlayerDraw( ply )
	
end


/*------------------------------------
	PostPlayerDraw
------------------------------------*/
function GM:PostPlayerDraw( ply )

	if ply:IsAntlion() and ply == LocalPlayer() and ply == GetViewEntity() and !ply:GetDrawBody() and ply:Alive() and !ply:IsBurrowed() then
		
		render.SetBlend( 1 )
		
		gamemode.Call( "PlayerDrawAntlion", ply, ply.AntlionModel )
		
		return true
		
	end
	
	return self.BaseClass:PostPlayerDraw( ply )
	
end

// The following is by foszor

// storage
local WalkTimer = 0;
local VelSmooth = 0;
local LastStrafeRoll = 0;
local VIEW_BONE = 1 -- The chest bone
local hSub = 40 -- subtracted view height

/*------------------------------------
	CalcView - by foszor
------------------------------------*/
function GM:CalcView( ply, origin, angle, fov )
	
	// not antlion?
	if ( !ply:IsAntlion() ) then
	
		// base
		return self.BaseClass:CalcView( ply, origin, angle, fov );
		
	// hasn't been calculated yet?
	elseif ( !ply.HeadPosition ) then
		
		// base
		return self.BaseClass:CalcView( ply, origin, angle, fov );
		
	// dead?
	elseif ( !ply:Alive() ) then
	
		// base
		return self.BaseClass:CalcView( ply, origin, angle, fov );
		
	// burrowed?
	elseif ( ply:IsBurrowed() ) then
	
		// base
		origin = Vector( origin.x, origin.y, origin.z );
		return self.BaseClass:CalcView( ply, origin, angle, fov );
		
	end
	
	local flipped = ( ply:GetFlipped() > CurTime() );
	
	// get velocity and angles
	local vel = ply:GetVelocity();
	local ang = ply:EyeAngles();
	
	// calculate velocity smoothing
	VelSmooth = math.Clamp( VelSmooth * 0.9 + vel:Length() * 0.1, 0, 700 );
	
	// update timer
	WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.03;
	
	// roll on strafe
	LastStrafeRoll = ( LastStrafeRoll * 3 ) + ( ang:Right():DotProduct( vel ) * 0.0001 * VelSmooth * 0.3 );
	LastStrafeRoll = LastStrafeRoll * 0.25;
	angle.roll = angle.roll + LastStrafeRoll;
	
	// step bobbing
	if ( ply:GetGroundEntity() != NULL ) then	
	
		// adjust angle
		angle.roll = angle.roll + math.sin( WalkTimer ) * VelSmooth * 0.000002 * VelSmooth;
		angle.pitch = angle.pitch + math.cos( WalkTimer * 0.6 ) * VelSmooth * 0.000004 * VelSmooth;
		angle.yaw = angle.yaw + math.cos( WalkTimer ) * VelSmooth * 0.000002 * VelSmooth;
		
	else
		
		ply.FlightRoll = angle.roll * 30
		
	end
	
	if ( flipped ) then
	
		angle = ply.HeadAngles * -1;
		
	end
	
	ply.HeadPosition, ply.HeadAngles = ply:GetBonePosition( VIEW_BONE );
	ply.HeadPosition = ply.HeadPosition - ply:GetForward() * 15
	
	origin = Vector( ply.HeadPosition.x, ply.HeadPosition.y, origin.z );
	
	// override
	return self.BaseClass:CalcView( ply, origin, angle, 90 );

end
