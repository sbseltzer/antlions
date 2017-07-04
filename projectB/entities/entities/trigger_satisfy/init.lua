
ENT.Type = "brush"
ENT.Base = "base_brush"

--[[
	fraction(float) : "Satisfaction Percentage" : 1.0 : "Percentage of ents that must pass through this trigger to trigger it. Needs to be a number between 0 and 1."
	codeNumerator(string) : "Entity Numerator" : "team.GetAlivePlayers(TEAM_REBEL)" : "Function to run that returns a table of entities. This will be used as the numerator of he fraction."
	codeFilter(string) : "Entity FilterEnts" : "team.GetPlayers(TEAM_REBEL)" : "Function to run that returns a table of entities.  This will be used as the denominator of he fraction."
	
	PassType(choices) : "Trigger Pass Type" : 0 =
	[
		0 : "Start Touch"
		1 : "End Touch"
		2 : "Touching"
		3 : "Start then End Touch"
	]
	spawnflags(flags) =
	[
		1: "Trigger on start touch." : 1
		2: "Trigger on end touch." : 0
		4: "Only satisfy while touching." : 0
	]
	
	input SetPercentage(float) : "Set Satisfaction Percentage."
	input SetNumerator(string) : "Set Entity Numerator."
	input SetDenominator(string) : "Set Entity FilterEnts."
	
	output OnTriggerSatisfied(void) : "Fired when the specified percentage of players who meet the filter have passed."
]]

local TYPE_FRAC, TYPE_COUNT, TYPE_FRAC_AND_COUNT, TYPE_FRAC_OR_COUNT, TYPE_FRAC_XOR_COUNT = 0, 1, 2, 3, 4
local MODE_STARTTOUCH, MODE_TOUCHING, MODE_ENDTOUCH = 0, 1, 2
local validInputs = {
	"SetPercentage",
	"SetNumerator",
	"SetDenominator"
}

function ENT:Initialize()
	--self.Enabled = self.Enabled or false
	self.Numerator = {}
	self.FilterEnts = {}
	self.SatisfyType = self.SatisfyType or TYPE_FRAC
	self.TriggerType = self.TriggerType or MODE_STARTTOUCH
	--self.CodeFilter = nil
	--self.SatisfyFraction = nil
	--self.SatisfyCounter = nil
	self.Counter = 0
end

function ENT:UpdateFilterEnts()
	RunString( 'if type('..self.CodeFilter..') != "table" then error( tostring(ents.GetByIndex( '..self:EntIndex()..' )).." attempted to use invalid string value for trigger FilterEnts!" ) end ents.GetByIndex( '..self:EntIndex()..' ).FilterEnts = '..self.CodeFilter )
end
function ENT:UpdateNumerator( ent )
	if table.HasValue( self.FilterEnts, ent ) and !table.HasValue( self.Numerator, ent ) then
		table.insert(self.Numerator, ent)
	end
end

function ENT:FractionSatisfied()
	if #self.Numerator > #self.FilterEnts then return false end
	--print( #self.Numerator.."/"..#self.FilterEnts, #self.Numerator/#self.FilterEnts, self.SatisfyFraction )
	return #self.Numerator/#self.FilterEnts >= self.SatisfyFraction
end

function ENT:CounterSatisfied()
	--print( self.Counter, self.SatisfyCounter )
	return self.Counter == self.SatisfyCounter
end

function ENT:OnSatisfied( activator )
	--print( "satisfied by ", activator )
	self:TriggerOutput( "OnTriggerSatisfied", activator )
end

function ENT:PassesTriggerFilters( ent )
	self:UpdateFilterEnts()
	return table.HasValue( self.FilterEnts, ent )
end

function ENT:StartTouch( ent )
	
	self:TriggerOutput( "OnStartTouch", ent )
	
	if self.TriggerType == MODE_ENDTOUCH then return end
	
	--print( self.CodeFilter )
	
	if !self.CodeFilter then return end
	
	self:UpdateFilterEnts()
	self:UpdateNumerator( ent )
	
	--PrintTable(self.FilterEnts)
	--PrintTable(self.Numerator)
	
	if self.SatisfyType == TYPE_COUNT then
		self.Counter = self.Counter + 1
		if self:CounterSatisfied() then
			self:OnSatisfied( ent )
			return
		end
	elseif TYPE_FRAC_AND_COUNT then
		self.Counter = self.Counter + 1
		if self:FractionSatisfied() and self:CounterSatisfied() then
			self:OnSatisfied( ent )
			return
		end
	elseif TYPE_FRAC_OR_COUNT then
		self.Counter = self.Counter + 1
		if self:FractionSatisfied() or self:CounterSatisfied() then
			self:OnSatisfied( ent )
			return
		end
	elseif TYPE_FRAC_XOR_COUNT then
		self.Counter = self.Counter + 1
		if ( self:FractionSatisfied() and !self:CounterSatisfied() ) or ( !self:FractionSatisfied() and self:CounterSatisfied() ) then
			self:OnSatisfied( ent )
			return
		end
	end
	
end

function ENT:Touch( ent )
	
	self:TriggerOutput( "OnTouching", ent )
	
end

function ENT:EndTouch( ent )

	self:TriggerOutput( "OnEndTouch", ent )
	
	if self.TriggerType == MODE_STARTTOUCH then return end
	
	if self.TriggerType == MODE_TOUCHING then
		if table.HasValue( self.Numerator, ent ) then
			for k, v in pairs( self.Numerator ) do
				if v == ent then
					table.remove(self.Numerator, k)
					break
				end
			end
		end
	end
	
	if self.TriggerType != MODE_ENDTOUCH then return end
	
	if !self.CodeFilter then return end
	
	self:UpdateFilterEnts()
	self:UpdateNumerator( ent )
	
	--PrintTable(self.FilterEnts)
	--PrintTable(self.Numerator)
	
	if self.SatisfyType == TYPE_COUNT then
		self.Counter = self.Counter + 1
		if self:CounterSatisfied() then
			self:OnSatisfied( ent )
			return
		end
	elseif TYPE_FRAC_AND_COUNT then
		self.Counter = self.Counter + 1
		if self:FractionSatisfied() and self:CounterSatisfied() then
			self:OnSatisfied( ent )
			return
		end
	elseif TYPE_FRAC_OR_COUNT then
		self.Counter = self.Counter + 1
		if self:FractionSatisfied() or self:CounterSatisfied() then
			self:OnSatisfied( ent )
			return
		end
	elseif TYPE_FRAC_XOR_COUNT then
		self.Counter = self.Counter + 1
		if ( self:FractionSatisfied() and !self:CounterSatisfied() ) or ( !self:FractionSatisfied() and self:CounterSatisfied() ) then
			self:OnSatisfied( ent )
			return
		end
	end
	
end

function ENT:AcceptInput( name, activator, caller, data )
	--print( "Input "..tostring(self)..":", name, activator, caller, data )
	if name == "OnTriggerSatisfied" then
		self:TriggerOutput( name, activator )
	elseif name == "SetPercentage" then
		self:SetKeyValue( "fraction", data )
	elseif name == "SetCount" then
		self:SetKeyValue( "counter", data )
	elseif name == "SetFilter" then
		self:SetKeyValue( "codeFilter", data )
	elseif name == "Enable" then
		self.Enabled = true
	elseif name == "Disable" then
		self.Enabled = false
	elseif name == "Toggle" then
		self.Enabled = !self.Enabled
	end
end

function ENT:KeyValue( key, value )
	--print( "Key Value "..tostring(self)..":", key, value )
	if string.sub(key, 1, 2):lower() == "on" then
		self:StoreOutput( key, value )
	elseif key == "StartDisabled" then
		if value == 0 or value == "No" then
			self.Enabled = true
		end
	elseif key == "satisfaction" then
		self.TriggerType = value
	elseif key == "satisfytype" then
		self.SatisfyType = value
	elseif key == "codeFilter" then
		self.CodeFilter = value
	elseif key == "fraction" then
		self.SatisfyFraction = tonumber(value)
	elseif key == "counter" then
		self.SatisfyCounter = tonumber(value)
	end
end

