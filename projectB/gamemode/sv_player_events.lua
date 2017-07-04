
/*------------------------------------
	Think
------------------------------------*/
function GM:Think()

	for k, v in pairs( player.GetAll() ) do
		
		v:Think()
		
		if v:IsRebel() then
			
			for _, battlezone in pairs( BATTLE_ZONES ) do
				
				if battlezone.KeyVals["volume"] then
					
					local zone = ents.FindByName( battlezone.KeyVals["volume"] )[1]
					
					if v:GetPos() > zone:OBBMins() and v:GetPos() < zone:OBBMaxs() then
						
						ply.BattleZone = battlezone
						
					end
					
				end
				
			end
			
		end
		
	end
	
end


/*------------------------------------
	KeyPress - by foszor
------------------------------------*/
function GM:KeyPress( ply, key )

	// spectator?
	if ( !ply:Alive() ) then
	
		return;
		
	end

	if ( key == IN_ATTACK ) then
	
		ply.AttackKey = true;
		
	elseif ( key == IN_ATTACK2 ) then
	
		ply.RangeAttackKey = true;
	
	end

end


/*------------------------------------
	KeyRelease - by foszor
------------------------------------*/
function GM:KeyRelease( ply, key )

	if ( key == IN_ATTACK ) then
	
		ply.AttackKey = false;
	
	elseif ( key == IN_ATTACK2 ) then
	
		ply.RangeAttackKey = false;
	
	end

end


/*------------------------------------
	PlayerCanPickupWeapon
------------------------------------*/
function GM:PlayerCanPickupWeapon( ply, weapon )

	return ply:IsRebel() -- only pickup when they're a rebel
	
end


/*------------------------------------
	PlayerSwitchFlashlight
------------------------------------*/
function GM:PlayerSwitchFlashlight( ply, SwitchOn )

	return ply:IsRebel() -- only use flashlight when they're a rebel
	
end


/*------------------------------------
	PlayerUse
------------------------------------*/
function GM:PlayerUse( ply, ent )

	return ply:IsRebel() -- only use when they're a rebel
	
end


/*------------------------------------
	PlayerDisconnected
------------------------------------*/
function GM:PlayerDisconnected( ply )
	
	// no players left?
	if #player.GetAll() == 0 then
		
		// lets reset
		GAME_EVENTS:Fire( "StartPreGame" )
		
		GAMEMODE:ResetMapEntities()
		
	end
	
end 


/*------------------------------------
	PlayerCanHearPlayersVoice
------------------------------------*/
function GM:PlayerCanHearPlayersVoice( ply1, ply2 )

	// speaking to your team?
	if ply1:TeamSpeaking() then
	
		return ply2:Team() == ply1:Team()
		
	else
	
		return true
		
	end
	
end

/*------------------------------------
	AntlionModelEvent
------------------------------------*/
function GM:AntlionModelEvent( ply, event, ... )

	print( event:upper(), ply, ... )
	
	if event == "spawn" then
		
		GAMEMODE:CreateAntlionModel( ply, ply:GetModel(), ply:GetSkin() )
		
	elseif event == "death" then
		
		GAMEMODE:RemoveAntlionModel( ply )
		
	end
	
end

/*------------------------------------
	Concommand - antlion_burrow
------------------------------------*/
local function Burrow( ply, cmd, args )
	
	if ply:IsBurrowed() then
		ply:BurrowOut()
	else
		ply:BurrowIn()
	end
	
end
concommand.Add( "antlion_burrow", Burrow )

/*------------------------------------
	Concommand - antlion_teamspeak
------------------------------------*/
local function TeamSpeak( ply, cmd, args )

	ply:SendNWBool( "player_isteamspeaking", cmd == "+antlion_teamspeak" )
	
	ply:ConCommand( cmd:sub( 0, 1 ) .. "voicerecord" )
	
end
concommand.Add( "+antlion_teamspeak", TeamSpeak )
concommand.Add( "-antlion_teamspeak", TeamSpeak )

/*------------------------------------
	Concommand - antlion_vision
------------------------------------*/
local function AntlionVision( ply, cmd, args )
	
	if !ply:IsAntlion() then return end
	
	ply:SetNWBool( "antlion_visionon", cmd == "+antlion_vision" )
	
end
concommand.Add( "+antlion_vision", AntlionVision )
concommand.Add( "-antlion_vision", AntlionVision )

/*
function GM:ShowHelp( ply )
	ply:ConCommand("")
end
function GM:ShowTeam( ply )
	ply:ConCommand("")
end
function GM:ShowSpare1( ply )
	ply:ConCommand("")
end
function GM:ShowSpare2( ply )
	ply:ConCommand("")
end
*/














