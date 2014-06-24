//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		For lulz
//			HeX is idiot
//				SkidChek for losers
//===================================================================================

bmas.cheaters = {}
bmas.cheaters["STEAM_0:0:40196066"] = "hcking ppl with vatchdagz t3l3ph0ne"
bmas.cheaters["STEAM_0:1:20360963"] = "i dont know why"
bmas.cheaters["STEAM_0:1:44889403"] = "hacking servers with e2p"
bmas.cheaters["STEAM_0:1:44629398"] = "darkrp money hack"
bmas.cheaters["STEAM_0:1:12021356"] = "hacking ulx with vatchdagz t3l3ph0ne"

local function DestroyColor(...)
        local args = {...}
        for k,v in pairs(args) do
                if type(v) == "table" and v.r then
                        table.remove(args, k)
                end
        end
        return args
end
function bmas.PrintGabe(...)
        ChatAddText(Color(100, 165, 255), "[GabeChits] ", ...)
       
        local args = DestroyColor(...)
       
        MsgC(Color(0, 165, 255), "[")
        MsgC(Color(0, 165, 200), "GabeChits")
        MsgC(Color(0, 165, 255), "] ")
        print(unpack(args))
end
function bmas.CallGabe( ply )
	if bmas.cheaters[ply:SteamID()] then
		bmas.PrintGabe(bmas.colors.gray, ply:Nick(),bmas.colors.red," <"..bmas.cheaters[ply:SteamID()],"> ",bmas.colors.white,"iz a KNAWN CHEATSER, plz call Gabe for help.")
	end
end
hook.Add("PlayerInitialSpawn","BMAS_LIB_CHEATERS_TROLL",bmas.CallGabe)
