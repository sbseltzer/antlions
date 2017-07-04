ENT.Type = "point"
ENT.Base = "base_point"

function ENT:Initialize()
    self.Player = NULL
	self.Enabled = true
end

function ENT:KeyValue( key, value )
	if ( key == "StartDisabled" ) then
		self.Enabled = tonumber( value ) == 0
	end
end

function ENT:AcceptInput( name, activator, caller, data )
    if (name == "Enable") then 
        self.Enabled = true
    elseif (name == "Disable") then 
        self.Enabled = false
    end
end