
ENT.Type = "point"
ENT.Base = "base_point"

--[[
	//Inputs
	input StartGame(void) : "Start the game."
	input EndGame(string) : "End the game with result."
	input CheckpointPassed(string) : "Signify a checkpoint being passed."
	input StartBattle(string) : "Start a battle."
	input EndBattle(string) : "End a battle."
	input ReleaseAntlionGuard(void) : "Start an antlion guard fight."
	
	// Outputs
	output OnStartGame(void) : "Fired when the game starts."
	output OnEndGame(void) : "Fired when the game ends."
	output OnCheckpointPassed(string) : "Fired when a checkpoint has been passed."
	output OnStartBattle(string) : "Fired when a battle starts."
	output OnEndBattle(string) : "Fired when a battle ends."
	output OnAntlionGuardReleased(void) : "Fired when an antlion guard fight is started."
]]

local validKeys = {
	"Mode",
	"AntlionSpawnTime",
	"RebelSpawnTime",
	"PreGameTime",
	"RestartDelay",
	"SandMats"
}
local validInputs = {
	"WaitForPlayers",
	"WaitForStart",
	"StartGame",
	"EndGame",
	"CheckpointPassed",
	"StartBattle",
	"EndBattle",
	"RestartGame",
	"ReleaseAntlionGuard"
}
local validOutputs = {
	"OnWaitForPlayers",
	"OnWaitForStart",
	"OnStartGame",
	"OnEndGame",
	"OnCheckpointPassed",
	"OnStartBattle",
	"OnEndBattle",
	"OnRestartGame",
	"OnAntlionGuardDefeated"
}
local IOConvert = {
	WaitForPlayers = "OnWaitForPlayers",
	WaitForStart = "OnWaitForStart",
	EndPreGame = "OnEndPreGame",
	StartGame = "OnStartGame",
	EndGame = "OnEndGame",
	CheckpointPassed = "OnCheckpointPassed",
	StartBattle = "OnStartBattle",
	EndBattle = "OnEndBattle",
	RestartGame = "OnRestartGame",
	ReleaseAntlionGuard = "OnAntlionGuardReleased"
}

function ENT:AcceptInput( name, activator, caller, data )
	if !table.HasValue( validInputs, name ) then return end
	if name == "EndGame" then
		if _G[data] == TEAM_REBEL then
			SetGlobalString( "VICTORY_STATUS", "Rebels Won" )
		elseif _G[data] == TEAM_ANTLION then
			SetGlobalString( "VICTORY_STATUS", "Antlions Won" )
		elseif !data or data == "" then
			SetGlobalString( "VICTORY_STATUS", "No Winner" )
		else
			SetGlobalString( "VICTORY_STATUS", data )
		end
	elseif name == "ReleaseAntlionGuard" then
		self.GuardSpawn = ents.FindByName(data)
	end
	if IOConvert[name] then
		self:TriggerOutput( IOConvert[name], activator )
		print("FIRING HOOK",name,GAMEMODE["On"..name])
		if GAMEMODE["On"..name] then
			gamemode.Call( "On"..name, activator, self )
		end
	end
end

function ENT:KeyValue( key, value )
	if table.HasValue( validOutputs, key ) then
		self:StoreOutput( key, value )
	elseif table.HasValue( validInputs, key ) or table.HasValue( validKeys, key ) then
		self[key] = value
		if key == "AntlionSpawnDelay" or key == "RebelSpawnDelay" or key == "RestartDelay" then
			GAMEMODE[key] = value
		elseif key == "SandMats" then
			self.SandMats = value
			local mats = string.Explode( " ", value )
			for k, v in pairs( mats ) do
				mats[k] = _E[v]
			end
			GAMEMODE[key] = mats
		end
	end
end




