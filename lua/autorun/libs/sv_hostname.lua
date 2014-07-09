//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Hostname trolling
//===================================================================================

bmas.hostname = {}
bmas.hostname_prefix = "Command Center 'Gondor' - "
bmas.hostname = {
	"Samo suschestvovanie INRI delaet nas vseh lashkami.",
	"hello garry, why you are so stupid?",
	"bad argument #1: nil expected, got string",
	"PLZ UNBAN ME!11 plz plz",
	"ubi dead. demon stand by",
	"because this is 1337 variant to VAC ban a guy",
	"how to noclip",
	"what here to do?",
	"Garry's mod is in chaos.",
	"developers are pink",
	"tushenka amerikanskaya - 300 rubles",
	"I GOT HACKED BY WATCHDOGS!111!11",
	"telephone watchdogs hacking servers",
	"bitch mode enabled for tostring(ply)",
	"bad argument #228: string expected, got string",	
	"oh no!11 capster here!11 panic!11",
	"INRI zapreshen konvenciey",
	"WHAT A FUCK BOOOOOOOOOOOOOOOOOOOOOOM",
	"Fertnon can't save the gmod.",
	"he is doing addon for coderhire",
	"YOU ARE BANNED WITH REASON TEST",
	"Capster is a god.",
	"Fertnon! Help, i got hacked by INRI.",
	"do you like sandvichezzzz?",
	"FUS-ROH-DAH!!!!!!!!!PIECE OF SHIT OMG OMG",
	"warning, unauthorized biological forms detected"
}
bmas.hostname_delay = 3 // 3 seconds
bmas.hostname_enabled = true
RunConsoleCommand("hostname",bmas.hostname_prefix .. table.Random(bmas.hostname))

function bmas.HostnameChangeCheck()
	if not bmas.hostname_enabled then return end
	if !timer.Exists("BMAS_LIB_HOSTNAME") then
		timer.Create("BMAS_LIB_HOSTNAME",bmas.hostname_delay,0,function()
			RunConsoleCommand("hostname",bmas.hostname_prefix .. table.Random(bmas.hostname))
		end)
	end
end
hook.Add("Think","BMAS_LIB_HOSTNAME_T",bmas.HostnameChangeCheck)