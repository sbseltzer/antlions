
ENT.Type = "point"
ENT.Base = "base_point"

--[[
	Type(choices) : "Battle End Type" : 1 =
	[
		0 : "Timer"
		1 : "Trigger"
		2 : "Either"
	]
	Spawns(target_destination) : "Spawnpoints" : : "Name of the antlion spawnpoints to use for accellerated battle spawning."
	AntlionSpawnRate(float) : "Antlion Spawn Rate" : : "Optional spawn delay when an antlion gets killed for this battle."
	TimeFrac1(float) : "Time Fraction 1" : :
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac2(float) : "Time Fraction 2" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac3(float) : "Time Fraction 3" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac4(float) : "Time Fraction 4" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac5(float) : "Time Fraction 5" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac6(float) : "Time Fraction 6" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac7(float) : "Time Fraction 7" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeFrac8(float) : "Time Fraction 8" : : 
		"Enter a number between 0 and 1 which signifies a fraction of the battle Time Limit. " +
		"When this time is reached, the corresponding OnTimeFraction# output will fire."
	TimeLimit(integer) : "Time Limit" : 45 : "The battle time limit. Only valid when the battle end type is Timed or Both."
	
	input SetTimeLimit(float) : "Set the time limit."
	input StartBattle(void) : "Start the battle."
	input EndBattle(void) : "End the battle."
	input SetTimeFraction1(float) : ""
	input SetTimeFraction2(float) : ""
	input SetTimeFraction3(float) : ""
	input SetTimeFraction4(float) : ""
	input SetTimeFraction5(float) : ""
	input SetTimeFraction6(float) : ""
	input SetTimeFraction7(float) : ""
	input SetTimeFraction8(float) : ""
	
	output OnStartBattle(void) : "Fired when a battle starts."
	output OnEndBattle(void) : "Fired when a battle ends."
	output OnTimeFraction1(void) : "Fired when the corresponding Time Fraction 1 is reached."
	output OnTimeFraction2(void) : "Fired when the corresponding Time Fraction 2 is reached."
	output OnTimeFraction3(void) : "Fired when the corresponding Time Fraction 3 is reached."
	output OnTimeFraction4(void) : "Fired when the corresponding Time Fraction 4 is reached."
	output OnTimeFraction5(void) : "Fired when the corresponding Time Fraction 5 is reached."
	output OnTimeFraction6(void) : "Fired when the corresponding Time Fraction 6 is reached."
	output OnTimeFraction7(void) : "Fired when the corresponding Time Fraction 7 is reached."
	output OnTimeFraction8(void) : "Fired when the corresponding Time Fraction 8 is reached."
]]

ENT.TimeFractions = {}
local validKeys = {
	"Type",
	"Spawns",
	"AntlionSpawnRate",
	"TimeLimit",
	"volume"
}
local validInputs = {
	"SetTimeLimit",
	"StartBattle",
	"EndBattle",
	"SetAntlionSpawnRate"
}
local validOutputs = {
	"OnBattleStart",
	"OnBattleEnd"
}
local IOConvert = {
	StartBattle = "OnBattleStart",
	EndBattle = "OnBattleEnd",
}

function ENT:Initialize()
	
	local nameString = "__BATTLEZONES"..self:EntIndex().."__"
	local targetName = self:GetKeyValues().targetname
	
	if !targetName or targetName == "" then
	
		self:SetName( nameString )
		self:SetKeyValue( "targetname", nameString )
		
	end
	
	self.BattleZoneVolumes[1]:SetKeyValue( "OnTrigger", nameString..",PassBattleActivator,!activator,0,-1" )

end

function ENT:AcceptInput( name, activator, caller, data )
	
	if name == "PassBattleActivator" then
		
		local inputdata = string.Explode( ",", data )
		print(activator, caller, unpack(inputdata))
		
		return
		
	end
	
	if name:sub( 1, 15 ) == "SetTimeFraction" then
		
		self:SetKeyValue( name:sub( 4, name:len() ), data )
		
		return
		
	end
	
	if !table.HasValue( validInputs, name ) then return end
	
	if name == "SetTimeLimit" then
	
		self:SetKeyValue( "TimeLimit", data )
		return
		
	elseif name == "SetAntlionSpawnRate" then
	
		self:SetKeyValue( "AntlionSpawnRate", data )
		return
		
	end
	
	if IOConvert[name] then
	
		self:TriggerOutput( IOConvert[name], activator )
		
		if GAMEMODE["On"..name] then
			
			gamemode.Call( "On"..name, activator, self )
			
		end
		
	end
	
end
/*
for k, v in pairs( ents.GetAll() ) do
	if v.Outputs then
		for output, data in pairs( v.Outputs ) do
			local outdata = string.Explode( ",", data )
			if ents.FindByName( outdata[1] )[1]:GetClass() == "ENTITY_BATTLE_CLASS" and outdata[2] == "Trigger" then
			
			end
		end
	end
end
*/
function ENT:KeyValue( key, value )

	if key:sub( 0, 12 ) == "TimeFraction" then
		
		local i = tonumber( name:sub( 12, key:len() ) )
		
		if i then
		
			self.TimeFractions[i] = value
			
		end
		
		return
		
	elseif key == "volume" then
		
		local zones = ents.FindByName( value )
		
		if zones[1] then
			
			/*for _, ent in pairs( zones ) do
			
				if !ent.StoreOutput or !ent.TriggerOutput then -- probably an engine entity
				
					ent.StoreOutput = GAMEMODE.BaseEntity.StoreOutput
					ent.TriggerOutput = GAMEMODE.BaseEntity.TriggerOutput
					
				end
				
				ent:StoreOutput( "OnTrigger", GAME_EVENTS:GetName()..",<input name>,<param>,<delay>,<times to be used>" )
				
			end*/
			
			self.BattleZoneVolumes = zones
			
		end
		
	end
	
	if table.HasValue( validOutputs, key ) then
	
		self:StoreOutput( key, value )
		
	elseif table.HasValue( validInputs, key ) or table.HasValue( validKeys, key ) then
	
		self[key] = value
		
	end
	
end




