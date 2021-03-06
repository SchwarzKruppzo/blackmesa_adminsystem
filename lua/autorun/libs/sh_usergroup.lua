//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Usergroup system alpha
//===================================================================================

bmas.usergroups = {
	superadmin = {
		name = "Super Admin",
		color = Color(75,220,0),
		access = 1
	},
	admin = {
		name = "Admin",
		color = Color(220,160,0),
		access = 2
	},
	user = {
		name = "User",
		color = Color(60,150,180),
		access = 3
	},
}

local meta = FindMetaTable("Player")

if SERVER then
	function meta:BMAS_SetAccess(str)
		self:SetNWString("m_sAccess",str)
		if !self:IsBot() then
			self:SetPData("m_sAccess",str) // holy crap
		end
	end
end
function meta:BMAS_GetAccess() // IT MYST BE SHARED!!1111
	return self:GetNWString("m_sAccess")
end
function bmas.SetupAccess( ply ) // local because capster
	if ply:BMAS_GetAccess() == "" then
		if ply:GetPData("m_sAccess") == nil then
			ply:BMAS_SetAccess("user")
		else
			ply:BMAS_SetAccess(ply:GetPData("m_sAccess"))
		end
	end
end

local meta = FindMetaTable("Player")
function meta:IsSuperAdmin()
	if not bmas then return false end
	if self:BMAS_GetAccess() == "" then return false end
	
	local access = bmas.usergroups[self:BMAS_GetAccess()].access
	if access == 1 then
		return true
	else
		return false
	end
end
function meta:IsAdmin()
	if not bmas then return false end
	if self:BMAS_GetAccess() == "" then return false end
	
	local access = bmas.usergroups[self:BMAS_GetAccess()].access
	if access == 2 or access == 1 then
		return true
	else
		return false
	end
end
function meta:IsUserGroup( str )
	if not bmas then return false end
	if self:BMAS_GetAccess() == str then
		return true
	else
		return false
	end
end
function bmas.OverrideTeamLib() // hack 228
	if gamemode.Get("sandbox") then
		function team.GetName( number )
			local name = bmas.usergroups[ number ].name
			return name
		end
		function team.GetColor( number )
			if type(number) == "string" then
				if bmas.usergroups[ number ] then
					local clr = bmas.usergroups[ number ].color
					return clr
				end
				return Color(255,255,255,255)
			else
				return Color(255,255,255,255)
			end
		end
	end
	local meta = FindMetaTable("Player")
	if gamemode.Get("sandbox") then
		function meta:Team()
			return self:BMAS_GetAccess()
		end
	end
end

-- hooks
hook.Add("PlayerInitialSpawn","BMAS_LIB_USERGROUP_PIS",bmas.SetupAccess)
hook.Add("Initialize","BMAS_OVERRIDE_TEAM_LIB",bmas.OverrideTeamLib)

if SERVER then
	bmas.CreateCommand( "setaccess", function(ply,args)
		local target,nick = bmas.FindPlayer( args[1] )
		local rank = args[2]
		if IsValid(target) then
			if target:IsPlayer() then
				if !bmas.usergroups[rank] then 
					bmas.SystemNotify(ply,bmas.colors.red,"No such usergroup found")
					return
				end
				if target:BMAS_GetAccess() ~= rank then
					target:BMAS_SetAccess(rank)
					bmas.CommandNotify(ply," has set ",nick,"",""," access to ",rank)
				end
			end
		end
	end, 2 , "<player name> <usergroup name>" )
end