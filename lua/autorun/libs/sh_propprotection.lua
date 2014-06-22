//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Basic Prop Protection
//===================================================================================

local meta = FindMetaTable("Entity")
if SERVER then
	function meta:BMAS_SetOwner( ply )
		self:SetNWEntity( "m_hOwner", ply )
	end
end
function meta:BMAS_GetOwner( ply )
	return self:GetNWEntity( "m_hOwner" )
end


if SERVER then
	function bmas.PlayerSpawnProp(ply, model, ent)
		ent:BMAS_SetOwner( ply )
	end
	hook.Add( "PlayerSpawnedProp", "BMAS_LIB_PP_PSP", bmas.PlayerSpawnProp )
	function bmas.PlayerSpawnEffect(ply, model, ent)
		ent:BMAS_SetOwner( ply )
	end
	hook.Add( "PlayerSpawnedEffect", "BMAS_LIB_PP_PSP", bmas.PlayerSpawnEffect )
	function bmas.PlayerSpawnNPC(ply, ent)
		ent:BMAS_SetOwner( ply )
	end
	hook.Add( "PlayerSpawnedNPC", "BMAS_LIB_PP_PSP", bmas.PlayerSpawnNPC )
	function bmas.PlayerSpawnSENT(ply, ent)
		ent:BMAS_SetOwner( ply )
	end
	hook.Add( "PlayerSpawnedSENT", "BMAS_LIB_PP_PSP", bmas.PlayerSpawnSENT )
	function bmas.PlayerSpawnVehicle(ply, ent)
		ent:BMAS_SetOwner( ply )
	end
	hook.Add( "PlayerSpawnedVehicle", "BMAS_LIB_PP_PSP", bmas.PlayerSpawnVehicle )
	function bmas.PlayerSpawnRagdoll(ply, model, ent)
		ent:BMAS_SetOwner( ply )
	end
	hook.Add( "PlayerSpawnedRagdoll", "BMAS_LIB_PP_PSP", bmas.PlayerSpawnRagdoll )
end
function bmas.PhysgunPickup(ply, ent)
	if ply:IsAdmin() then
		return true
	else
		if ent:BMAS_GetOwner() == ply then
			return true
		else
			return false
		end
	end
end
hook.Add( "PhysgunPickup", "BMAS_LIB_PP", bmas.PhysgunPickup )
function bmas.CanTool(ply, trace, tool)
	local ent = trace.Entity
	if ply:IsAdmin() then
		return true
	else
		if ent:BMAS_GetOwner() == ply then
			return true
		else
			return false
		end
	end
end
hook.Add( "CanTool", "BMAS_LIB_PP", bmas.CanTool )