//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Server shutdown event
//===================================================================================

shutdown = {}

local commands = {}
commands[300] = {"warning _comma five minutes remaining until shut down", "Five minutes"}
commands[240] = {"warning _comma four minutes remaining until shut down", "Four minutes"}
commands[180] = {"warning _comma three minutes remaining until shut down", "Three minutes"}
commands[120] = {"warning _comma two minutes remaining until shut down", "Two minutes"}
commands[60] = {"warning _comma one minutes remaining until shut down", "One minute"}
commands[10] = {"warning _comma ten seconds remaining until shut down", "Ten seconds"}
commands[5] = {"five", "Five seconds"}
commands[4] = {"four", "Four seconds"}
commands[3] = {"three", "Three seconds"}
commands[2] = {"two", "Two seconds"}
commands[1] = {"one", "One second"}
 
STATUS_SHUTDOWN = false
 
function shutdown.GetCommands()
    return commands
end
 
function shutdown.GetStatus()
	return STATUS_CLEANUP
end
function shutdown.Abort()
    STATUS_CLEANUP = false
	timer.Destroy("ShutdownTimer")
end
function shutdown.Error( strError )
        MsgC(Color(255, 100, 0), "[Shutdown Error]") MsgC(color_white, strError)
end
 
 
 
function shutdown.Start( numSeconds )
    if cleanup.GetStatus() or shutdown.GetStatus() then return shutdown.Error("Another event is already started") end
        local counter = numSeconds
        STATUS_SHUTDOWN = true
        timer.Create("ShutdownTimer", 1, numSeconds, function()
                if commands[counter] then
                    bmas.AllPlayVox(commands[counter][1])
                    bmas.PrintVOX(bmas.colors.white, "Warning! ", bmas.colors.red, commands[counter][2], bmas.colors.white, " remaining until shutdown.")
				end
                counter = counter - 1
                if counter == 0 then
                        RunConsoleCommand("disconnect")
                        STATUS_SHUTDOWN = false
                end
        end)
end