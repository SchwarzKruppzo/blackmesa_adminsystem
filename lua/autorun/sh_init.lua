//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Shared Init
//===================================================================================

if SERVER then
	AddCSLuaFile()
end
bmas = {}
bmas.prefix = "[BMAS]"
bmas.colors = {}
bmas.colors.self = Color(110,180,225)
bmas.colors.target = Color(145,210,65)
bmas.colors.white = Color(255,255,255)
bmas.colors.green = Color(0,255,0)
bmas.colors.gray = Color(200,200,200)
bmas.colors.red = Color(255,100,100)

local function DestroyColor(...)
        local args = {...}
        for k,v in pairs(args) do
                if type(v) == "table" and v.r then
                        table.remove(args, k)
                end
        end
        return args
end

function bmas.Error(...) -- For warnings only (without stack trace)
        local args = DestroyColor(...)
 
        MsgC(Color(255, 0, 0), "[")
        MsgC(Color(200, 0, 0), "BMAS - Error")
        MsgC(Color(255, 0, 0), "] ")
        print(unpack(args))
end
 
function bmas.Print(...)
        if CLIENT then return error("Calling bmas.Print from client?") end
        local args = DestroyColor(...)
 
        MsgC(Color(100, 255, 100), "[")
        MsgC(Color(100, 200, 100), "BMAS")
        MsgC(Color(100, 200, 100), "] ")
        print(unpack(args))
end
 
function bmas.PrintServer(...)
        if CLIENT then return error("Calling bmas.PrintServer from client?") end
        local args = DestroyColor(...)
 
        MsgC(Color(100, 100, 255), "[")
        MsgC(Color(100, 100, 200), "BMAS - Server")
        MsgC(Color(100, 100, 255), "] ")
        print(unpack(args))
end
 
 
function bmas.PrintClient(...)
        if SERVER then return error("Calling bmas.PrintClient from server?") end
        local args = DestroyColor(...)
 
        MsgC(Color(255, 100, 100), "[")
        MsgC(Color(200, 100, 100), "BMAS - Client")
        MsgC(Color(255, 100, 100), "] ")
        print(unpack(args))
end

function bmas.Initialize()
	bmas.LoadLibs()
	if SERVER then
		bmas.PrintServer("Initialize finished serverside.")
	else
		bmas.PrintClient("Initialize finished clientside.")
	end
end
 
// Schwartsune Kumiko: Hey Vince!
// Vince: wut?
// Schwartsune Kumiko: Do you like sandvichez?
// Vince: nop
// Schwartsune Kumiko: DIE MOTHERFUCKER DIE!


//===================================================================================
//
//		Library system
//
//===================================================================================

local function includefile(dir,file) // fuck you garry YOU ARE A FUCKING BITCH MOTHERFUCKER YOU ARE A PIECE OF SHIT
	local prefix = string.Explode( "_" , file )[1]
	if ( CLIENT and ( prefix == "sh" or prefix == "cl" ) ) then
		include( dir )
		bmas.PrintClient("CLIENT LOADED LIB " .. dir)
	elseif ( SERVER ) then
		include( dir )
		if ( prefix == "sh" or prefix == "cl" ) then AddCSLuaFile( dir ) end
		bmas.PrintServer("SERVER LOADED LIB " .. dir)
	end
end
local LibDir = file.Find( "autorun/libs/*.lua", "LUA" )
function bmas.LoadLibs()
	for _, name in pairs( LibDir ) do
		includefile( "autorun/libs/" .. name,name)
	end
end


//===================================================================================
//
//		Notification system
//
//===================================================================================

if ( SERVER ) then
	function bmas.Notify(...)
			local args = {...}
	 
			if args[1].IsPlayer and args[1]:IsPlayer() then
					ply = args[1]
					table.remove(args, 1)
					return ply:ChatAddText(unpack(args))
			end
			bmas.Print(unpack(args))
			return ChatAddText(unpack(args))
	end

	function bmas.SystemNotify( ply,... )
		if IsValid(ply) then
			local args = {...}
			bmas.Notify(ply,bmas.colors.green,bmas.prefix,bmas.colors.white,">",unpack(args))
		else
			local args = {...}
			bmas.Print(unpack(args))
		end
	end
	function bmas.CommandNotify(ply,text,tply,text2,var1,text3,var2)
		local text2 = text2 or ""
		local var1 = var1 or ""
		local text3 = text3 or ""
		local var2 = var2 or ""
		if IsValid(ply) then
			bmas.Notify(bmas.colors.self,ply:Nick(),bmas.colors.white,text,bmas.colors.target,tply,bmas.colors.white,text2,bmas.colors.gray,var1,bmas.colors.white,text3,bmas.colors.gray,var2)
		elseif type(ply) == "string" then
			bmas.Notify(bmas.colors.self,ply,bmas.colors.white,text,bmas.colors.target,tply,bmas.colors.white,text2,bmas.colors.gray,var1,bmas.colors.white,text3,bmas.colors.gray,var2)
		else
			bmas.Notify(bmas.colors.self,"Console",bmas.colors.white,text,bmas.colors.target,tply,bmas.colors.white,text2,bmas.colors.gray,var1,bmas.colors.white,text3,bmas.colors.gray,var2)
		end
	end
end

//===================================================================================
//
//		Player search
//
//===================================================================================

function bmas.CheckName( ply, str ) // hello doctor freeman
	if ( str == "*" ) then
		return true
	elseif ( string.match( str, "STEAM_[0-5]:[0-9]:[0-9]+" ) ) then
		return ply:SteamID() == str
	elseif ( string.Left( str, 1 ) == "\"" and string.Right( str, 1 ) == "\"" ) then
		return ( ply:Nick() == string.sub( str, 2, #str - 1 ) )
	else
		return ( string.lower( ply:Nick() ) == string.lower( str ) or string.find( string.lower( ply:Nick() ), string.lower( str ), nil, true ) )
	end
end

function bmas.FindPlayer( name ) // hey freeman
	local matches = {}

	if ( !name or #name == 0 ) then
		matches[1] = def
	else
		if ( type( name ) != "table" ) then name = { name } end

		for _, ply in ipairs( player.GetAll() ) do
			for _, str in ipairs( name ) do
				if ( bmas.CheckName( ply, str ) and !table.HasValue( matches, ply ) ) then 
					table.insert( matches, ply ) 
				end
			end
		end
	end

	return matches
end
bmas.Initialize()


function bmas.PlayerInitialSpawn( ply )
	timer.Simple(2,function() 
		bmas.Notify( ply, bmas.colors.white, "Hello. The Black Mesa Announcement System welcomes you to the Black Mesa Research Facility.")
		bmas.Notify( ply, bmas.colors.white, "Remember: have a secure day!")
		ply:SendLua("LocalPlayer():EmitSound('vox/vox_login.wav')") 
	end)
end
hook.Add( "PlayerInitialSpawn", "BMAS_PIS", bmas.PlayerInitialSpawn )