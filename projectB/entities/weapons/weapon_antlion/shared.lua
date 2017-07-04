if SERVER then
	AddCSLuaFile("shared.lua")
end
if CLIENT then
	SWEP.PrintName = "Antlion"
end

SWEP.ViewModel = "none"
SWEP.WorldModel = "none"