//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Guard Dag by Capster
//===================================================================================

if SERVER then
	
	GuardDag = {}
	
	util.AddNetworkString( "Load Info" )
	util.AddNetworkString( "Player Info" )

	function GuardDag.PrintInfo( ply )
		
		
		local i = ply.Info
		
	--	PrintTable(i.gam)
		local games = i.gam
		
		local nocss = "[NoCSS] "
		local nohl2 = "[NoHL2] "
		local notf2 = "[NoTF2] "
		for k,v in pairs(games) do
			if v.depot == 240 then
				nocss = ""
			end
			if v.depot == 220 then
				nohl2 = ""
			end
			if v.depot == 440 then
				notf2 = ""
			end
		end
		
		local nowire = "[NoWire]"
		if i.wire then
			nowire = ""
		end
		
		ply:SetNWString("HasWire", i.wire)
		
		Msg"[GuardDag] " print(tostring(ply).." | OS: "..i.os.." | Resolution: "..i.res.." | Addons: "..i.add.." "..nowire..nocss..nohl2..notf2) 
		
	end
	
	function GuardDag.LoadInfo( ply )
		
		local tbl = {}
		
		if !ply then return end
		
		net.Start( "Load Info" )
		net.Send( ply )
		
		net.Receive( "Load Info",function( _,ply )
			
			ply.Info = net.ReadTable()
			GuardDag.PrintInfo( ply )
		--	PrintTable(ply.Info)	
		end )
		
	end
	
	hook.Add("PlayerInitialSpawn","SaveINFO",function( ply )
		
		GuardDag.LoadInfo( ply )
		
	end )
	
	--[[for k,v in pairs(player.GetAll()) do
		LoadInfo(v)	
	end]]
	
	return
end

if CLIENT then

	function CheckWire()
		local fl,fr = file.Find( "addons/*", "GAME" )
		local find,conc = string.find,table.concat

		local str = conc( fl )..conc( fr )

		return ( find( str, "wire" ) or find( str, "waer" ) ) and true or false
	end

	function UpdateInfo()
		
		local tbl = {}
		
		tbl.dx = tostring(render.GetDXLevel())
		tbl.hdr = tostring(render.SupportsHDR())
		tbl.ps14 =tostring(render.SupportsPixelShaders_1_4())
		tbl.ps20 =tostring(render.SupportsPixelShaders_2_0())
		tbl.vs20 =tostring(render.SupportsVertexShaders_2_0())
		tbl.os =tostring(jit.os)
		tbl.arch =tostring(jit.arch)
		tbl.bat = system.BatteryPower() == 255 and "Charging" or ( system.BatteryPower().."%" )
		tbl.gam = engine.GetGames()
		tbl.add = #engine.GetAddons()
		tbl.res = ScrW().."x"..ScrH()
		tbl.wire = CheckWire()
		return tbl
		
	end

	

	net.Receive("Load Info", function() 
	
		net.Start( "Load Info" )
		
			net.WriteTable( UpdateInfo() )
		
		net.SendToServer()
	
	end )
	
	return 
end	