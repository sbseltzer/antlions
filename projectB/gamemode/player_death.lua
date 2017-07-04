
// Translate damage scale using hitbox enumerations.

local HitBoxTranslateDamage = {}

HitBoxTranslateDamage.Rebel = {}
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_SPINE] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_SPINE1] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_SPINE2] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_NECK] = 2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_HEAD] = 2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_UPPERARM] = 0.8
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_UPPERARM] = 0.8
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_CLAVICLE] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_CLAVICLE] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_FOREARM] = 0.5
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_FOREARM] = 0.5
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_HAND] = 0.2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_HAND] = 0.2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_THIGH] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_THIGH] = 1
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_CALF] = 0.8
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_CALF] = 0.8
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_FOOT] = 0.2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_FOOT] = 0.2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_L_TOE] = 0.2
HitBoxTranslateDamage.Rebel[HITBOX_PLAYER_R_TOE] = 0.2

HitBoxTranslateDamage.Antlion = {}
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_BODY] = 1
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_HEAD] = 1
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_BKLF_SEG1] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_BKLF_SEG2] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_BKLF_SEG3] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_BKRT_SEG1] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_BKRT_SEG2] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_BKRT_SEG3] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_BACK] = 1
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_FTRT_SEG1] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_FTRT_SEG2] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_FTRT_SEG3] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_FTLF_SEG1] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_FTLF_SEG2] = 0.5
HitBoxTranslateDamage.Antlion[HITBOX_ANTLION_LEG_FTLF_SEG3] = 0.5

HitBoxTranslateDamage.AntlionGuard = {}
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_BODY] = 2
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_SPINE1] = 1.5
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_SPINE2] = 1.5
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_SPINE3] = 0
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_HEAD] = 0
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_CLAW1_L] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_CLAW2_L] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_CLAW1_R] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_CLAW2_R] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_CLAW3_L] = 0
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_CLAW3_R] = 0
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_ARM_L] = 0.1
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_ARM_R] = 0.1
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_FINGER_L] = 0
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_FINGER_R] = 0
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_PELVIS] = 2
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_LEG1_L] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_LEG2_L] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_LEG1_R] = 0.25
HitBoxTranslateDamage.AntlionGuard[HITBOX_ANTLION_GUARD_LEG2_R] = 0.25

function GM:PlayerTraceAttack( ply, dmginfo, dir, trace ) // we will need to call this from the antlion swep if we dont use bullet damage

	if ( SERVER ) then
	
 		GAMEMODE:ScalePlayerDamage( ply, trace.HitGroup, dmginfo, trace.HitBox ) 
		
 	end 
	
end


function GM:ScalePlayerDamage( ply, hitgroup, dmg, hitbox )

	local attacker = dmg:GetAttacker()
	
	if ( ply != attacker and attacker:IsPlayer() and attacker:Team() == ply:Team() ) then
		
		dmg:ScaleDamage( 0 )
		
	end
	
	if ply:IsAntlion() then
	
		--local e = EffectData()
		--e:SetOrigin( dmg:GetDamagePosition() )
		--e:SetStart( dmg:GetDamagePosition() );
		--e:SetScale( 256 )
		--e:SetMagnitude( 256 );
		--util.Effect( "AntlionGib", e, true, true )
		
		if ply:IsBurrowed() or ( attacker:IsAntlion() and !attacker:IsAntlionGuard() and !attacker:IsAntlionGuardian() ) then
		
			dmg:ScaleDamage(0)
			return dmg
			
		end
		
		if dmg:IsFallDamage() then
		
			local effectdata = EffectData();
			effectdata:SetStart( ply:GetPos() );
			effectdata:SetOrigin( ply:GetPos() );
			effectdata:SetScale( 256 );
			effectdata:SetMagnitude( 256 );
			util.Effect( "ThumperDust", effectdata, true, true );
			
			// This should be damaging whatever we land on.
			ply:ImpactAttack();
		
			// no damage
			dmginfo:SetDamage( 0 );
			return;
			
		end
		
		if ( CurTime() > ( ply.NextPainSound or 0 ) ) then
	
			ply.NextPainSound = CurTime() + 0.5;
			ply:EmitSound( Sound( "NPC_Antlion.Pain" ) );
		
		end
		
		if ply:IsAntlionGuard() then
		
			if hitbox and HitBoxTranslateDamage.AntlionGuard[hitbox] then
			
				dmg:ScaleDamage( HitBoxTranslateDamage.AntlionGuard[hitbox] )
				
			else
			
				dmg:ScaleDamage( 0.5 )
				
			end
			
		elseif ply:IsAntlionGuardian() then
		
			if hitbox and HitBoxTranslateDamage.AntlionGuard[hitbox] then
			
				dmg:ScaleDamage( HitBoxTranslateDamage.AntlionGuard[hitbox] / 2 )
				
			else
			
				dmg:ScaleDamage( 0.25 )
				
			end
			
		elseif ply:IsAntlionWorker() then
		
			if hitbox and HitBoxTranslateDamage.Antlion[hitbox] then
			
				dmg:ScaleDamage( HitBoxTranslateDamage.Antlion[hitbox] * 1.5 )
				
			else
			
				dmg:ScaleDamage( 1.25 )
				
			end
			
		else
		
			dmg:ScaleDamage( 0.3 )
			
		end
		
		return
		
	elseif ply:IsRebel() then
	
		if ( hitgroup == HITGROUP_LEFTARM or
			hitgroup == HITGROUP_RIGHTARM or 
			hitgroup == HITGROUP_LEFTLEG or
			hitgroup == HITGROUP_RIGHTLEG or
			hitgroup == HITGROUP_GEAR ) then
			
			dmg:ScaleDamage( 0.25 )
			
		elseif ( hitgroup == HITGROUP_HEAD or
			hitgroup == HITGROUP_CHEST or
			hitgroup == HITGROUP_STOMACH ) then
			
			dmg:ScaleDamage( 1 )
			
		end
		
		ply:EmitSound( "NPC_Citizen.Pain" )
		
		return
		
	end
	
	return self.BaseClass:ScalePlayerDamage( ply, dmg )
	
end

/*------------------------------------
	EntityTakeDamage - by foszor
------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	// make sure its a player
	if ( !ValidEntity( ent ) || !ent:IsPlayer() ) then
	
		return;
	
	end
	
	// falling?
	if ( ent:IsPlayer() and ent:IsAntlion() and dmginfo:IsFallDamage() ) then
		
		local effectdata = EffectData();
		effectdata:SetStart( ent:GetPos() );
		effectdata:SetOrigin( ent:GetPos() );
		effectdata:SetScale( 256 );
		effectdata:SetMagnitude( 256 );
		util.Effect( "ThumperDust", effectdata, true, true );
		
		// call impact attack
		ent:ImpactAttack();
	
		// no damage
		dmginfo:SetDamage( 0 );
		return;
	
	end
	
	if ent:IsPlayer() and ent:IsAntlion() and ( CurTime() > ( ent.NextPainSound or 0 ) ) then
	
		ent.NextPainSound = CurTime() + 0.5;
		ent:EmitSound( Sound( "NPC_Antlion.Pain" ) );
		
	elseif ply:IsRebel() then
		
		ent:EmitSound( "NPC_Citizen.Pain" )
		
	end

end


function GM:GetFallDamage( ply, fallSpeed )

	if ply:IsAntlion() then
	
		return 0
		
	else
	
		return self.BaseClass:GetFallDamage( ply, fallSpeed )
		
	end
	
end

function GM:PlayerDeathSound( ply )

	return true
	
end

function GM:DoPlayerDeath( ply, attacker, dmg )

	self.BaseClass:DoPlayerDeath( ply, attacker, dmg )
	
	if ply:IsAntlion() then
	
		--SafeRemoveEntity( ply:GetRagdollEntity() )
		--ply:CreateRagdoll()
		
		if ply:IsAntlionGuard() then
		
			ply:MakeAntlionGuard( false )
			GAME_EVENTS:TriggerOutput( "OnAntlionGuardDefeated" )
			ply:EmitSound( "NPC_AntlionGuard.Die" )
			
		elseif ply:IsAntlionGuardian() then
		
			ply:MakeAntlionGuardian( false )
			GAME_EVENTS:TriggerOutput( "OnAntlionGuardianDefeated" )
			ply:EmitSound( "NPC_AntlionGuard.Die" )
			
		else
		
			ply:StopSound( "NPC_Antlion.WingsOpen" )
			ply:EmitSound( "NPC_Antlion.Pain" )
			
		end
		
		local rag = ply:GetRagdollEntity()
		rag:SetBloodColor( BLOOD_COLOR_ANTLION )
		rag:SetSkin( ply:GetSkin() )
		rag:SetOwner( ply )
		
		GAMEMODE:AntlionModelEvent( ply, "death" )
		
		// Apparently our ragdoll entity doesn't exist on the client quite yet... :/
		timer.Simple( 0.1, function( )
			umsg.Start( "UpdateRagdollProperties" )
				umsg.Entity( ply )
			umsg.End()
		end )
		
	elseif ply:IsRebel() then
	
		GAMEMODE:DestroyPlayerBody( ply )
		ply:EmitSound( "NPC_Citizen.Die" )
		
	end
	
	gamemode.Call( "DecideScore", ply, attacker, dmg )
	
end

function GM:DecideScore( ply, attacker, dmg )

end










