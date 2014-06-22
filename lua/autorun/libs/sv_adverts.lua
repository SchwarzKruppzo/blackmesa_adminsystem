//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Advert system
//===================================================================================

bmas.adverts = bmas.adverts or {}
function bmas.LoadAdverts()
	if !file.Exists( "bmas_adverts.txt", "DATA" ) then
		file.Write( "bmas_adverts.txt", "[]" )
	else
		local read = file.Read( "bmas_adverts.txt", "DATA" )
		local decoded = util.JSONToTable( read ) or {}
		for k,v in pairs(decoded) do
			bmas.adverts[k] = {text = decoded[k].text,color = decoded[k].color,sec = decoded[k].sec}
		end
	end
end
bmas.LoadAdverts()

function bmas.SaveAdverts()
	if !file.Exists( "bmas_adverts.txt", "DATA" ) then
		file.Write( "bmas_adverts.txt", str )
	else
		local encode = util.TableToJSON(bmas.adverts)
		file.Write( "bmas_adverts.txt", encode )
	end
end
hook.Add("ShutDown","BMAS_LIB_ADVERTS_S",bmas.SaveAdverts)


function bmas.AdvertDestroyTimers()
	for k,v in pairs(bmas.adverts) do
		if timer.Exists("bmas.adverts["..k.."]") then
			timer.Destroy("bmas.adverts["..k.."]")
		end
	end
end
bmas.AdvertDestroyTimers()

function bmas.AdvertTimers()
	for k,v in pairs(bmas.adverts) do
		if !timer.Exists("bmas.adverts["..k.."]") then
			timer.Create("bmas.adverts["..k.."]",v.sec,0,function() bmas.Notify(v.color,v.text) end)
		end
	end
end
hook.Add("Think","BMAS_LIB_ADVERTS_T",bmas.AdvertTimers)



bmas.CreateCommand( "addadvert", function(ply,args) // >addadvert <name> <seconds> <r> <g> <b> <text>
	local name = args[1]
	local time = args[2]
	local rgb = {args[3],args[4],args[5]}
	local text = table.concat(args," ",6)
	if not name then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #1: String expected, got shit." )
		return
	elseif not time then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #2: Number expected, got shit." )
		return
	elseif not args[3] then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #3: Number expected, got shit." )
		return
	elseif not args[4] then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #4: Number expected, got shit." )
		return
	elseif not args[5] then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #5: Number expected, got shit." )
		return
	elseif not text then
		bmas.SystemNotify( ply, bmas.colors.red, "Bad argument #6: String expected, got shit." )
		return
	end
	bmas.adverts[name] = {
		text = text,
		color = Color(rgb[1],rgb[2],rgb[3]),
		sec = tonumber(time)
	}
	bmas.SaveAdverts()
	bmas.CommandNotify(ply, " has created advert ", name )
end, 1 )
bmas.CreateCommand( "removeadvert", function( ply, args )
	local name = args[1]
	if not bmas.adverts[name] then
		bmas.SystemNotify( ply, bmas.colors.red, "No such advert found." )
		return
	end
	bmas.adverts[name] = nil
	if timer.Exists("bmas.adverts["..name.."]") then
		timer.Destroy("bmas.adverts["..name.."]")
	end
	bmas.SaveAdverts()
	bmas.CommandNotify(ply, " has removed advert ", name )
end, 1 )
bmas.CreateCommand( "adverts", function( ply, args )
	bmas.SystemNotify( ply,bmas.colors.white, "Adverts: " )
	for k,v in pairs( bmas.adverts ) do
		bmas.SystemNotify( ply, bmas.colors.gray, k )
	end
end, 2 )