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

local voxPath = "vox/"
local function ReceivePlayVOX( data )
	local delay = 0
	local strTable = string.Explode( " ", data:ReadString() )
	for k,v in pairs( strTable ) do
		local soundFile = voxPath .. v .. ".wav"
		if k ~= 1 then
			delay = delay + SoundDuration( soundFile ) + .1
		end
		timer.Simple( delay, function()
			if !IsValid( LocalPlayer() ) then return end
			LocalPlayer():EmitSound( soundFile )
		end )
	end
end
usermessage.Hook( "PlayVOX", ReceivePlayVOX )