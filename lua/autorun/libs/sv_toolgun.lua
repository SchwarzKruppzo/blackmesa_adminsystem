//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Tool restrict
//===================================================================================

bmas.toolblacklist = bmas.toolblacklist or {}
function bmas.LoadToolList()
	if !file.Exists( "bmas_toolblacklist.txt", "DATA" ) then
		luadata.WriteFile( "bmas_toolblacklist.txt", {} )
	else
		local read = luadata.ReadFile("bmas_toolblacklist.txt")
		for k,v in pairs(read) do
			bmas.toolblacklist[k] = read[k]
		end
	end
end
bmas.LoadToolList()

function bmas.SaveToolList()
	if !file.Exists( "bmas_toolblacklist.txt", "DATA" ) then
		luadata.WriteFile( "bmas_toolblacklist.txt", {} )
	else
		luadata.WriteFile( "bmas_toolblacklist.txt", bmas.toolblacklist)
	end
end

bmas.CreateCommand( "rtool", function(ply,args)
	local name = args[1]
	local access = args[2]
	
	if not name then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: String expected, got shit." )
		return
	elseif not access then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #2: String expected, got shit." )
		return
	end
	if not bmas.usergroups[access] then
		bmas.SystemNotify( ply, bmas.colors.red, "No such usergroup found." )
		return
	end
	bmas.toolblacklist[access] = bmas.toolblacklist[access] or {}
	for k,v in pairs(bmas.toolblacklist[access]) do
		if v == name then
			bmas.SystemNotify( ply, bmas.colors.red, "This tool is already restricted for this usergroup." )
			return
		end
	end
	table.insert(bmas.toolblacklist[access],name)
	
	bmas.SaveToolList()
	bmas.CommandNotify(ply, " has restricted tool ", name , " for usergroup ", access)
end, 1 , "<tool name> <usergroup>" )

bmas.CreateCommand( "unrtool", function( ply, args )
	local name = args[1]
	local access = args[2]
	
	if not bmas.toolblacklist[access] then
		bmas.SystemNotify( ply, bmas.colors.red, "No such restricted tool found." )
		return
	end
	for k,v in pairs(bmas.toolblacklist[access]) do
		if v == name then
			table.remove( bmas.toolblacklist[access], k )
			bmas.SaveToolList()
			bmas.CommandNotify(ply, " has unrestricted tool ", name , " for usergroup ", access)
			return
		end
		bmas.SystemNotify( ply, bmas.colors.red, "No such restricted tool found." )
		return 
	end
end, 1 , "<tool name> <usergroup>" )

bmas.CreateCommand( "rtools", function( ply, args )
	if table.GetFirstKey(bmas.toolblacklist) == nil then 
		bmas.SystemNotify( ply,bmas.colors.red, "No such restricted tools found. " )
		return
	else
		bmas.SystemNotify( ply,bmas.colors.white, "Restricted Tools: " )
	end
	for k,v in pairs( bmas.toolblacklist ) do
		for c,s in pairs( v ) do
			bmas.SystemNotify( ply, bmas.colors.white,"Access: ",bmas.colors.gray, k, bmas.colors.white," Tool: ",bmas.colors.gray, s)
		end
	end
end, 2 , "<none>" )

local function CanRestrictedTool(ply, trace, tool)
	local group = bmas.toolblacklist[ply:BMAS_GetAccess()]
	if group then
		for k,v in pairs(group) do
			if v == tool then
				bmas.SystemNotify( ply,bmas.colors.red, "This tool is restricted for your group." )
				return false
			end
		end	
	end
	local ent = trace.Entity
	return ply:BMAS_CheckPropAccess( ent )
end
hook.Add( "CanTool", "BMAS_LIB_TOOLS_CT2", CanRestrictedTool )

-- hooks
hook.Add("ShutDown","BMAS_LIB_TOOLS_S",bmas.SaveToolList)
