//===================================================================================
// 		Black Mesa Administrative System
//			a 228 admin system
//
//		Copyright (C) 2014 
//			Schwartsune Kumiko
//
//		Log System
//===================================================================================

function bmas.GetLog( data )
	MsgC(Color(255, 255, 255), "[",Color(255, 200, 200), "BMAS - LOG",Color(255, 255, 255), "] ", data:ReadString() .. "\n")
end
usermessage.Hook( "BMAS_Log", bmas.GetLog );