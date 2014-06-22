//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Like "user can't grab admin"
//===================================================================================

function bmas.PhysgunPickup( ply, ent )
	if ent:IsPlayer() then
		if ply:IsSuperAdmin() then
			return true
		elseif ply:IsAdmin() then
			if ent:IsSuperAdmin() then
				return false
			else
				return true
			end
		end
	end
end
hook.Add("PhysgunPickup", "BMAS_LIB_RESTRICTIONS_PP", bmas.PhysgunPickup)