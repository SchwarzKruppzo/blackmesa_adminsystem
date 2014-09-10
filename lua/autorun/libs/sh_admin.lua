//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Admin commands and ban system
//===================================================================================

timer.Simple(.1,function()
bmas.lBanTime = {}
bmas.lBanReason = {}
bmas.lBanTime[0] = " permently"
bmas.lBanTime[1] = " for %s minutes"
bmas.lBanReason[""] = " without reason."
bmas.lBanReason["1"] = " with reason %s"

local meta = FindMetaTable("Player")
function meta:IsBanned()
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "bmas_bans.txt" )
	if read[ self:SteamID() ] then
		return true,read[ self:SteamID() ].r
	else
		return false,""
	end
end
function bmas.Ban( steamid, time, reason, banner )
	local nick = "Console"
	if banner:IsPlayer() then
		nick = banner:Nick() // cheat 228
	end
	
	local save = {}
	save[steamid] = {t = time,r = reason, comid = util.SteamIDTo64( steamid ), banner = nick}
	local str = util.TableToJSON( save )
	
	if !file.Exists( "bmas_bans.txt", "DATA" ) then
		luadata.WriteFile( "bmas_bans.txt", save )
	else
		local read = luadata.ReadFile( "bmas_bans.txt" )
		read[steamid] = {t = time,r = reason, comid = util.SteamIDTo64( steamid ), banner = nick}
		luadata.WriteFile( "bmas_bans.txt", read )
	end
end
function bmas.UnBan( steamid )
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "bmas_bans.txt" )
	if read[ steamid ] then
		read[ steamid ].banner = nil
		read[ steamid ].comid = nil
		read[ steamid ].t = nil
		read[ steamid ].r = nil
		read[ steamid ] = nil
		luadata.WriteFile( "bmas_bans.txt", read )
	end
end
function bmas.IsBanned( comid )
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "bmas_bans.txt" )
	for k,v in pairs(read) do
		if v.comid == comid then
			return true,"You are banned by "..v.banner.." with reason "..v.r
		end
	end
	return false,""
end
function bmas.IsBannedSteamID( steamid )
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = luadata.ReadFile( "bmas_bans.txt" )
	if read[ steamid ] then
		return true
	else
		return false
	end
end
if SERVER then
	connect_manager = {}

	function connect_manager.Join(...)
		MsgC(Color(0,255,0), "[")
		MsgC(Color(0,200,0), "Join")
		MsgC(Color(0,255,0), "] ")
		print(...)
	end

	function connect_manager.WrongPass(...)
		MsgC(Color(255,0,0), "[")
		MsgC(Color(200,0,0), "WrongPass")
		MsgC(Color(255,0,0), "] ")
		print(...)
	end

	function connect_manager.Banned(...)
		MsgC(Color(255,0,0), "[")
		MsgC(Color(200,0,0), "Banned")
		MsgC(Color(255,0,0), "] ")
		print(...)
	end

	function connect_manager.Disconnect(...)
		MsgC(Color(200,200,200), "[")
		MsgC(Color(150,150,150), "Disconnect")
		MsgC(Color(200,200,200), "] ")
		print(...)
	end
	gameevent.Listen( "player_disconnect" )
	
	function bmas.CheckBan(steamID, ipAdderss, svPass, clPass, strName)
		connect_manager.Join("Nick: "..strName..". Steam Profile: http://steamcommunity.com/profiles/" .. steamID.." IP Address: "..ipAdderss )
		local ban,reason = bmas.IsBanned( steamID  )
		if ban then
			connect_manager.Banned("Kick: "..strName)
			return false, reason
		end
		if svPass != "" then
			if svPass != clPass then
				connect_manager.WrongPass("Kick: "..strName)
				return false, "#GameUI_ServerRejectBadPassword"
			end
		end
	end
	
	-- hooks
	hook.Add("CheckPassword","BMAS_LIB_CHECKBAN",bmas.CheckBan)
	hook.Add( "player_disconnect", "BMAS_LIB_DISCONNECT", function( data )
		connect_manager.Disconnect(data.name.." ("..data.reason..")")
	end)
	
	bmas.CreateCommand( "rcon", function( ply, args )
		if args[1] == nil then
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: commands expected, got shit." )
			return
		else
			RunConsoleCommand( unpack(args))
		end
	end, 1 , "<commands>" )
	
	bmas.CreateCommand( "kick", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		local reason = args[2] or ""
		if IsValid( t_ply ) then
			if reason ~= "" then
				bmas.CommandNotify(ply," has kicked ",nick,"",""," with reason ",reason)
			else
				bmas.CommandNotify(ply," has kicked ",nick,"",""," without reason.")
			end
			t_ply:Kick( reason )
		end
	end, 2 , "<player name> [reason]" )
	bmas.CreateCommand( "ban", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		local time = args[2] or 0
		local reason = table.concat( args, " ", 3)
		if IsValid( t_ply ) then
			local correct_time = 0
			if tonumber(time) ~= nil then
				correct_time = tonumber(time)
			end
			
			if correct_time ~= 0 then
				bmas.Ban( t_ply:SteamID(), tostring( os.time() + correct_time*60 ), reason, ply)
			elseif correct_time <= 0 then
				bmas.Ban( t_ply:SteamID(), 0,  reason, ply)
			end
			
			local langID_time = 0
			local langID_reason = ""
			if correct_time > 0 then  langID_time   =  1  end
			if reason ~= ""     then  langID_reason = "1" end
			local m_sReason = string.format( bmas.lBanReason[ langID_reason ], reason )
			local m_sTime = string.format( bmas.lBanTime[ langID_time ], correct_time )
			bmas.CommandNotify(ply," has banned ",nick,m_sTime,"",m_sReason)
			
			t_ply:Kick( reason )
		end
	end, 2 , "<player name> [time minutes] [reason]" )	
	bmas.CreateCommand( "banid", function( ply, args )	
		local steamID = args[1]
		local time = args[2] or 0
		local reason = table.concat( args, " ", 3 )
		if !string.match( steamID, "STEAM_[0-5]:[0-9]:[0-9]+" ) then
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: SteamID expected, got shit." )
			return
		elseif bmas.IsBannedSteamID( steamID ) then
			bmas.SystemNotify( ply, bmas.colors.red, "This SteamID is already banned." )
			return
		else
			local correct_time = 0
			if tonumber(time) ~= nil then
				correct_time = tonumber(time)
			end
			if correct_time ~= 0 then
				bmas.Ban( steamID, tostring( os.time() + correct_time*60 ), reason, ply)
			elseif correct_time <= 0 then
				bmas.Ban( steamID, 0,  reason, ply)
			end
			
			local langID_time = 0
			local langID_reason = ""
			if correct_time > 0 then  langID_time   =  1  end
			if reason ~= ""     then  langID_reason = "1" end
			local m_sReason = string.format( bmas.lBanReason[ langID_reason ], reason )
			local m_sTime = string.format( bmas.lBanTime[ langID_time ], correct_time )
			bmas.CommandNotify(ply," has banned SteamID ",steamID,m_sTime,"",m_sReason)

			for k,v in pairs(player.GetAll()) do
				if v:SteamID() == steamID then
					v:Kick( reason )
				end
			end
		end
	end, 2 , "<steamid> [time minutes] [reason]")	
	bmas.CreateCommand( "unban", function( ply, args )	
		local steamID = args[1]
		if !string.match( steamID, "STEAM_[0-5]:[0-9]:[0-9]+" ) then
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: SteamID expected, got shit." )
			return
		elseif not bmas.IsBannedSteamID( steamID ) then
			bmas.SystemNotify( ply, bmas.colors.red, "This SteamID is already unbanned." )
			return
		else
			bmas.UnBan( steamID )
			bmas.CommandNotify(ply," has unbanned SteamID ",steamID,"","","")
		end
	end, 1 , "<steamid>" )
	bmas.CreateCommand( "banlist", function( ply, args )
		if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
		local read = luadata.ReadFile( "bmas_bans.txt" )
		if table.GetFirstKey(read) == nil then 
			bmas.SystemNotify( ply,bmas.colors.red, "No such bans found. " )
			return
		else
			bmas.SystemNotify( ply,bmas.colors.white, "Ban list: " )
		end
		for k,v in pairs( read ) do
			bmas.SystemNotify( ply, bmas.colors.white,"STEAMID: ", bmas.colors.gray, k , bmas.colors.white," Reason: ", bmas.colors.gray, v.r , bmas.colors.white," Banned by: ", bmas.colors.gray, v.banner )
		end
	end, 3 , "<none>" )
	bmas.CreateCommand( "crash", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		if IsValid(t_ply) then
			t_ply:SendLua("while true do end")
			bmas.CommandNotify(ply," has crashed ",nick,"","","")
		end
	end, 1 , "<player name>" )
	bmas.CreateCommand( "cleanupserver", function( ply, args )	
		local time = args[1]
		if cleanup.GetStatus() or shutdown.GetStatus() then
			bmas.SystemNotify( ply, bmas.colors.red, "Another event is already started." )
			return
		end
		if time == nil then
			time = 61
		end
		cleanup.Start(time)
		bmas.CommandNotify(ply," has started cleanup event.","","","")

	end, 2 , "[time seconds]" )
	bmas.CreateCommand( "shutdown", function( ply, args )	
		local time = args[1]
		if cleanup.GetStatus() or shutdown.GetStatus() then
			bmas.SystemNotify( ply, bmas.colors.red, "Another event is already started." )
			return
		end
		if time == nil then
			time = 61
		end
		shutdown.Start(time)
		bmas.CommandNotify(ply," has started server shutdown event.","","","")

	end, 1 , "[time seconds]" )
	bmas.CreateCommand( "abort", function( ply, args )	
		if cleanup.GetStatus() then
			cleanup.Abort()
			bmas.CommandNotify(ply," has aborted cleanup event.","","","")
		elseif shutdown.GetStatus() then
			shutdown.Abort()
			bmas.CommandNotify(ply," has aborted server shutdown event.","","","")
		else
			bmas.SystemNotify( ply, bmas.colors.red, "No such event found." )
			return
		end
	end, 2 , "<none>" )
	bmas.CreateCommand( "goto", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		if IsValid(t_ply) then
			ply:SetPos(t_ply:GetPos()-t_ply:GetForward()*50)
			bmas.CommandNotify(ply," has teleported to ",nick,"","","")
		end
	end, 1 , "<player name>" )	
	bmas.CreateCommand( "bring", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		local t2_ply,nick2 = bmas.FindPlayer( args[1] )
		if IsValid(t_ply) then
			if IsValid(t2_ply) then
				t_ply:SetPos(t2_ply:GetPos()+t2_ply:GetForward()*50)
				bmas.CommandNotify(ply," has bring ",nick," to ",nick2,"")
			else
				t_ply:SetPos(ply:GetPos()+ply:GetForward()*50)
				bmas.CommandNotify(ply," has bring ",nick," to ","self","")
			end
		end
	end, 1 , "<player name> [player2 name]" )	
	bmas.CreateCommand( "slay", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		if IsValid(t_ply) then
			t_ply:Kill()
			bmas.CommandNotify(ply," has slayed ",nick,"","","")
		end
	end, 1 , "<player name>" )	
	bmas.CreateCommand( "spawn", function( ply, args )	
		local t_ply,nick = bmas.FindPlayer( args[1] )
		if IsValid(t_ply) then
			t_ply:Spawn()
			bmas.CommandNotify(ply," has spawned ",nick,"","","")
		end
	end, 1 , "<player name>" )
	
	
	timer.Create("BMAS_UNBAN",5,0,function()
		if file.Exists( "bmas_bans.txt", "DATA" ) then
			local read = luadata.ReadFile( "bmas_bans.txt" )
			for k,v in pairs(read) do
				if os.time() >= tonumber(v.t) then
					if tonumber(v.t) ~= 0 then
						bmas.Notify(bmas.colors.gray,k,bmas.colors.white," is unbanned (Ban time is reached)")
						read[ k ] = nil
						luadata.WriteFile( "bmas_bans.txt", read )
					end
				end
			end
		end
	end)
	
	
	bmas.CreateCommand( "god", function( ply, args )
		local t_ply,nick = bmas.FindPlayer( args[1] )
		if t_ply then
			if !t_ply:HasGodMode() then
				t_ply:GodEnable()
				bmas.CommandNotify(ply," has enabled godmode for ",nick)
			else
				t_ply:GodDisable()
				bmas.CommandNotify(ply," has disabled godmode for ",nick)			
			end
		end
	end, 2 , "<player name>" )
	
	bmas.CreateCommand( "cmds", function( ply, args )	
		bmas.SystemNotify( ply,bmas.colors.white, "Available commands: " )
		for k,v in pairs( bmas.commands ) do
			local canRun,reason = hook.Call( "BMAS_COMMAND_CheckAccess", GAMEMODE, ply, k )
			local color
			if canRun then
				color = bmas.colors.gray
			else
				color = bmas.colors.red
			end
			bmas.SystemNotify( ply, color, k, bmas.colors.white, " "..v.desc )
		end
	end, 3 , "<none>" )
	bmas.CreateCommand( "cleardecals", function( ply, args )	
		for k,v in pairs( player.GetAll() ) do
			v:ConCommand('r_cleardecals 1')
		end
		bmas.CommandNotify(ply," has removed all decals.","")
	end, 1 , "<none>" )
	local function PlayerExists( steamid )
		for k,v in pairs(player.GetAll()) do
			if v:SteamID() == steamid then
				return v
			end
		end
		return nil
	end
	bmas.CreateCommand( "cleanup", function( ply, args )
		local t_ply,nick = bmas.FindPlayer( args[1] )
		if IsValid(t_ply) then
			if cleanup and cleanup.CC_Cleanup then
				cleanup.CC_Cleanup(t_ply,"gmod_cleanup",{})
				bmas.CommandNotify(ply," has cleanuped ",nick,"'s props.","","")
			end
		elseif args[1] == nil then
			for k,v in pairs(ents.GetAll()) do
				if string.match( v:BMAS_GetOwner(), "STEAM_[0-5]:[0-9]:[0-9]+" ) then
					if !IsValid(PlayerExists(v:BMAS_GetOwner())) then
						v:Remove()
					end
				end
			end
			bmas.CommandNotify(ply," has cleanuped disonnected props.","")
		end
	end, 2, "<player name>" )
end


end)