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
bmas.hostname_prefix = "Your Prefix Here - "
bmas.hostname = {
	"Your Text Here 1",
	"Your Text Here 2",
	"Your Text Here 4",
	"Your Text Here 5"
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