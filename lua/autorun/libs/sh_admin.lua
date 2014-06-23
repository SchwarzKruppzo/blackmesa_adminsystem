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
local meta = FindMetaTable("Player")
function meta:IsBanned()
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = file.Read( "bmas_bans.txt", "DATA" )
	local decoded = util.JSONToTable( read ) or {}
	if decoded[ self:SteamID() ] then
		return true,decoded[ self:SteamID() ].r
	else
		return false,""
	end
end
function bmas.Ban( steamid, time, reason)
	local save = {}
	save[steamid] = {t = time,r = reason}
	local str = util.TableToJSON( save )
	
	if !file.Exists( "bmas_bans.txt", "DATA" ) then
		file.Write( "bmas_bans.txt", str )
	else
		local read = file.Read( "bmas_bans.txt", "DATA" )
		local decoded = util.JSONToTable( read ) or {}
		decoded[steamid] = {t = time,r = reason}
		local encode = util.TableToJSON(decoded)
		file.Write( "bmas_bans.txt", encode )
	end
end
function bmas.UnBan( steamid )
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = file.Read( "bmas_bans.txt", "DATA" )
	local decoded = util.JSONToTable( read ) or {}	
	if decoded[ steamid ] then
		decoded[ steamid ].t = nil
		decoded[ steamid ].r = nil
		decoded[ steamid ] = nil
		local encode = util.TableToJSON(decoded)
		file.Write( "bmas_bans.txt", encode )
	end
end
function bmas.IsBanned( steamid )
	if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
	local read = file.Read( "bmas_bans.txt", "DATA" )
	local decoded = util.JSONToTable( read ) or {}
	if decoded[ steamid] then
		return true,decoded[ steamid ].r
	else
		return false,""
	end
end



if SERVER then
	function bmas.CheckBan( steamID, ipAddress, svPassword, sclPassword, name )
		local ban,reason = bmas.IsBanned( steamID )
		if ban then
			return false,reason
		else
			return true
		end
	end
	hook.Add("CheckPassword","BMAS_LIB_CHECKBAN",bmas.CheckBan)

	bmas.CreateCommand( "rcon", function( ply, args )
		if args[1] == nil then
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: commands expected, got shit." )
			return
		else
			RunConsoleCommand( unpack(args))
		end
	end, 1 , "<commands>" )
	
	bmas.CreateCommand( "kick", function( ply, args )	
		local t_ply = bmas.FindPlayer( args[1] )[1]
		local reason = args[2] or ""
		if IsValid( t_ply ) then
			t_ply:Kick( reason )
			if reason ~= "" then
				bmas.CommandNotify(ply," has kicked ",t_ply:Nick(),"",""," with reason ",reason)
			else
				bmas.CommandNotify(ply," has kicked ",t_ply:Nick(),"",""," without reason.")
			end
		end
	end, 2 , "<player name> [reason]" )
	bmas.CreateCommand( "ban", function( ply, args )	
		local t_ply = bmas.FindPlayer( args[1] )[1]
		local time = args[2] or 0
		local reason = table.concat( args, " ", 3)
		if IsValid( t_ply ) then
			local correct_time = 0
			if tonumber(time) ~= nil then
				correct_time = tonumber(time)
			end
			
			if correct_time ~= 0 then
				bmas.Ban( t_ply:SteamID(), tostring( os.time() + correct_time*60 ), reason)
			elseif correct_time <= 0 then
				bmas.Ban( t_ply:SteamID(), 0,  reason)
			end
			t_ply:Kick( reason )

			if tonumber(correct_time) > 0 and reason ~= "" then	// if we have time and reason then 
				bmas.CommandNotify(ply," has banned ",t_ply:Nick()," for ",tostring(correct_time)," minutes with reason ",reason)
			elseif tonumber(correct_time) > 0 and reason == "" then // if we have time but don't have reason then
				bmas.CommandNotify(ply," has banned ",t_ply:Nick()," for ",tostring(correct_time)," minutes without reason.")
			elseif tonumber(correct_time) == 0 and reason ~= "" then // if we don't have time (0) but have reason then
				bmas.CommandNotify(ply," has banned ",t_ply:Nick()," permently",""," with reason ",reason)
			elseif tonumber(correct_time) == 0 and reason == "" then // if we don't have and reason then
				bmas.CommandNotify(ply," has banned ",t_ply:Nick()," permently",""," without reason.")
			end
			
		end
	end, 2 , "<player name> [time minutes] [reason]" )	
	bmas.CreateCommand( "banid", function( ply, args )	
		local steamID = args[1]
		local time = args[2] or 0
		local reason = table.concat( args, " ", 3 )
		if !string.match( steamID, "STEAM_[0-5]:[0-9]:[0-9]+" ) then
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: SteamID expected, got shit." )
			return
		elseif bmas.IsBanned( steamID ) then
			bmas.SystemNotify( ply, bmas.colors.red, "This SteamID is already banned." )
			return
		else
			local correct_time = 0
			if tonumber(time) ~= nil then
				correct_time = tonumber(time)
			end
			for k,v in pairs(player.GetAll()) do
				if v:SteamID() == steamID then
					v:Kick( reason )
				end
			end
			if correct_time ~= 0 then
				bmas.Ban( steamID, tostring( os.time() + correct_time*60 ), reason)
			elseif correct_time <= 0 then
				bmas.Ban( steamID, 0,  reason)
			end
			
			if tonumber(correct_time) > 0 and reason ~= "" then	// if we have time and reason then
				bmas.CommandNotify(ply," has banned SteamID ",steamID," for ",tostring(correct_time)," minutes with reason ",reason)
			elseif tonumber(correct_time) > 0 and reason == "" then // if we have time but don't have reason then
				bmas.CommandNotify(ply," has banned SteamID ",steamID," for ",tostring(correct_time)," minutes without reason.")
			elseif tonumber(correct_time) == 0 and reason ~= "" then // if we don't have time (0) but have reason then
				bmas.CommandNotify(ply," has banned SteamID ",steamID," permently",""," with reason ",reason)
			elseif tonumber(correct_time) == 0 and reason == "" then // if we don't have and reason then
				bmas.CommandNotify(ply," has banned SteamID ",steamID," permently",""," without reason.")
			end
		end
	end, 2 , "<steamid> [time minutes] [reason]")	
	bmas.CreateCommand( "unban", function( ply, args )	
		local steamID = args[1]
		if !string.match( steamID, "STEAM_[0-5]:[0-9]:[0-9]+" ) then
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: SteamID expected, got shit." )
			return
		elseif not bmas.IsBanned( steamID ) then
			bmas.SystemNotify( ply, bmas.colors.red, "This SteamID is already unbanned." )
			return
		else
			bmas.UnBan( steamID )
			bmas.CommandNotify(ply," has unbanned SteamID ",steamID,"","","")
		end
	end, 1 , "<steamid>" )
	bmas.CreateCommand( "banlist", function( ply, args )
		bmas.SystemNotify( ply,bmas.colors.white, "Ban list: " )
		
		if !file.Exists( "bmas_bans.txt", "DATA" ) then return end
		local read = file.Read( "bmas_bans.txt", "DATA" )
		local decoded = util.JSONToTable( read )
		
		for k,v in pairs( decoded ) do
			bmas.SystemNotify( ply, bmas.colors.white,"STEAMID: ", bmas.colors.gray, k , bmas.colors.white," Reason: ", bmas.colors.gray, v.r )
		end
	end, 3 , "<none>" )
	bmas.CreateCommand( "crash", function( ply, args )	
		local t_ply = bmas.FindPlayer( args[1] )[1]
		if IsValid(t_ply) then
			t_ply:SendLua("while true do end")
			bmas.CommandNotify(ply," has crashed ",t_ply:Nick(),"","","")
		end
	end, 1 , "<player name>" )
	bmas.CreateCommand( "cleanup", function( ply, args )	
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
		local t_ply = bmas.FindPlayer( args[1] )[1]
		if IsValid(t_ply) then
			ply:SetPos(t_ply:GetPos()-t_ply:GetForward()*50)
			bmas.CommandNotify(ply," has teleported to ",t_ply:Nick(),"","","")
		end
	end, 1 , "<player name>" )	
	bmas.CreateCommand( "bring", function( ply, args )	
		local t_ply = bmas.FindPlayer( args[1] )[1]
		local t2_ply = bmas.FindPlayer( args[2] )[1]
		if IsValid(t_ply) then
			if IsValid(t2_ply) then
				t_ply:SetPos(t2_ply:GetPos()+t2_ply:GetForward()*50)
				bmas.CommandNotify(ply," has bring ",t_ply:Nick()," to ",t2_ply:Nick(),"")
			else
				t_ply:SetPos(ply:GetPos()+ply:GetForward()*50)
				bmas.CommandNotify(ply," has bring ",t_ply:Nick()," to ","self","")
			end
		end
	end, 1 , "<player name> [player2 name]" )	
	bmas.CreateCommand( "slay", function( ply, args )	
		local t_ply = bmas.FindPlayer( args[1] )[1]
		if IsValid(t_ply) then
			t_ply:Kill()
			bmas.CommandNotify(ply," has slayed ",t_ply:Nick(),"","","")
		end
	end, 1 , "<player name>" )	
	bmas.CreateCommand( "spawn", function( ply, args )	
		local t_ply = bmas.FindPlayer( args[1] )[1]
		if IsValid(t_ply) then
			t_ply:Spawn()
			bmas.CommandNotify(ply," has spawned ",t_ply:Nick(),"","","")
		end
	end, 1 , "<player name>" )
	local SOUND_DISCO = false
	bmas.CreateCommand( "disco", function( ply, args )
		if SOUND_DISCO then
			for k,v in pairs( player.GetAll() ) do
				v:SendLua("SOUND_DISCO:Stop()")
			end
			SOUND_DISCO = false
		else
			SOUND_DISCO = true
			for k,v in pairs( player.GetAll() ) do
			v:SendLua([[
			SOUND_DISCO = nil
			sound.PlayURL( "http://puu.sh/9Funs.mp3", "", function( sound )
			SOUND_DISCO = sound
			end)]])
			end
		end
	end, 1 , "<none>" )
	
	timer.Create("BMAS_UNBAN",5,0,function()
		if file.Exists( "bmas_bans.txt", "DATA" ) then
			local read = file.Read( "bmas_bans.txt", "DATA" )
			local decoded = util.JSONToTable( read ) or {}	
			for k,v in pairs(decoded) do
				if os.time() >= tonumber(v.t) and not v.t == 0 then
					bmas.CommandNotify(decoded[ k ]," is unbanned (Ban time is reached).","","","","")
					decoded[ k ] = nil
					local encode = util.TableToJSON(decoded)
					file.Write( "bmas_bans.txt", encode )
				end
			end
		end
	end)
	
	
	bmas.CreateCommand( "god", function( ply, args )
		local t_ply = bmas.FindPlayer( args[1] )[1]
		if t_ply then
			if not t_ply.godmode then
				t_ply:GodEnable()
				t_ply.godmode = true
				bmas.CommandNotify(ply," has enabled godmode for ",t_ply:Nick())
			else
				t_ply:GodDisable()
				t_ply.godmode = false
				bmas.CommandNotify(ply," has disabled godmode for ",t_ply:Nick())			
			end
		else
			if not ply.godmode then
				ply:GodEnable()
				ply.godmode = true
				bmas.CommandNotify(ply," has enabled godmode for ","self")
			else
				ply:GodDisable()
				ply.godmode = false
				bmas.CommandNotify(ply," has disabled godmode for ","self")			
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
end


end)