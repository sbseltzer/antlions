
function GM:HandlePlayerJumping( ply, velocity )
	
	local bRet = self.BaseClass:HandlePlayerJumping( ply, velocity )
	
	if( ply:IsSurvivor() ) then
		return bRet
	end
	
	if ply.m_bJumping then
		ply.CalcSeqOverride = ply:LookupSequence( "jump_glide" )
		return true
	end
	
	return false
	
end

function GM:HandlePlayerDucking( ply, velocity )

	if( ply:IsSurvivor() ) then
		return self.BaseClass:HandlePlayerDucking( ply, velocity )
	end

	return false
	
end

function GM:HandlePlayerSwimming( ply, velocity )

	if( ply:IsSurvivor() ) then
		return self.BaseClass:HandlePlayerSwimming( ply, velocity )
	end
	
	if ( ply:WaterLevel() < 2 ) then 
		ply.m_bInSwim = false
		return false 
	end
	
	ply.CalcSeqOverride = ply:LookupSequence( "drown" )
		
	ply.m_bInSwim = true
	return true
	
end

function GM:HandlePlayerDriving( ply )

	if( ply:IsSurvivor() ) then
		return self.BaseClass:HandlePlayerDriving( ply, velocity )
	end
	
	return false
	
end

/*---------------------------------------------------------
   Name: gamemode:UpdateAnimation( )
   Desc: Animation updates (pose params etc) should be done here
---------------------------------------------------------*/
function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )	

	if( ply:IsSurvivor() ) then
		return self.BaseClass:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	end
	
	local len = velocity:Length()
	local movement = 1.0
	
	if ( len > 0.2 ) then
		movement =  ( len / maxseqgroundspeed )
	end
	
	rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( ply:WaterLevel() >= 2 ) then
		rate = math.max( rate * 0.1, 0.1 )
	elseif ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then 
		rate = len * 0.00001;
	elseif ( !ply:IsOnGround() and len >= 1000 ) then 
		rate = 0.1;
	end
	
	ply:SetPoseParameter( "move_yaw", ply:GetVelocity():Angle().yaw )
	ply:SetPoseParameter( "aim_pitch", ply:GetAimVector():Angle().pitch )
	ply:SetPlaybackRate( rate )
	
	if( CLIENT and ply == LocalPlayer() ) then
		
		ply.ViewModel:SetPoseParameter( "move_yaw", ply:GetPoseParameter( "move_yaw" ) )
		ply.ViewModel:SetPlaybackRate( rate )
	end
	
end

function GM:CalcMainActivity( ply, velocity )	

	if( ply:IsSurvivor() ) then
		return self.BaseClass:CalcMainActivity( ply, velocity )
	end
	
	ply.CalcIdeal = -1
	ply.CalcSeqOverride = ply:LookupSequence( "Idle" )
	
	if self:HandlePlayerDriving( ply ) or
		self:HandlePlayerJumping( ply, velocity ) or
		self:HandlePlayerDucking( ply, velocity ) or
		self:HandlePlayerSwimming( ply, velocity ) then
		
	elseif( ply:GetAttackData() ) then
		
		ply.CalcSeqOverride = ply:LookupSequence( ply:GetAttackData().Sequence )
		
	else
		
		local len2d = velocity:Length2D()
		
		if len2d > 210 then
			if( ply:Health() < ply:GetMaxHealth() / 2 )
				ply.CalcSeqOverride = ply:LookupSequence( "RunAgitated" )
			else
				ply.CalcSeqOverride = ply:LookupSequence( "run_all" )
			end
		elseif len2d > 0.5 then
			ply.CalcSeqOverride = ply:LookupSequence( "walk_all" )
		end
		
	end
	
	return ply.CalcIdeal, ply.CalcSeqOverride

end

-- it is preferred you return ACT_MP_* in CalcMainActivity, and if you have a specific need to not tranlsate through the weapon do it here
function GM:TranslateActivity( ply, act )

	if( ply:IsSurvivor() ) then
		return self.BaseClass:TranslateActivity( ply, act )
	end
	
	return ACT_HL2MP_IDLE

end

function GM:DoAnimationEvent( ply, event, data )

	if( ply:IsSurvivor() ) then
		return self.BaseClass:DoAnimationEvent( ply, event, data )
	end
	
	if event == PLAYERANIMEVENT_JUMP then
	
		ply.m_bJumping = true
		ply.m_bFirstJumpFrame = true
		ply.m_flJumpStartTime = CurTime()
		
		ply:AnimRestartMainSequence()
		
		return ACT_INVALID
		
	end

	return nil
	
end
