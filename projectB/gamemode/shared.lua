
--[[---------------------------------------------------------

	Developer's Notes:
	
  ---------------------------------------------------------]]


--NARWHAL_DERIVATIVE = "base"

GM.Name 		= "Antlion Survival"
GM.Author 		= "Grea$eMonkey"
GM.Email 		= "geekwithalife@gmail.com"
GM.Website 		= "www.geekwithalife.com"
GM.TeamBased 	= true

DeriveGamemode( "narwhal" )

GM.SandMats = {}
GM.ThumperShakeScale = 15
GM.IsLastRound = false

REBEL_MODELS = {}
TEAM_REBEL = 1
TEAM_ANTLION = 2

--[[------------------------------------
	CreateTeams
------------------------------------]]
function GM:CreateTeams()

	team.SetUp( TEAM_REBEL, "Rebels", Color( 207, 25, 25 ), true )
	team.SetSpawnPoint( TEAM_REBEL, { "info_player_start", "info_player_progress"  } )
	
	team.SetUp( TEAM_ANTLION, "Antlions", Color( 75, 255, 105 ), true )
	team.SetSpawnPoint( TEAM_ANTLION, { "info_player_antlion" } )
	
end

--[[------------------------------------
	Initialize
------------------------------------]]
function GM:Initialize()

	local path = "models/humans/group03/"
	local pathm = "models/humans/group03m/"
	local fStr, mStr = "female_0", "male_0"
	
	for i = 1, 7 do
	
		if util.IsValidModel( path..fStr..i..".mdl" ) then
		
			table.insert( REBEL_MODELS, path..fStr..i..".mdl" )
			
		end
		
		if util.IsValidModel( pathm..fStr..i..".mdl" ) then
		
			table.insert( REBEL_MODELS, pathm..fStr..i..".mdl" )
			
		end
		
	end
	
	for i = 1, 9 do
	
		if util.IsValidModel( path..mStr..i..".mdl" ) then
		
			table.insert( REBEL_MODELS, path..mStr..i..".mdl" )
			
		end
		
		if util.IsValidModel( pathm..mStr..i..".mdl" ) then
		
			table.insert( REBEL_MODELS, pathm..mStr..i..".mdl" )
			
		end
		
	end
	
	for k, v in pairs(REBEL_MODELS) do
	
		util.PrecacheModel(v)
		
	end
	
	util.PrecacheModel("models/antlion.mdl")
	util.PrecacheModel("models/antlion_guard.mdl")
	util.PrecacheModel("models/antlion_worker.mdl")
	util.PrecacheModel("models/props_combine/CombineThumper001a.mdl")
	util.PrecacheModel("models/props_combine/CombineThumper002.mdl")
	util.PrecacheModel("models/v_antlion.mdl")
	
	// Precache the antlion sounds from gamesounds.txt
	util.PrecacheSound("npc/antlion/digin.wav")
	util.PrecacheSound("npc/antlion/digout.wav")
	util.PrecacheSound("npc/antlion/rumble1.wav")
	util.PrecacheSound("npc/antlion/distract1.wav")
	util.PrecacheSound("npc/antlion/land1.wav")
	util.PrecacheSound("npc/antlion/wingsopen.wav")
	util.PrecacheSound("npc/antlion/foot1.wav")
	util.PrecacheSound("npc/antlion/foot2.wav")
	util.PrecacheSound("npc/antlion/foot3.wav")
	util.PrecacheSound("npc/antlion/foot4.wav")
	util.PrecacheSound("npc/antlion/pain1.wav")
	util.PrecacheSound("npc/antlion/pain2.wav")
	util.PrecacheSound("npc/antlion/attack_single1.wav")
	util.PrecacheSound("npc/antlion/attack_single2.wav")
	util.PrecacheSound("npc/antlion/attack_single3.wav")
	util.PrecacheSound("npc/antlion/attack_double1.wav")
	util.PrecacheSound("npc/antlion/attack_double2.wav")
	util.PrecacheSound("npc/antlion/attack_double3.wav")
	util.PrecacheSound("npc/vote/swing1.wav")
	util.PrecacheSound("npc/vote/swing2.wav")
	util.PrecacheSound("npc/zombie/claw_strike1.wav")
	util.PrecacheSound("npc/zombie/claw_strike2.wav")
	util.PrecacheSound("npc/zombie/claw_strike3.wav")
	util.PrecacheSound("npc/zombie/claw_miss1.wav")
	util.PrecacheSound("npc/zombie/claw_miss2.wav")
	
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard1.wav")
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard2.wav")
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard3.wav")
	util.PrecacheSound("physics/flesh/flesh_squishy/impact_hard4.wav")
	
end


--[[------------------------------------
	OnThumperThumped
------------------------------------]]
function GM:OnThumperThumped( thumper )
end


--[[------------------------------------
	IsConsideredSand
------------------------------------]]
function GM:IsConsideredSand( enum )
	return ( enum and table.HasValue( GAMEMODE.SandMats, enum ) )
end

--[[------------------------------------
	GetGroundMat
------------------------------------]]
function GM:GetGroundMat( vPos, h )
	
	h = h or 10
	local filter = ents.GetAll()
	
	for k, v in pairs( filter ) do
		
		if v:GetClass() == "worldspawn" then
			
			table.remove( filter, k )
			break
			
		end
		
	end
	
	local obbmins, obbmaxs = Vector( -16, -16, 0 ), Vector( 16, 16, 32 )
	
	local tr = {}
	tr.start = vPos + vector_up * 10
	tr.endpos = vPos - vector_up * ( h + 10 )
	tr.filter = filter
	tr.mins = obbmins
	tr.maxs = obbmaxs
	tr = util.TraceHull( tr )
	
	return tr.MatType
	
end




--[[
ANTLION_EFFECTS = {
	//ANTLION_GIB_01.PCF
	"antlion_gib_01",
	"antlion_gib_01_juice",
	"antlion_gib_01_trailsA",
	"antlion_gib_01_trailsb",
	//ANTLION_GIB_02.PCF
	"antlion_gib_02",
	"antlion_gib_02_blood",
	"antlion_gib_02_floaters",
	"antlion_gib_02_gas",
	"antlion_gib_02_juice",
	"antlion_gib_02_slime",
	"antlion_gib_02_trailsA",
	"antlion_gib_02_trailsB",
	//ANTLION_WORKER.PCF
	"antlion_spit",
	"antlion_spit_02",
	"antlion_spit_03",
	"antlion_spit_05",
	"antlion_spit_player",
	"antlion_spit_player_splat",
	"antlion_spit_trail"
}
]]
	--[[
	for k, v in pairs(ANTLION_EFFECTS) do
		PrecacheParticleSystem( v )
	end
	PrecacheParticleSystem( "blood_impact_green_01" )
	PrecacheParticleSystem( "blood_impact_yellow_01" )
	]]



