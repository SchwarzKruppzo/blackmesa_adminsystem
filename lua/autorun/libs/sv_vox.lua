//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Black Mesa Announcement System
//			for lulzs
//===================================================================================

resource.AddWorkshop("232356231")

function bmas.PlayVOX( ply, str )
	if !IsValid(ply) then return end
	umsg.Start( "PlayVOX", ply )
		umsg.String( str )
	umsg.End()
end
function bmas.AllPlayVox( str )
	for k,v in pairs(player.GetAll()) do
		bmas.PlayVOX( v, str )
	end
end


local function DestroyColor(...)
        local args = {...}
        for k,v in pairs(args) do
                if type(v) == "table" and v.r then
                        table.remove(args, k)
                end
        end
        return args
end
function bmas.PrintVOX(...)
        ChatAddText(Color(255, 165, 0), "[VOX] ", ...)
       
        local args = DestroyColor(...)
       
        MsgC(Color(255, 165, 0), "[")
        MsgC(Color(200, 165, 0), "VOX")
        MsgC(Color(255, 165, 0), "] ")
        print(bmas.unpack(args))
end


bmas.CreateCommand( "vox", function( ply, args )
	local str = table.concat( args, " ", 1)
	bmas.AllPlayVox( str )
end, 2, "<vox text>" )