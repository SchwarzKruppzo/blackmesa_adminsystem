//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Cleanup event
//===================================================================================


local commands = {}
commands[300] = {"warning _comma five minutes remaining until cleanup", "Five minutes"}
commands[240] = {"warning _comma four minutes remaining until cleanup", "Four minutes"}
commands[180] = {"warning _comma three minutes remaining until cleanup", "Three minutes"}
commands[120] = {"warning _comma two minutes remaining until cleanup", "Two minutes"}
commands[60] = {"warning _comma one minutes remaining until cleanup", "One minute"}
commands[10] = {"warning _comma ten seconds remaining until cleanup", "Ten seconds"}
commands[5] = {"five", "Five seconds"}
commands[4] = {"four", "Four seconds"}
commands[3] = {"three", "Three seconds"}
commands[2] = {"two", "Two seconds"}
commands[1] = {"one", "One second"}
 
STATUS_CLEANUP = false
 
function cleanup.GetCommands()
    return commands
end
 
function cleanup.GetStatus()
        return STATUS_CLEANUP
end
function cleanup.Abort()
    STATUS_CLEANUP = false
	timer.Destroy("CleanupTimer")
end
function cleanup.Error( strError )
        MsgC(Color(255, 100, 0), "[Cleanup Error]") MsgC(color_white, strError)
end
 
 
 
function cleanup.Start( numSeconds )
    if cleanup.GetStatus() then return cleanup.Error("Cleanup is already started") end
        local counter = numSeconds
        STATUS_CLEANUP = true
        timer.Create("CleanupTimer", 1, numSeconds, function()
                if commands[counter] then
                    bmas.AllPlayVox(commands[counter][1])
                    bmas.PrintVOX(bmas.colors.white, "Warning! ", bmas.colors.red, commands[counter][2], bmas.colors.white, " remaining until cleanup.")
				end
                counter = counter - 1
                if counter == 0 then
                        game.CleanUpMap()
                        STATUS_CLEANUP = false
                end
        end)
end