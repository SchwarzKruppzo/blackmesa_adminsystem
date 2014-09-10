//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Log System
//===================================================================================

local function DestroyColor(...)
        local args = {...}
        for k,v in pairs(args) do
                if type(v) == "table" and v.r then
                        table.remove(args, k)
                end
        end
        return args
end
function bmas.Log(...)
	local args = DestroyColor(...)
	MsgC(Color(255, 255, 255), "[",Color(255, 200, 200), "BMAS - LOG",Color(255, 255, 255), "] ")
	print(bmas.unpack(args))
	for k,v in pairs(player.GetAll()) do
		if v:IsAdmin() then
			umsg.Start( "BMAS_Log", v )
				umsg.String( bmas.unpack(args) )
			umsg.End()
		end
	end
end

function bmas.LOG_PlayerSpawnProp(ply, model, ent)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") spawned prop with model: "..model)
end
hook.Add( "PlayerSpawnedProp", "BMAS_LIB_LOG_PSP", bmas.LOG_PlayerSpawnProp )
function bmas.LOG_PlayerSpawnEffect(ply, model, ent)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") spawned effect with model: "..model)
end
hook.Add( "PlayerSpawnedEffect", "BMAS_LIB_LOG_PSE", bmas.LOG_PlayerSpawnEffect )
function bmas.LOG_PlayerSpawnNPC(ply, ent)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") spawned npc with class: "..ent:GetClass())
end
hook.Add( "PlayerSpawnedNPC", "BMAS_LIB_LOG_PSNPC", bmas.LOG_PlayerSpawnNPC )
function bmas.LOG_PlayerSpawnSENT(ply, ent)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") spawned scripted entity with class: "..ent:GetClass())
end
hook.Add( "PlayerSpawnedSENT", "BMAS_LIB_LOG_PSENT", bmas.LOG_PlayerSpawnSENT )
function bmas.LOG_PlayerSpawnVehicle(ply, ent)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") spawned vehicle with class: "..ent:GetClass())
end
hook.Add( "PlayerSpawnedVehicle", "BMAS_LIB_LOG_PSV", bmas.LOG_PlayerSpawnVehicle )
function bmas.LOG_PlayerSpawnRagdoll(ply, model, ent)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") spawned ragdoll with model: "..ent:GetModel())
end
hook.Add( "PlayerSpawnedRagdoll", "BMAS_LIB_LOG_PSP", bmas.LOG_PlayerSpawnRagdoll )
function bmas.LOG_CanTool(ply, trace, tool)
	bmas.Log("Player "..ply:Name().." ("..ply:SteamID()..") used tool "..tool.." to "..tostring(trace.Entity))
end
hook.Add( "CanTool", "BMAS_LIB_LOG_CT", bmas.LOG_CanTool )