surface.CreateFont("BMAS_HostName",{font = "Trebuchet MS",size = 32,weight = 1000})
surface.CreateFont("BMAS_Group",{font = "Trebuchet MS",size = 20,weight = 1000,antialias = true})
surface.CreateFont("BMAS_Player",{font = "Trebuchet MS",size = 20,weight = 800,antialias = true})

local PANEL = {}
function PANEL:Init()
    self.Avatar = vgui.Create( "AvatarImage", self )
    self.Avatar:SetSize(24, 24)
    self.Avatar:SetMouseInputEnabled(false)
    self.Mute = vgui.Create( "DImageButton", self )
    self.Mute:SetWidth(24)
    self.Mute:SetColor(Color(180,180,180,220))
    self.Mute:Dock(RIGHT)
    self.Mute:DockMargin(2,0,2,0)
    self.Mute:SetImage("icon32/unmuted.png")
    self:SetText("")
    self.Player = nil
    self.Ping = "0"
    self.Frags = "0"
    self.Deaths = "0"
    self:SetCursor( "hand" )
end
function PANEL:DoClick( w )
    self.Player:ShowProfile() 
    GAMEMODE:ScoreboardHide()
end
function PANEL:SetPlayer( ply )
    self.Player = ply
    self.Avatar:SetPlayer(ply)
    self.Mute.DoClick = function()
        if IsValid(ply) and ply != LocalPlayer() then
            ply:SetMuted(not ply:IsMuted())
        end
    end
end
function PANEL:Paint( w, h )
    if not IsValid(self.Player) then return end
    
    local kolor = self.entered and 220 or 255
    draw.RoundedBox( 0, 0, 0, w, h, Color(kolor,kolor,kolor,255) )
    
    surface.SetFont("BMAS_Player")
    local fw, fh = surface.GetTextSize( self.Player:Name() )
    local c = (24 / 2) - (fh / 2)
    draw.SimpleTextOutlined( self.Player:Name(), "BMAS_Player", 24 + 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    
    local ping = string.sub( self.Ping, 1, 5)
    local frags = string.sub( self.Frags, 1, 10)
    local deaths = string.sub( self.Deaths, 1, 10)
    
    local fw, fh = surface.GetTextSize( "0" )
    local c = (24 / 2) - (fh / 2)
    draw.SimpleTextOutlined(ping,"BMAS_Player", w * 0.88, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    draw.SimpleTextOutlined(frags,"BMAS_Player", w * 0.45, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
    draw.SimpleTextOutlined(deaths,"BMAS_Player", w * 0.6, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))

end
function PANEL:Think()
    if not IsValid(self.Player) then return end
    
    self.Ping = tostring( self.Player:Ping() )
    self.Frags = tostring( self.Player:Frags() )
    self.Deaths = tostring( self.Player:Deaths() ) 
    if self.Player != LocalPlayer() then
        local muted = self.Player:IsMuted()
        self.Mute:SetImage(muted and "icon32/muted.png" or "icon32/unmuted.png")
    else
        self.Mute:Hide()
    end 
end
function PANEL:OnCursorEntered()
    self.entered = true
end
function PANEL:OnCursorExited()
    self.entered = false
end
function PANEL:PerformLayout()
   self:SetSize(self:GetWide(),24 )
end
function PANEL:ApplySchemeSettings()
end
vgui.Register( "BMAS_Player", PANEL, "Button" )

PANEL = {}
function PANEL:Init()
    self.Name = "Test"
    self.Color = Color(0,0,0,255)
    self.Players = {}
end
function PANEL:SetInfo( name, color, group )
    self.Name = name
    self.Color = color
    self.group = group
end
function PANEL:AddPlayer( ply )
    if ply:BMAS_GetAccess() == self.group and not self.Players[ply] then
        local plypanel = vgui.Create("BMAS_Player", self)
        plypanel:SetPlayer( ply )
        self.Players[ply] = plypanel
        self:PerformLayout()
    end
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, 28, self.Color )
    
    surface.SetFont("BMAS_Group")
    local fw, fh = surface.GetTextSize( self.Name )
    local c = (28 / 2) - (fh / 2)
    draw.SimpleTextOutlined(self.Name, "BMAS_Group", 5, c, Color( 70, 70, 70, 255 ), 0, 0, 0, Color(0,0,0))
   
end
function PANEL:Think()
    for k,v in pairs(self.Players) do
        if !IsValid( v.Player ) then
            local pnl = self.Players[k]
            if ValidPanel(pnl) then
                v:Remove()
            end
            self.Players[k] = nil
        end
    end
    
    self:InvalidateLayout()
end
function PANEL:PerformLayout()
    if table.Count(self.Players) < 1 then
        self:SetVisible( false )
        return
    end
    local y = 28
    for k, v in pairs(self.Players) do
        v:SetPos(32, y)
        v:SetSize(self:GetWide() - 32, v:GetTall())

        y = y + v:GetTall()-- + 1
    end
    self:SetSize(self:GetWide(), 28 + (y - 28))
end

vgui.Register( "BMAS_Access", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
   self.pnlCanvas  = vgui.Create( "Panel", self )
   self.YOffset = 0

   self.scroll = vgui.Create("DVScrollBar", self)
   self.scroll.Paint = function( s, w, h )
      surface.SetDrawColor( bfscoreboard.rowBGColor )
      surface.DrawRect( 0, 0, w, h )
   end
   self.scroll.btnUp.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
   self.scroll.btnDown.Paint = function( s, w, h ) 
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
   self.scroll.btnGrip.Paint = function( s, w, h )
      surface.SetDrawColor( Color(17, 24, 30) )
      surface.DrawRect( 0, 0, w-1, h )
      surface.SetDrawColor( Color(207, 203, 200) )
      surface.DrawRect( 1, 1, w-3, h-2 )
   end
end

function PANEL:GetCanvas() return self.pnlCanvas end

function PANEL:OnMouseWheeled( dlta )
   self.scroll:AddScroll(dlta * -2)

   self:InvalidateLayout()
end

function PANEL:SetScroll(st)
   self.scroll:SetEnabled(st)
end

function PANEL:PerformLayout()
   self.pnlCanvas:SetVisible(self:IsVisible())

   -- scrollbar
   scrollOnBarSize = 16
   self.scroll:SetPos(self:GetWide() - 16, 0)
   self.scroll:SetSize(scrollOnBarSize, self:GetTall())

   scrollOnFlag = self.scroll.Enabled
   self.scroll:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
   self.scroll:SetEnabled(scrollOnFlag) -- setup mangles enabled state

   self.YOffset = self.scroll:GetOffset()

   self.pnlCanvas:SetPos( 0, self.YOffset )
   self.pnlCanvas:SetSize( self:GetWide() - (self.scroll.Enabled and 16 or 0), self.pnlCanvas:GetTall() )
end
vgui.Register( "BMAS_Frame", PANEL, "Panel" )

PANEL = {}
function PANEL:Init()
    self.HostName = vgui.Create("DLabel",self)
    self.HostName:SetText( GetHostName() )
    self.HostName:SetColor(Color(255,255,255))
    self.HostName:Dock(TOP)
    self.HostName:DockMargin(30,5,30,0)
    
    self.Main = vgui.Create( "BMAS_Frame",self )
    self.groups = {}
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, Color(150,150,150,100) )
    draw.RoundedBox( 0, 5, 5, w - 10, 64, Color(80,80,80,140) )
    draw.RoundedBox( 0, 5, 64 + 15, w - 10, h - 84, Color(80,80,80,140) )
end
function PANEL:PerformLayout()
    local u = 0
    for k,v in pairs(self.groups) do
        if ValidPanel( v ) then
            if table.Count(v.Players) > 0 then
               v:SetVisible(true)
               v:InvalidateLayout()
               u = u + v:GetTall() + 5
            else
               v:SetVisible(false)
            end
        end
    end
    local w = math.max(ScrW() * 0.5, 640)
    local h = ScrH() * 0.8
    self:SetSize(w,64 + 15 + 5 + self.Main:GetCanvas():GetTall())
    self:SetPos( (ScrW() - w) / 2, (ScrH() - self.Main:GetCanvas():GetTall()) / 2 )
    
    self.HostName:SetSize( self:GetWide(), 64 )
    self.Main:GetCanvas():SetSize(self.Main:GetCanvas():GetWide(), u)
    self.Main:SetPos( 5, 64 + 15 )
    self.Main:SetSize( self:GetWide() - 10, math.Clamp(self.Main:GetCanvas():GetTall(),0,h) )
end
function PANEL:Think()
    for k, p in pairs(player.GetAll()) do
        if p:Team() == TEAM_CONNECTING then continue end
        local gr = "user"
        if bmas.usergroups[p:BMAS_GetAccess()] then
            gr = p:BMAS_GetAccess()
        end
        if !IsValid(self.groups[gr]) then
            local group = vgui.Create( "BMAS_Access", self.Main:GetCanvas() )
            group:Dock( TOP )
            group:SetInfo( bmas.usergroups[gr].name, bmas.usergroups[gr].color, gr) 
            self.groups[gr] = group
            
            self:PerformLayout() 
        else
            if self.groups[gr].Players[p] == nil then
                self.groups[gr]:AddPlayer( p )
                self:PerformLayout() 
            end
        end
    end    
end
function PANEL:ApplySchemeSettings()
    self.HostName:SetFont( "BMAS_HostName" )
end
vgui.Register( "BMASScoreboard", PANEL, "Panel" )

local function ScoreboardRemove()
   if sboard_panel then
      sboard_panel:Remove()
      sboard_panel = nil
   end
end
ScoreboardRemove()

function GM:ScoreboardCreate()
   sboard = vgui.Create("BMASScoreboard")
end

function GM:ScoreboardShow()
   self.ShowScoreboard = true

   if not sboard_panel then
      self:ScoreboardCreate()
   end

   gui.EnableScreenClicker(true)

   sboard:SetVisible(true)
end

function GM:ScoreboardHide()
   self.ShowScoreboard = false

   gui.EnableScreenClicker(false)

   if sboard then
      sboard:SetVisible(false)
   end
end

function GM:GetScoreboardPanel()
   return sboard
end