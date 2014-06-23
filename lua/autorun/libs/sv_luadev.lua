//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Luadev commands
//===================================================================================


bmas.CreateCommand( "l", function( ply, args )
	local code = table.concat( args, " ", 1 )
	if code ~= nil then
		luadev.RunOnServer( code, nil, ply )
		bmas.Notify( bmas.colors.self, ply:Nick(), Color(200,200,200), "@", Color(233,255,0), "Server: ", bmas.colors.white, code)
	else
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: Code expected, got shit." )
		return
	end
end, 1 , "<code>" )
bmas.CreateCommand( "ls", function( ply, args )
	local code = table.concat( args, " ", 1 )
	if code ~= nil then
		luadev.RunOnShared( code, nil, ply )
		bmas.Notify( bmas.colors.self, ply:Nick(), Color(200,200,200), "@", Color(100,120,150), "Shared: ", bmas.colors.white, code)
	else
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: Code expected, got shit." )
		return
	end
end, 1 , "<code>" )
bmas.CreateCommand( "lc", function( ply, args )
	local code = table.concat( args, " ", 1 )
	if code ~= nil then
		luadev.RunOnClients( code, nil, ply )
		bmas.Notify( bmas.colors.self, ply:Nick(), Color(200,200,200), "@", Color(100,255,150), "Clients: ", bmas.colors.white, code)
	else
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: Code expected, got shit." )
		return
	end
end, 1 , "<code>" )
bmas.CreateCommand( "lb", function( ply, args )
	local code = table.concat( args, " ", 1 )
	if code ~= nil then
		luadev.RunOnClient( code, nil, ply, ply )
		bmas.Notify( bmas.colors.self, ply:Nick(), Color(200,200,200), "@", Color(120,100,150), "Self: ", bmas.colors.white, code)
	else
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: Code expected, got shit." )
		return
	end
end, 1 , "<code>" )
bmas.CreateCommand( "lm", function( ply, args )
	local t_ply = bmas.FindPlayer( args[1] )[1]
	local code = table.concat( args, " ", 2 )
	if IsValid( t_ply ) then
		if code ~= nil then
			luadev.RunOnClient( code, nil, ply, t_ply )
			bmas.Notify( bmas.colors.self, ply:Nick(), Color(200,200,200), "@", Color(120,100,150), "Client: ", bmas.colors.white, code)
		else
			bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: Code expected, got shit." )
			return
		end
	end
end, 1 , "<player name> <code>" )