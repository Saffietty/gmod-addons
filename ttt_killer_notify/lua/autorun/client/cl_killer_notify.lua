local WeaponToIcon=function(WepClass)
	local wep=util.WeaponForClass(WepClass);
	return wep&&wep.Icon||"vgui/ttt/icon_skull";//"vgui/ttt/icon_nades";
end;

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
	Base:SetPaintShadow(false);
	Base:SetBackgroundBlur(false);
	Base:MakePopup();
	Base:SetKeyboardInputEnabled(false);
	Base:SetDeleteOnClose(true);
	Base.btnMinim:SetVisible(false);
	Base.btnMaxim:SetVisible(false);

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
	if Table.Role=="innocent" then
		Role:SetImage("vgui/ttt/icon_inno");
		Role:SetTooltip("Невиновный");
	elseif Table.Role=="traitor" then
		Role:SetImage("vgui/ttt/icon_traitor");
		Role:SetTooltip("Предатель");
	elseif Table.Role=="detective" then
		Role:SetImage("vgui/ttt/icon_det");
		Role:SetTooltip("Детектив");
	end;

	local Weapon=vgui.Create("DImageButton",Base);
	Weapon:SetPos(152,32);
	Weapon:SetSize(64,64);
	if Table.Weapon!="None"&&Table.Weapon!="World"&&Table.Weapon!="Prop"&&Table.Weapon!="weapon_zm_molotov" then
		Weapon:SetImage(WeaponToIcon(Table.Weapon));
		local wep=util.WeaponForClass(Table.Weapon);
		Weapon:SetTooltip(LANG.TryTranslation(wep.PrintName));
	elseif Table.Weapon=="World" then
		Weapon:SetImage("vgui/ttt/icon_fall");
		Weapon:SetTooltip("Сила притяжения");
	elseif Table.Weapon=="Prop" then
		Weapon:SetImage("vgui/ttt/icon_rock");
		Weapon:SetTooltip("PropKill");
	elseif Table.Weapon=="weapon_zm_molotov" then
		Weapon:SetImage("vgui/ttt/icon_fire");
		local wep=util.WeaponForClass(Table.Weapon);
		Weapon:SetTooltip(LANG.TryTranslation(wep.PrintName));
	else
		Weapon:SetImage("vgui/ttt/icon_skull");
		Weapon:SetTooltip("Неизвестно");
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
		else
			DNA:SetTooltip("Вас нашли по ДНК с трупа "..Table.DNA_Nick);
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
		else
			DNA:SetTooltip("Вас нашли по ДНК с трупа "..Table.DNA_Nick);
		end;
	end;
end;

local CVar_DM_Delay=CreateClientConVar("ttt_killer_notify_dm_delay",2);
local DM_Delay=CVar_DM_Delay:GetInt();
cvars.RemoveChangeCallback("ttt_killer_notify_dm_delay","ttt_killer_notify_dm_delay");
cvars.AddChangeCallback("ttt_killer_notify_dm_delay",function()
	DM_Delay=CVar_DM_Delay:GetInt();
end,"ttt_killer_notify_dm_delay");

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
	Base:SetPaintShadow(false);
	Base:SetBackgroundBlur(false);
	Base:SetDeleteOnClose(true);
	Base:ShowCloseButton(false);

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
	if Table.Weapon!="None"&&Table.Weapon!="World"&&Table.Weapon!="Prop"&&Table.Weapon!="weapon_zm_molotov" then
		Weapon:SetImage(WeaponToIcon(Table.Weapon));
		local wep=util.WeaponForClass(Table.Weapon);
		Weapon:SetTooltip(LANG.TryTranslation(wep.PrintName));
	elseif Table.Weapon=="World" then
		Weapon:SetImage("vgui/ttt/icon_fall");
		Weapon:SetTooltip("Сила притяжения");
	elseif Table.Weapon=="Prop" then
		Weapon:SetImage("vgui/ttt/icon_rock");
		Weapon:SetTooltip("PropKill");
	elseif Table.Weapon=="weapon_zm_molotov" then
		Weapon:SetImage("vgui/ttt/icon_fire");
		local wep=util.WeaponForClass(Table.Weapon);
		Weapon:SetTooltip(LANG.TryTranslation(wep.PrintName));
	else
		Weapon:SetImage("vgui/ttt/icon_skull");
		Weapon:SetTooltip("Неизвестно");
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

local CVar_Enable=CreateClientConVar("ttt_killer_notify_enable",1);
local Enable=CVar_Enable:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_enable","ttt_killer_notify_enable");
cvars.AddChangeCallback("ttt_killer_notify_enable",function()
	Enable=CVar_Enable:GetBool();
end,"ttt_killer_notify_enable");

local CVar_DM_Enable=CreateClientConVar("ttt_killer_notify_dm_enable",1);
local DM_Enable=CVar_DM_Enable:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_dm_enable","ttt_killer_notify_dm_enable");
cvars.AddChangeCallback("ttt_killer_notify_dm_enable",function()
	DM_Enable=CVar_DM_Enable:GetBool();
end,"ttt_killer_notify_dm_enable");

local CVar_ChatPrint=CreateClientConVar("ttt_killer_notify_chat_print",0);
local ChatPrint=CVar_ChatPrint:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_chat_print","ttt_killer_notify_chat_print");
cvars.AddChangeCallback("ttt_killer_notify_chat_print",function()
	ChatPrint=CVar_ChatPrint:GetBool();
end,"ttt_killer_notify_chat_print");

local CVar_DM_ChatPrint=CreateClientConVar("ttt_killer_notify_dm_chat_print",0);
local DM_ChatPrint=CVar_DM_ChatPrint:GetBool();
cvars.RemoveChangeCallback("ttt_killer_notify_dm_chat_print","ttt_killer_notify_dm_chat_print");
cvars.AddChangeCallback("ttt_killer_notify_dm_chat_print",function()
	DM_ChatPrint=CVar_DM_ChatPrint:GetBool();
end,"ttt_killer_notify_dm_chat_print");

local PrintInChat=function(Table)
	local headshot="";
	if Table.LastHit==1 then
		headshot=" (выстрелом в голову)";
	end;
	local wep_text="";
	if Table.Weapon!="None"&&Table.Weapon!="World"&&Table.Weapon!="Prop"&&Table.Weapon!="weapon_zm_molotov" then
		local wep=util.WeaponForClass(Table.Weapon);
		wep_text=LANG.TryTranslation(wep.PrintName);
	elseif Table.Weapon=="World" then
		wep_text="Силу притяжения";
	elseif Table.Weapon=="Prop" then
		wep_text="Проп";
	elseif Table.Weapon=="weapon_zm_molotov" then
		local wep=util.WeaponForClass(Table.Weapon);
		wep_text=LANG.TryTranslation(wep.PrintName);
	end;
	local pre_wep_text="";
	if wep_text!="" then
		pre_wep_text=", используя "
	end;
	local color_text=Color(255,255,255);
	local color_nick=Color(0,255,255);
	if SpecDM&&LocalPlayer():IsGhost() then
		chat.AddText(color_text,"Вас убил ",color_nick,Table.Nick,Color(255,255,0),headshot,color_text,pre_wep_text,Color(255,127,0),wep_text,color_text,".");
	else
		if Table.Role=="innocent" then
			color_nick=Color(25,200,25);
		elseif Table.Role=="traitor" then
			color_nick=Color(200,25,25);
		elseif Table.Role=="detective" then
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

net.Receive("KN_SendToVictim",function()
	local Table=util.JSONToTable(net.ReadString());
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

hook.Add("TTTSettingsTabs","KillerNotify",function(dtabs)
	local DScroll=vgui.Create("DScrollPanel",dtabs);
	local DForm=vgui.Create("DForm",DScroll);
	DForm:Dock(FILL);

	DForm:SetName("Настройки уведомлений после смерти");
	local Enable=DForm:CheckBox("Включено?","ttt_killer_notify_enable");
	Enable:SetTooltip("Отображать панель с информацией о смерти?");
	if SpecDM then
		local DM_Enable=DForm:CheckBox("Включено для Deathmatch?","ttt_killer_notify_dm_enable");
		DM_Enable:SetTooltip("То же, что и выше, но для Deathmatch");
	end;

	local Enable=DForm:CheckBox("Выводить информацию в чат?","ttt_killer_notify_chat_print");
	Enable:SetTooltip("Выводить информацию о смерти в чат?");
	if SpecDM then
		local DM_Enable=DForm:CheckBox("Выводить информацию в чат для Deathmatch?","ttt_killer_notify_dm_chat_print");
		DM_Enable:SetTooltip("То же, что и выше, но для Deathmatch");
	end;

	if SpecDM then
		DM_Delay=DForm:NumSlider("Время до закрытия панели в Deathmatch","ttt_killer_notify_dm_delay",1,SpecDM.RespawnTime,0);
		DM_Delay:SetTooltip("В секундах.");
	end;

	local Creator=vgui.Create("DLabelURL",DForm);
	Creator:SetText("Профиль создателя аддона в Steam");
	Creator:SetURL("https://steamcommunity.com/profiles/76561198105073033");
	DForm:AddItem(Creator);

	local Creator=vgui.Create("DLabelURL",DForm);
	Creator:SetText("Ссылка на GitHub аддона");
	Creator:SetURL("https://steamcommunity.com/profiles/76561198105073033");
	DForm:AddItem(Creator);

	DScroll:AddItem(DForm);
	dtabs:AddSheet("Killer Notify",DScroll,"icon16/tag_red.png",false,false,"Настройки для Killer Notify");
end);