

surface.CreateFont("EarthBound", {
	size = ScreenScale(12), weight = 500, font =  "Orange Kid" } )
surface.CreateFont("Dakota", { size= ScreenScale(12), weight=500,font= "Senor Saturno" } );
surface.CreateFont("TabLarge", { size= 13, weight=700,font= "Tahoma",shadow = true } );

local function EBClick()
	surface.PlaySound("mother/cursor" .. tostring(math.random(1, 2)) .. ".wav");
end

local function PaintMenu(menu)
	if (menu.Fade == "in") then
		menu.Alpha = math.Approach(menu.Alpha, 255, (FrameTime() * 2500));
	else
		menu.Alpha = math.Approach(menu.Alpha, 0, (FrameTime() * 1250));
	end
	local x, y = menu:GetPos();
	local w, h = menu:GetSize();
	local a, b = menu.Alpha, 8;
	draw.RoundedBox(b, 0, 0, w, h, Color(0, 0, 0, a));
	draw.RoundedBox(b, 3, 3, (w - 6), (h - 6), Color(255, 255, 255, a));
	draw.RoundedBox(b, 16, 16, (w - 32), (h - 32), Color(0, 0, 0, a));
end

local function PaintButton(btn)
	local menu = btn:GetParent();
	local x, y = btn:GetPos();
	local w, h = btn:GetSize();
	local a, b = menu.Alpha, 4;
	draw.RoundedBox(b, 0, 0, w, h, Color(255, 255, 255, a));
	draw.RoundedBox(b, 2, 2, (w - 4), (h - 4), Color(0, 0, 0, a));
	local txt = btn.txt;
	draw.SimpleText(txt, "Dakota", (w * .5), (h * .5), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
end

local function PaintDLV(dlv)
	local menu = dlv:GetParent();
	local x, y = dlv:GetPos();
	local w, h = dlv:GetSize();
	local a = menu.Alpha;
	if (menu.Alpha != 255) then
		a = math.Clamp((a * .05), 0, 255);
	else
		a = 255;
	end
	draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0, a));
end

local function PaintLine(line, menu)
	local x, y = line:GetPos();
	local w, h = line:GetSize();
	local a = menu.Alpha;
	if (menu.Alpha != 255) then
		a = math.Clamp((a * .05), 0, 150);
	else
		a = 150;
	end
	local clr = Color(0, 0, 0);
	if (line:IsLineSelected()) then
		clr = Color(150, 150, 255);
	end
	clr.a = a;
	draw.RoundedBox(2, 0, 0, w, h, clr);
end

local function PaintColumn(col, menu)
	local x, y = col:GetPos();
	local w, h = col:GetSize();
	local a = menu.Alpha;
	if (menu.Alpha != 255) then
		a = math.Clamp((a * .05), 0, 255);
	else
		a = 255;
	end
	draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, a));
end

local function PaintColumnHead(head, menu, txt)
	local x, y = head:GetPos();
	local w, h = head:GetSize();
	local a = menu.Alpha;
	draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, a));
	draw.RoundedBox(2, 1, 1, (w - 2), (h - 2), Color(0, 0, 0, a));
	draw.SimpleText(txt, "HudSelectionText", (w * .5), (h * .5), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
end

local function PaintGrip(grip, menu)
	local x, y = grip:GetPos();
	local w, h = grip:GetSize();
	local a = menu.Alpha;
	if (menu.Alpha != 255) then
		a = math.Clamp((a * .05), 0, 255);
	else
		a = 255;
	end
	draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, a));
	draw.RoundedBox(2, 1, 1, (w - 2), (h - 2), Color(0, 0, 0, a));
end

local function CreateSaturnMenu()
	local ent = LocalPlayer():GetNWEntity("SaturnControl");
	local sw, sh = ScrW(), ScrH();
	local menu = vgui.Create("DPanel");
	menu.lines = {};
	menu:SetPos((sw * .05), (sh * .1));
	menu:SetSize((sh * .4), (sh * .45));
	menu:SetVisible(true);
	menu.Fade = "in";
	menu.Alpha = 0;
	local x, y = menu:GetPos();
	local w, h = menu:GetSize();
	
	function menu:Paint()
		PaintMenu(self);
		local a = self.Alpha;
		draw.SimpleText("Shortcuts:", "TabLarge", (w * .5), (h * .55), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		draw.SimpleText("M1 - Coffee", "EarthBound", (w * .5), (h * .605), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		draw.SimpleText("M2 - Stop", "EarthBound", (w * .5), (h * .665), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		draw.SimpleText("Reload - Get up", "EarthBound", (w * .5), (h * .725), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
		if (self.Alpha <= 0) then
			self:SetVisible(false);
		else
			self:SetVisible(true);
		end
		return true;
	end

	
	local btn = vgui.Create("DButton", menu);
	btn:SetPos((w * .54), (h * .865));
	btn:SetSize((w * .325), (h * .075));
	btn.txt = "Exit!";
	local bx, by = btn:GetPos();
	
	function btn:Paint()
		PaintButton(self);
		return true;
	end
	
	function btn:DoClick()
		RunConsoleCommand("~MOTHER_stop_driving_saturn");
		gamemode.Call("OnContextMenuClose");
		EBClick();
	end
	

	local dlv = vgui.Create("DListView", menu);
	dlv.sched = 1;
	dlv:SetPos((w * .1), (h * .075));
	dlv:SetSize((w * .8), (h * .45));
	dlv:SetMultiSelect(false);
	
	function dlv:Paint()
		PaintDLV(self);
		return true;
	end
	
	local cdesc = dlv:AddColumn("Description");	
	local cdur = dlv:AddColumn("Duration");
	cdur:SetMinWidth(8);
	cdur:SetMaxWidth(64);
	
	function cdesc.Header:Paint()
		PaintColumnHead(self, menu, "Description");
		return true;
	end
	
	function cdur.Header:Paint()
		PaintColumnHead(self, menu, "Duration");
		return true;
	end
	
	local sched = ent.SCHED;
	for k, v in pairs(sched) do
		local dur = v.time;
		if (type(dur) == "table") then
			local a, b = tostring(dur[1]), tostring(dur[2]);
			dur = (a .. "~" .. b);
		end
		local line = dlv:AddLine(v.desc, tostring(dur));
		table.insert(menu.lines, line);

		function line:Paint()
			PaintLine(self, menu);
			return true;
		end
		
		function line:OnMousePressed()
			EBClick();
			for l, b in ipairs(menu.lines) do
				b:SetSelected(false);
			end
			self:SetSelected(true);
			menu.Sel = v.desc;
			dlv.sched = k;
		end
		
		for id,panel in pairs(line.Columns) do
			panel:SetTextColor(Color(200, 200, 200))
		end
		
	end
	
	function dlv.VBar:Paint()
		return true;
	end
	
	dlv.VBar.btnUp.txt = "";
	function dlv.VBar.btnUp:Paint()
		PaintButton(self);
		return true;
	end
	dlv.VBar.btnDown.txt = "";
	function dlv.VBar.btnDown:Paint()
		PaintButton(self);
		return true;
	end
	
	
	local btn = vgui.Create("DButton", menu);
	btn:SetPos((w * .54), (h * .775));
	btn:SetSize((w * .325), (h * .075));
	btn.txt = "Do it!";
	local bx, by = btn:GetPos();
	
	function btn:Paint()
		PaintButton(self);
		return true;
	end
	
	function btn:DoClick()
		RunConsoleCommand("~MOTHER_do_player_command", dlv.sched);
		EBClick();
	end
	
	
	local btn = vgui.Create("DButton", menu);
	btn:SetPos((w * .18), (h * .865));
	btn:SetSize((w * .325), (h * .075));
	btn.txt = "Stop!";
	local bx, by = btn:GetPos();
	
	function btn:Paint()
		PaintButton(self);
		return true;
	end
	
	function btn:DoClick()
		RunConsoleCommand("~MOTHER_end_player_command");
		EBClick();
	end
	
	
	local btn = vgui.Create("DButton", menu);
	btn:SetPos((w * .18), (h * .775));
	btn:SetSize((w * .325), (h * .075));
	btn.txt = "Get up!";
	local bx, by = btn:GetPos();
	
	function btn:Paint()
		PaintButton(self);
		return true;
	end
	
	function btn:DoClick()
		RunConsoleCommand("~MOTHER_get_up_command");
		EBClick();
	end
	
	
	return menu;
end


// Hooks

local tbl = {};
tbl[1] = "YoU wAnT CofFEe?!";
tbl[2] = "yOU WaNT CoFfEE?!";
tbl[3] = "yOu WanT COffeE?!";
tbl[4] = "YOu wANt COfFEe?!";

local function GetCoffeeMsg(um)
	chat.AddText(Color(240, 175, 145), "Mr. Saturn", Color(255, 255, 255), ": " .. tbl[math.random(1, #tbl)]);
	for i = 1, math.random(7, 10) do
		timer.Simple((i * .08), function()
			if (IsValid(LocalPlayer())) then
				surface.PlaySound("mother/saturn_text.wav");
			end
		end);
	end
end
usermessage.Hook("SaturnUWANTCOFFEE", GetCoffeeMsg);

local function OpenSaturnMenu()
	local ply = LocalPlayer();
	if (IsValid(ply:GetNWEntity("SaturnControl", nil))) then
		if (ply.SaturnMenu) then
			ply.SaturnMenu.Alpha = 1;
			ply.SaturnMenu:SetVisible(true);
			ply.SaturnMenu.Fade = "in";
			ply.SaturnMenu:MakePopup()
		else
			local menu = CreateSaturnMenu();
			ply.SaturnMenu = menu;
			ply.SaturnMenu:MakePopup()
		end
	end
end
hook.Add("OnContextMenuOpen", "MOTHEROpenSaturnMenu", OpenSaturnMenu);

local function CloseSaturnMenu()
	local ply = LocalPlayer();
	if (IsValid(ply:GetNWEntity("SaturnControl", nil))) then
		if (ply.SaturnMenu) then
			ply.SaturnMenu.Fade = "out";
		end
	end
end
hook.Add("OnContextMenuClose", "MOTHERCloseSaturnMenu", CloseSaturnMenu);
