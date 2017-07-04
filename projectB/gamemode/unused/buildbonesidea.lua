
local EntsWithBBPFuncs = {}
local EntityBuildBonesFuncs = {}
function GM:OnEntityCreated( ent )
	
	CheckForBuildBonesFunc( ent )
	
end

local function CheckForBuildBonesFunc( ent )
	
	if !IsValid( ent ) then
		
		if EntityBuildBonesFuncs[ent] or EntsWithBBPFuncs[ent] then
			
			EntityBuildBonesFuncs[ent] = nil
			EntsWithBBPFuncs[ent] = nil
			
		end
		
		return
		
	end
	
	if ent.BuildBonePositions then
		
		if !EntsWithBBPFuncs[ent] then

			EntsWithBBPFuncs[ent] = true
			EntityBuildBonesFuncs[ent] = ent.BuildBonePositions
			
			ent.BuildBonePositions = function( self, NumBones, NumPhysBones )
			
				EntityBuildBonesFuncs[self]( self, NumBones, NumPhysBones )
				
				if EntsWithBBPFuncs[self] then
					
					gamemode.Call( "EntityBuildBonePositions", self, NumBones, NumPhysBones )
					
				end
				
			end
			
		end
		
	elseif EntityBuildBonesFuncs[ent] then
		
		if EntsWithBBPFuncs[ent] then
			
			EntsWithBBPFuncs[ent] = false
			EntityBuildBonesFuncs[ent] = nil
			
		end
		
	end

end

for _, ent in pairs( ents.GetAll() ) do
	
	if ent.BuildBonePositions then
		
		CheckForBuildBonesFunc( ent )
		
	end
	
end


function GM:EntityBuildBonePositions( ent, NumBones, NumPhysBones )
	
	
	
end





