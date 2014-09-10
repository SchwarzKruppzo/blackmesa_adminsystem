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
		self:SetNWString( "m_hOwner", ply:SteamID() )
	end
end
function meta:BMAS_GetOwner()
	return self:GetNWString( "m_hOwner" )
end

local function PlayerExists( steamid )
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == steamid then
			return v
		end
	end
	return nil
end

local metaply = FindMetaTable("Player")

function metaply:BMAS_GetFriends()
	local decoded = util.JSONToTable(self:GetPData("ppFriends") or "[]") or {}
	return decoded
end
function metaply:BMAS_CheckFriends( steamid )
	local decoded = self:BMAS_GetFriends() or {}
	for k,v in pairs(decoded) do
		if v.s == steamid then
			return true
		end
	end
	return false
end
function metaply:BMAS_CheckPropAccess( ent )
	if self:IsAdmin() then
		return true
	else
		if ent:BMAS_GetOwner() == self:SteamID() then
			return true
		elseif !ent:IsPlayer() then
			if IsValid(PlayerExists(ent:BMAS_GetOwner())) then
				if PlayerExists(ent:BMAS_GetOwner()):BMAS_CheckFriends( self:SteamID() ) then
					return true
				else
					return false
				end
			end
		else
			return false
		end
	end
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
	return ply:BMAS_CheckPropAccess( ent )
end
hook.Add( "PhysgunPickup", "BMAS_LIB_PP", bmas.PhysgunPickup )


if SERVER then
	function meta:BMAS_AddFriend( handle )
		if handle:IsPlayer() then
			local nick = handle:Nick()
			local steamid = handle:SteamID()
			if self:BMAS_CheckFriends( steamid ) then return end
			
			local tableToSave = {
				n = nick,
				s = steamid
			}
			
			local decoded = self:BMAS_GetFriends()
			table.insert(decoded,tableToSave)
			local encode = util.TableToJSON(decoded)
			
			self:SetPData( "ppFriends", encode )
		end
	end
	function meta:BMAS_RemoveFriend( id )
		local decoded = self:BMAS_GetFriends()
		if not decoded[id] then return end
		decoded[id] = nil
		local encode = util.TableToJSON(decoded)
		self:SetPData( "ppFriends", encode )
	end

	
	bmas.CreateCommand( "addfriend", function(ply,args)
		local target = bmas.FindPlayer(args[1])
		if IsValid(target) then
			ply:BMAS_AddFriend( target )
			bmas.SystemNotify(ply,bmas.colors.gray,target:Nick(),bmas.colors.white," now can use your objects.")
		end
	end, 3 , "<player name>" )
	bmas.CreateCommand( "removefriend", function(ply,args)
		local friends = ply:BMAS_GetFriends()
		local id = tonumber(args[1])
		if friends[id] then
			bmas.SystemNotify(ply,bmas.colors.gray,friends[id].n,bmas.colors.white," now can't use your objects.")
			ply:BMAS_RemoveFriend( id )
		else
			bmas.SystemNotify(ply,bmas.colors.red,"No such friend found.")
			return
		end
	end, 3 , "<index>" )
	bmas.CreateCommand( "friends", function(ply,args)
		local friends = ply:BMAS_GetFriends()
		if #friends == 0 then
			bmas.SystemNotify( ply,bmas.colors.red, "No such friends found. " )
			return
		else
			bmas.SystemNotify( ply,bmas.colors.white, "Friends: " )
		end
		for k,v in pairs( friends ) do
			bmas.SystemNotify( ply, bmas.colors.white, "ID: ", bmas.colors.gray, k, bmas.colors.white, " - Nick: ", bmas.colors.gray, v.n, bmas.colors.white, " - SteamID: ", bmas.colors.gray, v.s )
		end
	end, 3 , "<none>" )
	
	// Start code by Falco
	if cleanup then
		bmas.oldcleanup = bmas.oldcleanup or cleanup.Add
		function cleanup.Add(ply, Type, ent)
			if not IsValid(ply) or not IsValid(ent) then return bmas.oldcleanup(ply, Type, ent) end

			ent:BMAS_SetOwner( ply )

			if ent:GetClass() == "gmod_wire_expression2" then
				ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
			
			return bmas.oldcleanup(ply, Type, ent)
		end
	end
	local PLAYER = FindMetaTable("Player")

	if PLAYER.AddCount then
		bmas.oldcount = bmas.oldcount or PLAYER.AddCount
		function PLAYER:AddCount(Type, ent)
			if not IsValid(self) or not IsValid(ent) then return bmas.oldcount(self, Type, ent) end
			--Set the owner of the entity
			ent:BMAS_SetOwner(self)
			return bmas.oldcount(self, Type, ent)
		end
	end
	if undo then
		local AddEntity, SetPlayer, Finish =  undo.AddEntity, undo.SetPlayer, undo.Finish
		local Undo = {}
		local UndoPlayer
		function undo.AddEntity(ent, ...)
			if type(ent) ~= "boolean" and IsValid(ent) then table.insert(Undo, ent) end
			AddEntity(ent, ...)
		end

		function undo.SetPlayer(ply, ...)
			UndoPlayer = ply
			SetPlayer(ply, ...)
		end

		function undo.Finish(...)
			if IsValid(UndoPlayer) then
				for k,v in pairs(Undo) do
					v:BMAS_SetOwner(UndoPlayer)
				end
			end
			Undo = {}
			UndoPlayer = nil

			Finish(...)
		end
	end
	// End code by Falco
	
	function bmas.PP_PlayerDisconnected( ply )
		for k,v in pairs(ents.GetAll()) do
			if IsValid(PlayerExists(v:BMAS_GetOwner())) then
				if ply == PlayerExists(v:BMAS_GetOwner()) then
					v:Remove()
				end
			end
		end		
	end
	hook.Add("PlayerDisconnected","BMAS_LIB_PP_PD2",bmas.PP_PlayerDisconnected)
end


if CLIENT then
	local function PropP_HUD()
		if !IsValid(LocalPlayer()) then return end
		local self = LocalPlayer()
		local trace = self:GetEyeTrace()
		local ent = trace.Entity
		local color = Color(255,255,255)
		local text = ""
		if !IsValid(ent) then return end
		if ent:IsPlayer() then return end
		
		if self:BMAS_CheckPropAccess( ent ) then
			color = Color(0,255,0)
		else
			color = Color(255,0,0)
		end
		if IsValid(PlayerExists(ent:BMAS_GetOwner())) then 
			text = "Owner: " .. PlayerExists(ent:BMAS_GetOwner()):Nick()
		else
			text = "Owner: Disconnected Player"
		end
		
		surface.SetFont("DebugFixed")
		local w,h = surface.GetTextSize( text )   
		
		surface.SetDrawColor(Color(0,0,0,200))
		surface.DrawRect( 2.5, ScrH()/2 + 1.5 , w + 5, h )

		surface.SetTextColor(color)
		surface.SetTextPos(5,ScrH()/2 )
		surface.DrawText(text)
	end
	hook.Add("HUDPaint","BMAS_HP_PPHUD",PropP_HUD)
end