//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Command system
//===================================================================================

bmas.commands = {}
bmas.commandprefixes = {">","!",".","/"}


hook.Add("BMAS_COMMAND_CheckAccess","main.cpp",function( ply, cmd )
	if bmas.commands[ cmd ] then
		if IsValid( ply ) then
			local currentAccess = bmas.usergroups[ ply:BMAS_GetAccess() ].access
			local cmdAccess = bmas.commands[ cmd ].access
			if currentAccess <= cmdAccess then
				return true,""
			else
				return false,"Access denied"
			end
		end
	end
end)
function bmas.CreateCommand( str, func, access, desc )
	bmas.commands = bmas.commands or {}
	bmas.commands[str] = { name = str, access = access or 1, func = func, desc = desc }
end
function bmas.RunCommand( ply, name, args )
	if IsValid(ply) then
		local canRun,reason = hook.Call( "BMAS_COMMAND_CheckAccess", GAMEMODE, ply, name )
		if canRun then
			bmas.commands[name].func(ply,args)
		else
			bmas.SystemNotify(ply,bmas.colors.red,reason)
		end
	end
end
function bmas.RunConCommand(ply, _, args)
	if bmas.commands[args[1]] then
		local name = args[1]
		table.remove(args, 1)
		bmas.RunCommand(ply, name, args)
	end
end
function bmas.RunCommandOnSay( ply, str )
	local prefix = string.Left(str,1)
	if table.HasValue(bmas.commandprefixes,prefix) then
		local name = string.match(str,prefix.."(.-) ") or string.match(str,prefix.."(.+)") or ""
		local args = string.match(str,prefix..".- (.+)") or ""
		name = string.lower(name) // FOR BIG CHARS MOTHAFUCKA
		local t_args = {}
		if args ~= "" then
			t_args = string.Explode(" ",args)
		end
		if bmas.commands[name] then // if command with that name is exist then we fuck it.
			bmas.RunCommand( ply, name, t_args )
		end
	end
end
if SERVER then
	hook.Add("PlayerSay","BMAS_LIB_COMMAND_PS",bmas.RunCommandOnSay)
	concommand.Add("bmas", bmas.RunConCommand)
	
	bmas.CreateCommand( "about", function( ply, args )
		bmas.SystemNotify( ply,bmas.colors.gray, "Black Mesa Administrative System" )
		bmas.SystemNotify( ply,bmas.colors.target, "	a admin mod by Schwartsune Kumiko" )
		bmas.SystemNotify( ply,bmas.colors.self, "	Copyright (C) 2014" )
	end, 2 , "<none>" )
end
