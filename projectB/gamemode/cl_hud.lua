

surface.CreateFont( "TargetID", 40, 400, true, false, "Stamina_Font", false, false )
surface.CreateFont( "TargetID", 40, 400, true, false, "Timer_Font", false, false )

local function GameTimerText( status )

	local timeStr, timeInt
	
	if status == GAME_STATUS_PREGAME then
		
		timeStr = "Pre-Game Status: Press F2 to choose team"
		
	elseif status == GAME_STATUS_WAITFORSTART then
	
		timeStr = "Waiting for Game Start..."
		
	elseif status == GAME_STATUS_WAITFORPLAYERS then
	
		timeStr = "Wait Timer: "
		timeInt = GetGlobalInt( "WaitForPlayersTimer", 0 )
		
	elseif status == GAME_STATUS_INBATTLE and GAMEMODE:GetCurrentBattle() and GAMEMODE:GetCurrentBattle().Mode != 1 then
	
		timeStr = "Battle Timer: "
		timeInt = GetGlobalInt( "BattleTimer_"..GAMEMODE:GetCurrentBattle():EntIndex(), 0 )
		
	elseif status == GAME_STATUS_INPROGRESS then
		
		timeStr = "Game In-Progress..."
		
	elseif status == GAME_STATUS_GAMEOVER then
		
		timeStr = "Game Over: "
		timeInt = GetGlobalString( "VICTORY_STATUS", "No Winner" )
		
	elseif status == GAME_STATUS_RESTARTING then
	
		timeStr = "Restarting in: "
		timeInt = GetGlobalInt( "RestartTimer", 0 )
		
	else
		
		timeStr = "What. The. Fuck. "
		timeInt = "9001"
		
	end
	
	--print( status, timeStr, timeInt )
	return timeStr .. ( ( tonumber( timeInt ) and string.ToMinutesSeconds( timeInt ) ) or timeInt or "" )
	
end

/*------------------------------------
	HUDPaint
------------------------------------*/
function GM:HUDPaint( )

	// get player
	local ply = LocalPlayer()
	
	ply.HeadPosition, ply.HeadAngles = ply:GetBonePosition( VIEW_BONE );
	ply.HeadPosition = ply.HeadPosition - ply:GetForward() * 15
	
	draw.SimpleText( "Stamina: " .. math.Round( ply:GetStamina() ), "Stamina_Font", 20, 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP );
	
	draw.SimpleText( GameTimerText( GAMEMODE:GetGameStatus() ), "Timer_Font", 20, 60, Color( 255, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP );
	
	
end


/*------------------------------------
	HUDDrawTargetID
------------------------------------*/
function GM:HUDDrawTargetID( )
	
	local tr = ply:GetEyeTrace()
	
	if tr.Entity and tr.Entity:IsPlayer() and tr.Entity:Team() == LocalPlayer():Team() then
	
		return self.BaseClass:HUDDrawTargetID()
		
	end
	
end

local matOverlay_World = CreateMaterial( "BlackOverlay", "UnlitGeneric", { [ "$basetexture" ] = "vgui/black" } )
local matOverlay_Rebel = CreateMaterial( "BlueOverlay", "UnlitGeneric", { [ "$basetexture" ] = "lights/red001" } )
local matOverlay_Antlion = CreateMaterial( "RedOverlay", "UnlitGeneric", { [ "$basetexture" ] = "lights/red001" } )
local matOverlay_Prop = CreateMaterial( "GreyOverlay", "UnlitGeneric", { [ "$basetexture" ] = "light/red001" } )

local function AntlionView( ply )

	cam.Start3D( EyePos(), EyeAngles() )
	
		for k, v in pairs( ents.GetAll() ) do
		
			if ValidEntity( v ) && util.IsValidModel( v:GetModel() or "" ) then
			
				render.SuppressEngineLighting( true )
				render.SetColorModulation( 0, 1, 0 )
				render.SetBlend( 0.5 )
				
				SetMaterialOverride( "debug/white" )
 
				v:DrawModel()
 
				render.SuppressEngineLighting( false )
				render.SetColorModulation( 1, 1, 1 )
				render.SetBlend( 1 )
				
				SetMaterialOverride( 0 )
				
			end
			
		end
		
	cam.End3D()

end

function GM:PostDrawTranslucentRenderables()
	
	local ply = LocalPlayer()
	
	if ply:IsAntlion() and ply:GetNWBool( "antlion_visionon" ) then
		
		AntlionView( ply )

	end
	
end






























