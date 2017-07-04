

GM.PlayersPastThumperRadius = {}
GM.IsMapValid = true
GM.AntlionSpawnDelay = 5
GM.RebelSpawnDelay = 5
GM.RestartDelay = 15
GM.PreGameTime = 60

ENTITY_THUMPER_CLASS = "prop_thumper2"
ENTITY_BATTLE_CLASS = "antlion_battle"
ENTITY_EVENTS_CLASS = "logic_antlion_events"--"antlion_game_events"
ENTITY_RULES_CLASS = "antlion_game_rules"
GAME_EVENTS = NULL
GAME_RULES = NULL
ENT_RESET_STORAGE = {}
ENT_OUTPUT_STORAGE = {}
ENT_INPUT_STORAGE = {}
NO_CLEANUP_ENTS = {
	"trigger_satisfy",
	"info_player_progress", "info_player_antlion", "info_player_antlion_guard",
	ENTITY_EVENTS_CLASS, ENTITY_BATTLE_CLASS--,
	--"prop_battery", "prop_mine", "prop_rollermine", "prop_turret"
}
--NO_CLEANUP_ENTS = file.Find( "../gamemodes/"..GM.Folder:sub(11).."/entities/entities/*" )

local function ReplaceThumper( thumper )
	local newThumper = ents.Create( ENTITY_THUMPER_CLASS )
	local keyvals = thumper.KeyVals
	if !keyvals then print("Thumper "..tostring(thumper).." has no key values.") return end
	for key, value in pairs( keyvals ) do
		if key != "classname" then
			newThumper:SetKeyValue( key, value )
		end
	end
	newThumper:SetModel( thumper:GetModel() )
	newThumper:SetPos( thumper:GetPos() )
	newThumper:SetAngles( thumper:GetAngles() )
	newThumper:Spawn()
	newThumper:Activate()
	print("Replacing", thumper, "with", newThumper)
	thumper:Remove()
end

/*------------------------------------
	ReplaceThumpers
------------------------------------*/
function GM:ReplaceThumpers()
	local Thumpers = ents.FindByClass( "prop_thumper" )
	for _, thumper in pairs( Thumpers ) do
		ReplaceThumper( thumper )
	end
end

/*------------------------------------
	CreateAntlionModel
------------------------------------*/
function GM:CreateAntlionModel( ply, mdl, skin )
	
	if !ply then return end
	
	if SERVER then
		
		if !mdl then
			if ply:IsAntlionWorker() then
				mdl = "models/Antlion_worker.mdl"
			elseif ply:IsAntlionGuard() then
				mdl = "models/Antlion_guard.mdl"
			elseif ply:IsAntlionGuardian() then
				mdl = "models/Antlion_guard.mdl"
			else
				mdl = "models/Antlion.mdl"
			end
		end
	
		if !skin then
			if ply:IsAntlionWorker() then
				skin = 0
			elseif ply:IsAntlionGuard() then
				skin = 0
			elseif ply:IsAntlionGuardian() then
				skin = 1
			else
				skin = ply:GetSkin()
			end
		end
		
		umsg.Start( "UpdateAntlionModel", ply )
			umsg.Entity( ply ) -- parent
			umsg.String( mdl ) -- model
			umsg.Short( skin ) -- skin
		umsg.End()
		
	else
		
		ply = ply or LocalPlayer()
		// Thanks ralle for all your help!
		local ent = ClientsideModel( mdl or "models/antlion.mdl", RENDERGROUP_TRANSLUCENT )
		ent:SetNoDraw( true ) -- dont draw until everything has been set up
		ent:SetPos( ply:GetPos() )
		ent:SetAngles( ply:GetAngles() )
		ent:AddEffects( EF_BONEMERGE | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES | EF_NOSHADOW ) --| EF_NOINTERP 
		ent:SetParent( ply )
		ent:SetNoDraw( false )
		ent:SetSkin( skin or 0 )
		ent.Bounds = { ent:GetRenderBounds() } -- store our default bounds
		
		local legBones = { 
			ent:LookupBone( "Antlion.LegL1_Bone" ), --25
			ent:LookupBone( "Antlion.LegL2_Bone" ), --26
			ent:LookupBone( "Antlion.LegL3_Bone" ), --27
			ent:LookupBone( "Antlion.LegR1_Bone" ), --29
			ent:LookupBone( "Antlion.LegR2_Bone" ), --30
			ent:LookupBone( "Antlion.LegR3_Bone" )  --31
		}
		PrintTable(legBones)
			--[[ent:LookupBone( "Antlion.LegMidR1_Bone" ),
			ent:LookupBone( "Antlion.LegMidR2_Bone" ),
			ent:LookupBone( "Antlion.LegMidR3_Bone" ),
			ent:LookupBone( "Antlion.LegMidL1_Bone" ),
			ent:LookupBone( "Antlion.LegMidL2_Bone" ),
			ent:LookupBone( "Antlion.LegMidL3_Bone" )
			0]]
		ent.BuildBonePositions = function( self, numBones, numPhysBones )
			
			if self.Player:IsAntlion() and self.Player == LocalPlayer() and self.Player == GetViewEntity() then
			
				local boneMatrix
				
				for bone = 0, numBones do
					
					boneMatrix = self:GetBoneMatrix( bone )
					
					-- bones 25 to 27 are the left leg bones
					-- bones 29 to 31 are the right leg bones
					if ( bone < 25 or bone == 28 or bone > 31 ) and boneMatrix then
						
						boneMatrix:Scale( Vector( 0, 0, 0 ) )
						boneMatrix:SetTranslation( self:GetBonePosition( 0 ) )
						self:SetBoneMatrix( bone, boneMatrix )
						
					end
					
				end
				
			end
			
		end
		
		ent.Player = ply
		ply.AntlionModel = ent
		
		print( "Creating antlion:", ply, mdl, skin )
		
	end
	
end

/*------------------------------------
	AdjustAntlionModel
------------------------------------*/
function GM:AdjustAntlionModel( ply, parent, mdl, skin )
	
	if !ply then return end
	
	if SERVER then
		
		parent = parent or ply
		mdl = mdl or parent:GetModel() or ply:GetModel()
		skin = skin or parent:GetSkin() or ply:GetSkin()
		
		umsg.Start( "UpdateAntlionModel", ply )
			umsg.Entity( parent ) -- parent
			umsg.String( mdl ) -- model
			umsg.Short( skin ) -- skin
		umsg.End()
		
		--print( "Adjusting antlion:", ply, parent, mdl, skin )
		
	else
		
		local newparent, newmodel, newskin = ply, parent, mdl
		parent = newparent or LocalPlayer()
		mdl, skin = newmodel or parent:GetModel(), newskin or parent:GetSkin()
		
		print( "Preparing to adjust antlion:", parent, mdl, skin )
		
		local ent = LocalPlayer().AntlionModel
		
		if !ent then return end
		
		ent:SetParent( parent )
		ent:SetModel( mdl )
		ent:SetSkin( skin )
		
		print( "Adjusting antlion:", ent, parent, mdl, skin )
		
	end
	
end

/*------------------------------------
	RemoveAntlionModel
------------------------------------*/
function GM:RemoveAntlionModel( ply )
	
	if !ply then return end
	
	if SERVER then
		
		umsg.Start( "RemoveAntlionModel", ply )
			umsg.Entity( ply ) -- parent
		umsg.End()
		
	else
		
		ply = ply or LocalPlayer()
		print( "Removing antlion:", ply, ply.AntlionModel )
		SafeRemoveEntity( ply.AntlionModel )
		ply.AntlionModel = nil
		
	end
	
end


/*------------------------------------
	OnEntityCreated
------------------------------------*/
function GM:OnEntityCreated( ent )
	
	if IsValid(ent) and CLIENT and ent:GetClass() == "C_HL2MPRagdoll" then
		
		print(ent)
		local owner = ent:GetNWEntity( "Player" )
		
		if owner then
			
			ent:SetSkin( owner:GetSkin() )
			
		end
		
	end
	
end


// Only store original key values the first time around.
local firstTimeKeyVals = true

/*------------------------------------
	InitPostEntity
------------------------------------*/
function GM:InitPostEntity()
	
	GAMEMODE:ReplaceThumpers()
	
	for k, v in pairs( ents.FindByClass( ENTITY_THUMPER_CLASS ) ) do

		GAMEMODE.PlayersPastThumperRadius[v] = {}
		
	end
	
	if CLIENT then
		
		return
		
	end
	
	--PrintTable(ENT_INPUT_STORAGE)
	GAME_EVENTS = ents.FindByClass( ENTITY_EVENTS_CLASS )[1]
	GAME_RULES = ents.FindByClass( ENTITY_RULES_CLASS )[1]
	
	if GAME_EVENTS then --and GAME_RULES 
		GAMEMODE:SetGameType( GAME_EVENTS.Mode ) --or GAME_RULES.Mode
	else
		GAMEMODE.IsMapValid = false
		error( "FATAL ERROR: COULD NOT FIND A ENTITY_EVENTS_CLASS ENTITY IN MAP "..string.upper( game.GetMap() ).."!" )
		return --SHITE!!!!
	end
	
	BATTLE_ZONES = {}
	ANTLION_SPAWNS = {}
	ANTLION_BATTLE_SPAWNS = {}
	REBEL_INITIAL_SPAWNS = ents.FindByClass( "info_player_start" )
	REBEL_PROGRESS_SPAWNS = ents.FindByClass( "info_player_progress" )
	
	for k, v in pairs( ents.FindByClass( "logic_antlion_battlezone" ) ) do
		table.insert( BATTLE_ZONES, v )
		ANTLION_BATTLE_SPAWNS[v] = ents.FindByName( v.KeyVals.Spawns )
	end
	
	for k, v in pairs( ents.FindByClass( "info_player_antlion" ) ) do
		table.insert( ANTLION_SPAWNS, v )
	end
	
	firstTimeKeyVals = false
	
end

GM.BaseStoreOutput = nil
GM.BaseTriggerOutput = nil

/*------------------------------------
	EntityKeyValue
------------------------------------*/
function GM:EntityKeyValue( ent, key, value )

	ent.KeyVals = ent.KeyVals or {}
	ent.KeyVals[key] = value
	
	if !GAMEMODE.BaseStoreOutput or !GAMEMODE.BaseTriggerOutput then
	
		local e = scripted_ents.Get( "base_entity" )
		GAMEMODE.BaseStoreOutput = e.StoreOutput
		GAMEMODE.BaseTriggerOutput = e.TriggerOutput
		
	end

	if key:lower():sub( 1, 2 ) == "on" then
	
		ENT_OUTPUT_STORAGE[ent] = ENT_OUTPUT_STORAGE[ent] or {}
		ENT_OUTPUT_STORAGE[ent][key] = ENT_OUTPUT_STORAGE[ent][key] or {}
		
		if !ent.StoreOutput or !ent.TriggerOutput then -- probably an engine entity
		
			ent.StoreOutput = GAMEMODE.BaseStoreOutput
			ent.TriggerOutput = GAMEMODE.BaseTriggerOutput
			
			if ent.StoreOutput then
				
				--print(ent, key, value)
				ent:StoreOutput( key, value )
				
			end
			
			--ent.AcceptInput = function( self, name, activator, caller, data )
				
				--print( self, name, activator, caller, data )
				
			--end
			
		end
		
		local data = string.Explode( ",", value )
		if data and data[1] and data[2] and ents.FindByName( data[1] )[1] then
		
			--print(ent, value)
			local targets, input, param, delay, times = unpack(data)
			
			ENT_INPUT_STORAGE[ targets ] = ENT_INPUT_STORAGE[ targets ] or {}
			
			table.insert( ENT_INPUT_STORAGE[ targets ], { Activator=ent, Output=key, Input=input, Parameters=param, Delay=delay, Times=times } )
			
		end
		
		table.insert( ENT_OUTPUT_STORAGE[ent][key], value )
		
	end
	
	if firstTimeKeyVals then
	
		if table.HasValue( NO_CLEANUP_ENTS, ent:GetClass() ) then
		
			local t = {}
			
			t.KeyVals = t.KeyVals or {}
			t.KeyVals[key] = value
			
			t.Entity = t.Entity or ent
			t.Class = t.Class or ent:GetClass()
			t.Pos = t.Pos or ent:GetPos()
			t.Ang = t.Ang or ent:GetAngles()
			
			table.insert( ENT_RESET_STORAGE, t )
			
		end
		
	end
	
end


/*------------------------------------
	MapResetEntities
------------------------------------*/
function GM:ResetMapEntities()
	
	if !SERVER then return end
	
	game.CleanUpMap( false, NO_CLEANUP_ENTS )
	
	local e = NULL
	
	GAMEMODE:ReplaceThumpers()
	
	for ent, output in pairs( ENT_OUTPUT_STORAGE ) do
	
		for _, input in pairs( output ) do
		
			ent:TriggerOutput( output, ent )
			--print(ent,output,input)
			
		end
		
	end
	
	for k, v in pairs( ENT_RESET_STORAGE ) do
	
		if !IsValid(v.Entity) then
		
			e = ents.Create( v.Class )
			e:Spawn()
			e:Activate()
			
		else
		
			e = v.Entity
			
		end
		
		e:SetPos( v.Pos )
		e:SetAngles( v.Ang )
		
		for key, value in pairs( v.KeyVals ) do
			
			e:SetKeyValue( key, tostring(value) )
			
		end
		
	end
	
	if GAMEMODE:GetRoundNumber() == GAMEMODE.NumRounds - 1 then
	
		GAMEMODE.IsLastRound = true
		
	end
	
end

