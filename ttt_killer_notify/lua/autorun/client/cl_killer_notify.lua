
--[[
	Большинство строк данного кода написаны по-быдлятски, не стоит учиться на этом примере...
	Того же результата можно было добиться куда проще и компактнее, но мне впадлу перебирать старые строки в коде.
]]

--[[
	FUNCTIONS
]]
local WeaponToIcon=function(WepClass)
	local wep=util.WeaponForClass(WepClass);
	if wep then
		return wep["Icon"];
	end;
	return "vgui/ttt/icon_skull";
end;

local NiceWepDesc=function(bad_wep_desc)
	local img,tooltip,text;

	local wep=util.WeaponForClass(bad_wep_desc);
	if wep then
		img=WeaponToIcon(bad_wep_desc);
		tooltip=LANG.TryTranslation(wep.PrintName);
		text=tooltip;
	elseif bad_wep_desc=="Fall" then
		img="vgui/ttt/icon_fall";
		tooltip="Сила притяжения";
		text="Силу притяжения";
	elseif bad_wep_desc=="Prop" then
		img="vgui/ttt/icon_rock";
		tooltip="PropKill";
		text="Проп";
	elseif bad_wep_desc=="Barrel" then
		img="vgui/ttt/icon_splode";
		tooltip="Взрывная бочка";
		text="Взрывную бочку";
	else
		img="vgui/ttt/icon_skull";
		tooltip="Неизвестно";
		text="Неизвестное оружие";
	end;
	--Для правки текста
	if text=="Монтировка" then
		text="Монтировку";
	elseif text=="Пушка Ньютона" then
		text="Пушку Ньютона";
	end;

	return img,tooltip,text;
end;

local NumberToRole=function(number)
	local str=""
	if number==0 then
		str="невиновный";
	elseif number==1 then
		str="предатель";
	elseif number==2 then
		str="детектив";
	end;
	return str;
end;
--[[
	CONVARS
]]
local CVar_Colorized=CreateClientConVar("ttt_killer_notify_colorized_vgui","1",true,false,"",0,1);
local Colorized=CVar_Colorized:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_colorized_vgui","ttt_killer_notify_colorized_vgui");
cvars.AddChangeCallback("ttt_killer_notify_colorized_vgui",function()
	Colorized=CVar_Colorized:GetBool();
end,"ttt_killer_notify_colorized_vgui");

local CVar_Color=CreateClientConVar("ttt_killer_notify_vgui_color","0 0 0 230",true,false,"",nil,nil);
local Color_VGUI=CVar_Color:GetString();
cvars.RemoveChangeCallback("ttt_killer_notify_vgui_color","ttt_killer_notify_vgui_color");
cvars.AddChangeCallback("ttt_killer_notify_vgui_color",function()
	Color_VGUI=CVar_Color:GetString();
end,"ttt_killer_notify_vgui_color");

local CVar_Enable=CreateClientConVar("ttt_killer_notify_enable","1",true,false,"",0,1);
local Enable=CVar_Enable:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_enable","ttt_killer_notify_enable");
cvars.AddChangeCallback("ttt_killer_notify_enable",function()
	Enable=CVar_Enable:GetBool();
end,"ttt_killer_notify_enable");

local DM_Enable;
if SpecDM then
	local CVar_DM_Enable=CreateClientConVar("ttt_killer_notify_dm_enable","1",true,false,"",0,1);
	DM_Enable=CVar_DM_Enable:GetBool();
	cvars.RemoveChangeCallback("ttt_killer_notify_dm_enable","ttt_killer_notify_dm_enable");
	cvars.AddChangeCallback("ttt_killer_notify_dm_enable",function()
		DM_Enable=CVar_DM_Enable:GetBool();
	end,"ttt_killer_notify_dm_enable");
end;

local CVar_ChatPrint=CreateClientConVar("ttt_killer_notify_chat_print","0",true,false,"",0,1);
local ChatPrint=CVar_ChatPrint:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_chat_print","ttt_killer_notify_chat_print");
cvars.AddChangeCallback("ttt_killer_notify_chat_print",function()
	ChatPrint=CVar_ChatPrint:GetBool();
end,"ttt_killer_notify_chat_print");

local DM_ChatPrint;
if SpecDM then
	local CVar_DM_ChatPrint=CreateClientConVar("ttt_killer_notify_dm_chat_print","0",true,false,"",0,1);
	DM_ChatPrint=CVar_DM_ChatPrint:GetBool();
	cvars.RemoveChangeCallback("ttt_killer_notify_dm_chat_print","ttt_killer_notify_dm_chat_print");
	cvars.AddChangeCallback("ttt_killer_notify_dm_chat_print",function()
		DM_ChatPrint=CVar_DM_ChatPrint:GetBool();
	end,"ttt_killer_notify_dm_chat_print");
end;

local DM_Delay;
if SpecDM then
	local CVar_DM_Delay=CreateClientConVar("ttt_killer_notify_dm_delay",SpecDM.RespawnTime-1,true,false,"",1,SpecDM.RespawnTime);
	DM_Delay=CVar_DM_Delay:GetInt();
	cvars.RemoveChangeCallback("ttt_killer_notify_dm_delay","ttt_killer_notify_dm_delay");
	cvars.AddChangeCallback("ttt_killer_notify_dm_delay",function(_,_,value)
		DM_Delay=CVar_DM_Delay:GetInt();
	end,"ttt_killer_notify_dm_delay");
end;
--[[
	VGUI
]]
local DrawPanel=function(Table)
	local SizeX;
	local SizeY=104;

	if Table.LastHit==1&&Table.DNA==1 then
		SizeX=368;
	elseif (Table.LastHit!=1&&Table.DNA==1)||(Table.LastHit==1&&Table.DNA==0) then
		SizeX=296;
	else
		SizeX=224;
	end;

	local Base=vgui.Create("DFrame");
	Base:SetSize(SizeX,SizeY);
	Base:SetPos(ScrW()/2-SizeX/2,ScrH()/2-SizeY/2);
	Base:SetTitle("Вас убил "..Table.Nick);
	Base:SetDraggable(false);
	Base:MakePopup();
	Base:SetKeyboardInputEnabled(false);
	Base.btnMinim:SetVisible(false);
	Base.btnMaxim:SetVisible(false);
	if Colorized then
		local col=string.Explode(" ",Color_VGUI);
		Base.Paint=function(self,w,h)
			surface.SetAlphaMultiplier(col[4]/255);
			surface.SetDrawColor(col[1],col[2],col[3]);
			surface.DrawRect(0,0,w,h);
			surface.SetAlphaMultiplier(1);
		end;
	end;

	local AvatarBase=vgui.Create("DImageButton",Base);
	AvatarBase:SetPos(8,32);
	AvatarBase:SetSize(64,64);
	AvatarBase:SetImage("vgui/ttt/icon_id");
	AvatarBase:SetTooltip(Table.Nick);

	local Avatar=vgui.Create("AvatarImage",AvatarBase);
	Avatar:SetSize(32,32);
	Avatar:Center();
	Avatar:SetSteamID(Table.SteamID64,32);
	Avatar:SetMouseInputEnabled(false);

	local Role=vgui.Create("DImageButton",Base);
	Role:SetPos(80,32);
	Role:SetSize(64,64);
	if Table.Role==0 then
		Role:SetImage("vgui/ttt/icon_inno");
		Role:SetTooltip("Невиновный");
	elseif Table.Role==1 then
		Role:SetImage("vgui/ttt/icon_traitor");
		Role:SetTooltip("Предатель");
	elseif Table.Role==2 then
		Role:SetImage("vgui/ttt/icon_det");
		Role:SetTooltip("Детектив");
	end;

	local Weapon=vgui.Create("DImageButton",Base);
	Weapon:SetPos(152,32);
	Weapon:SetSize(64,64);
	local img,tooltip=NiceWepDesc(Table.Weapon);
	if img then
		Weapon:SetImage(img);
	end;
	if tooltip then
		Weapon:SetTooltip(tooltip);
	end;

	if Table.LastHit==1&&Table.DNA==1 then
		local LastHit=vgui.Create("DImageButton",Base);
		LastHit:SetPos(224,32);
		LastHit:SetSize(64,64);
		LastHit:SetImage("vgui/ttt/icon_head");
		LastHit:SetTooltip("Вы убиты выстрелом в голову");

		local DNA=vgui.Create("DImageButton",Base);
		DNA:SetPos(296,32);
		DNA:SetSize(64,64);
		DNA:SetImage("vgui/ttt/icon_wtester");
		if Table.DNA_Nick==nil then
			local wep=Table.EntClass;
			wep=util.WeaponForClass(wep);
			wep=LANG.TryTranslation(wep.PrintName);
			DNA:SetTooltip("Вас нашли по ДНК с "..wep);

			local wep_img=WeaponToIcon(Table.EntClass);
			if wep_img!="vgui/ttt/icon_skull" then
				local DNA_Wep=vgui.Create("DImageButton",DNA);
				DNA_Wep:SetSize(32,32);
				DNA_Wep:Center();
				DNA_Wep:SetImage(wep_img);
				DNA_Wep:SetMouseInputEnabled(false);
			end;
		else
			DNA:SetTooltip("Вас нашли по ДНК с трупа "..Table.DNA_Nick.." ("..NumberToRole(Table.DNA_Role)..")");

			local DNA_Avatar=vgui.Create("AvatarImage",DNA);
			DNA_Avatar:SetSize(32,32);
			DNA_Avatar:Center();
			DNA_Avatar:SetSteamID(Table.DNA_SteamID64,32);
			DNA_Avatar:SetMouseInputEnabled(false);

			local DNA_Ava_Role=vgui.Create("DImageButton",DNA_Avatar);
			DNA_Ava_Role:SetSize(16,16);
			DNA_Ava_Role:SetPos(32-16,32-16);
			if Table.DNA_Role==0 then
				DNA_Ava_Role:SetImage("vgui/ttt/icon_inno");
			elseif Table.DNA_Role==1 then
				DNA_Ava_Role:SetImage("vgui/ttt/icon_traitor");
			elseif Table.DNA_Role==2 then
				DNA_Ava_Role:SetImage("vgui/ttt/icon_det");
			end;
			DNA_Ava_Role:SetMouseInputEnabled(false);
		end;
	elseif Table.LastHit==1&&Table.DNA==0 then
		local LastHit=vgui.Create("DImageButton",Base);
		LastHit:SetPos(224,32);
		LastHit:SetSize(64,64);
		LastHit:SetImage("vgui/ttt/icon_head");
		LastHit:SetTooltip("Вы убиты выстрелом в голову");
	elseif Table.LastHit!=1&&Table.DNA==1 then
		local DNA=vgui.Create("DImageButton",Base);
		DNA:SetPos(224,32);
		DNA:SetSize(64,64);
		DNA:SetImage("vgui/ttt/icon_wtester");
		if Table.DNA_Nick==nil then
			local wep=Table.EntClass;
			wep=util.WeaponForClass(wep);
			wep=LANG.TryTranslation(wep.PrintName);
			DNA:SetTooltip("Вас нашли по ДНК с "..wep);

			local wep_img=WeaponToIcon(Table.EntClass);
			if wep_img!="vgui/ttt/icon_skull" then
				local DNA_Wep=vgui.Create("DImageButton",DNA);
				DNA_Wep:SetSize(32,32);
				DNA_Wep:Center();
				DNA_Wep:SetImage(wep_img);
				DNA_Wep:SetMouseInputEnabled(false);
			end;
		else
			DNA:SetTooltip("Вас нашли по ДНК с трупа "..Table.DNA_Nick.." ("..NumberToRole(Table.DNA_Role)..")");

			local DNA_Avatar=vgui.Create("AvatarImage",DNA);
			DNA_Avatar:SetSize(32,32);
			DNA_Avatar:Center();
			DNA_Avatar:SetSteamID(Table.DNA_SteamID64,32);
			DNA_Avatar:SetMouseInputEnabled(false);

			local DNA_Ava_Role=vgui.Create("DImageButton",DNA_Avatar);
			DNA_Ava_Role:SetSize(16,16);
			DNA_Ava_Role:SetPos(32-16,32-16);
			if Table.DNA_Role==0 then
				DNA_Ava_Role:SetImage("vgui/ttt/icon_inno");
			elseif Table.DNA_Role==1 then
				DNA_Ava_Role:SetImage("vgui/ttt/icon_traitor");
			elseif Table.DNA_Role==2 then
				DNA_Ava_Role:SetImage("vgui/ttt/icon_det");
			end;
			DNA_Ava_Role:SetMouseInputEnabled(false);
		end;
	end;
end;

local DrawPanel_DM=function(Table)
	local SizeX;
	local SizeY=104;

	if Table.LastHit==1 then
		SizeX=224;
	else
		SizeX=152;
	end;

	local Base=vgui.Create("DFrame");
	Base:SetSize(SizeX,SizeY);
	Base:SetPos(ScrW()/2-SizeX/2,ScrH()/2-SizeY/2);
	Base:SetTitle("Вас убил "..Table.Nick);
	Base:SetDraggable(false);
	Base:ShowCloseButton(false);
	if Colorized then
		local col=string.Explode(" ",Color_VGUI);
		Base.Paint=function(self,w,h)
			surface.SetAlphaMultiplier(col[4]/255);
			surface.SetDrawColor(col[1],col[2],col[3]);
			surface.DrawRect(0,0,w,h);
			surface.SetAlphaMultiplier(1);
		end;
	end;

	local AvatarBase=vgui.Create("DImageButton",Base);
	AvatarBase:SetPos(8,32);
	AvatarBase:SetSize(64,64);
	AvatarBase:SetImage("vgui/ttt/icon_id");
	AvatarBase:SetTooltip(Table.Nick);

	local Avatar=vgui.Create("AvatarImage",AvatarBase);
	Avatar:SetSize(32,32);
	Avatar:Center();
	Avatar:SetSteamID(Table.SteamID64,32);
	Avatar:SetMouseInputEnabled(false);

	local Weapon=vgui.Create("DImageButton",Base);
	Weapon:SetPos(80,32);
	Weapon:SetSize(64,64);
	local img,tooltip=NiceWepDesc(Table.Weapon);
	if img then
		Weapon:SetImage(img);
	end;
	if tooltip then
		Weapon:SetTooltip(tooltip);
	end;

	if Table.LastHit==1 then
		local LastHit=vgui.Create("DImageButton",Base);
		LastHit:SetPos(152,32);
		LastHit:SetSize(64,64);
		LastHit:SetImage("vgui/ttt/icon_head");
		LastHit:SetTooltip("Вы убиты выстрелом в голову");
	end;

	timer.Simple(DM_Delay,function()
		if Base:IsValid() then
			Base:Close();
		end;
	end);
end;
--[[
	CHAT PRINT
]]
local PrintInChat=function(Table)
	local headshot="";
	if Table.LastHit==1 then
		headshot=" (выстрелом в голову)";
	end;

	local wep_text="";
	local _,_,text=NiceWepDesc(Table.Weapon);
	wep_text=text;

	local pre_wep_text="";
	if wep_text!="" then
		pre_wep_text=", используя "
	end;

	local color_text=Color(255,255,255);
	local color_nick=Color(0,255,255);
	if SpecDM&&LocalPlayer():IsGhost() then
		chat.AddText(color_text,"Вас убил ",color_nick,Table.Nick,Color(255,255,0),headshot,color_text,pre_wep_text,Color(255,127,0),wep_text,color_text,".");
	else
		if Table.Role==0 then
			color_nick=Color(25,200,25);
		elseif Table.Role==1 then
			color_nick=Color(200,25,25);
		elseif Table.Role==2 then
			color_nick=Color(25,25,200);
		end;
		chat.AddText(color_text,"Вас убил ",color_nick,Table.Nick,Color(255,255,0),headshot,color_text,pre_wep_text,Color(255,127,0),wep_text,color_text,".");
		local DNA_text="";
		if Table.DNA==1 then
			if Table.DNA_Nick!=nil then
				DNA_text="Вас нашли по ДНК с трупа ";
				local col_rol;
				if Table.DNA_Role==0 then
					col_rol=Color(25,200,25);
				elseif Table.DNA_Role==1 then
					col_rol=Color(200,25,25);
				elseif Table.DNA_Role==2 then
					col_rol=Color(25,25,200);
				end;
				chat.AddText(color_text,"Вас нашли по ",Color(0,255,255),"ДНК",color_text," с трупа ",col_rol,Table.DNA_Nick,color_text,"!");
			else
				local wep=Table.EntClass;
				wep=util.WeaponForClass(wep);
				wep=LANG.TryTranslation(wep.PrintName);
				chat.AddText(color_text,"Вас нашли по ",Color(0,255,255),"ДНК",color_text," c ",Color(0,127,255),wep,color_text,"!");
			end;
		end;
	end;
end;
--[[
	NETWORK
]]
net.Receive("killer_notify",function()
	local Table=util.JSONToTable(net.ReadString());
	//PrintTable(Table);
	if !Enable then return end;
	if SpecDM then
		if LocalPlayer():IsGhost() then
			if DM_Enable then
				DrawPanel_DM(Table);
			end;
			if DM_ChatPrint then
				PrintInChat(Table);
			end;
		else
			if Enable then
				DrawPanel(Table);
			end;
			if ChatPrint then
				PrintInChat(Table);
			end;
		end;
	else
		if Enable then
			DrawPanel(Table);
		end;
		if ChatPrint then
			PrintInChat(Table);
		end;
	end;
end);
--[[
	MENU HOOK
]]
hook.Add("TTTSettingsTabs","killer_notify",function(dtabs)
	local DScroll=vgui.Create("DScrollPanel");
	--[[
		Настройки уведомлений о смерти
	]]
	local DForm=vgui.Create("DForm");
	DForm:Dock(TOP);
	DForm:SetName("Настройки уведомлений во время раунда");

	local Enable=DForm:CheckBox("Отображать уведомление с информацией по ценру экрана?","ttt_killer_notify_enable");

	local Enable=DForm:CheckBox("Выводить информацию в чат?","ttt_killer_notify_chat_print");

	DScroll:AddItem(DForm);
	--[[
		Настройки уведомлений в Deathmatch
	]]
	if SpecDM then
		local DForm2=vgui.Create("DForm");
		DForm2:Dock(TOP);
		DForm2:SetName("Настройки уведомлений в Deathmatch");

		local DM_Enable=DForm2:CheckBox("Отображать уведомление с информацией по ценру экрана?","ttt_killer_notify_dm_enable");

		local DM_Enable=DForm2:CheckBox("Выводить информацию в чат?","ttt_killer_notify_dm_chat_print");

		local DM_Delay=DForm2:NumSlider("Время до закрытия уведомления во время Deathmatch (в секундах)","ttt_killer_notify_dm_delay",1,SpecDM.RespawnTime,0);
		DM_Delay.Label:SetWrap(true);

		DScroll:AddItem(DForm2);
	end;
	--[[
		Стиль уведомлений
	]]
	local DForm3=vgui.Create("DForm");
	DForm3:Dock(TOP);
	DForm3:SetName("Кастомизация");

	local Enable=DForm3:CheckBox("Использовать нестандартный цвет VGUI для уведомлений?","ttt_killer_notify_colorized_vgui");

	local DButton=vgui.Create("DButton");
	DButton:SetText("Изменить цвет");
	DButton.DoClick=function()
		dtabs:GetParent():Close();

		local changed=false;
		local col=string.Explode(" ",Color_VGUI);

		local DFrame=vgui.Create("DFrame");
		DFrame:SetSize(267,186);
		DFrame:SetTitle("Образец");
		DFrame:Center();
		DFrame.btnMinim:SetVisible(false);
		DFrame.btnMaxim:SetVisible(false);
		DFrame:MakePopup();
		DFrame.Paint=function(self,w,h)
			surface.SetDrawColor(col[1],col[2],col[3],col[4]);
			surface.DrawRect(0,0,w,h);
		end;
		DFrame.OnClose=function()
			if changed then
				local str=col[1].." "..col[2].." "..col[3].." "..col[4];
				CVar_Color:SetString(str);
			end;
		end;

		local DColorMixer=vgui.Create("DColorMixer",DFrame);
		DColorMixer:Dock(FILL);
		DColorMixer:SetColor(Color(col[1],col[2],col[3],col[4]));
		DColorMixer.Think=function(self)
			if col!=self:GetColor() then
				changed=true;
				col=self:GetColor();
				col={col.r,col.g,col.b,col.a};
				DFrame.Paint=function(self,w,h)
					surface.SetDrawColor(col[1],col[2],col[3],col[4]);
					surface.DrawRect(0,0,w,h);
				end;
			end;
		end;
	end;
	DForm3:AddItem(DButton);

	DScroll:AddItem(DForm3);
	--[[
		Информация
	]]
	local DForm4=vgui.Create("DForm");
	DForm4:Dock(TOP);
	DForm4:SetName("Информация");
	--Просьба не удалять
	local Creator=vgui.Create("DLabelURL",DForm);
	Creator:Dock(TOP);
	Creator:SetText("Профиль создателя аддона в Steam");
	Creator:SetURL("https://steamcommunity.com/profiles/76561198105073033");
	DForm4:AddItem(Creator);
	--И это тоже
	local GitHub=vgui.Create("DLabelURL",DForm);
	GitHub:Dock(TOP);
	GitHub:SetText("Ссылка на аддон в GitHub");
	GitHub:SetURL("https://github.com/Saffietty/gmod-addons/tree/master/ttt_killer_notify");
	DForm4:AddItem(GitHub);

	DScroll:AddItem(DForm4);
	--
	dtabs:AddSheet("Уведомления о смерти",DScroll,"icon16/exclamation.png",false,false,"Настройки уведомлений о смерти");
end);