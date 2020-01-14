
util.AddNetworkString("killer_notify");

local AttackerHasVictimDNA=function(killer,victim)
	if killer:HasWeapon("weapon_ttt_wtester") then
		local wep=killer:GetWeapon("weapon_ttt_wtester");
		if wep.ItemSamples&&0<#wep.ItemSamples then
			for id=1,#wep.ItemSamples do
				if wep.ItemSamples[id]["ply"]==victim then
					local source=wep["ItemSamples"][id]["source"];
					if source&&IsValid(source) then
						if source:GetClass()=="prop_ragdoll" then 
							local role=-1;
							local steamid64=-1;
							source=source["killer_sample"]["victim"];
							if IsValid(source) then
								steamid64=source:SteamID64();
								role=source:GetRole();
								source=source:Nick();
							else
								steamid64=nil;
								role=nil;
								source=nil;
							end;
							return 1,source,role,steamid64;
						else
							return 2,source:GetClass(),nil,nil;
						end;
					end;
				end;
			end;
		end;
	end;
	return 0,nil,nil,nil;
end;

local GetNiceWeaponClass=function(dmginfo,killer)
	local SendTable={};

	if !IsValid(dmginfo:GetInflictor()) then
		return "None";
	end;

	local IC=dmginfo:GetInflictor():GetClass();--IC - класс инфликтора. Инфликтор - это обычно то, чем убивают; или то, что убивает...

	if IC=="player" then
		if dmginfo:GetDamageType()==268435464 then
			SendTable.Weapon="weapon_ttt_flaregun";
		else
			local wep=killer:GetActiveWeapon();
			if IsValid(wep) then
				SendTable.Weapon=wep:GetClass();
			else
				SendTable.Weapon="None";
			end;
		end;
	--Примеры интеграции аддонов на оружие
	elseif IC=="ttt_slam_satchel"||IC=="ttt_slam_tripmine" then
		SendTable.Weapon="weapon_ttt_slam";
	elseif IC=="ttt_fraggrenade_proj" then
		SendTable.Weapon="nc_ttt_gofrag";
	elseif IC=="weapon_ttt_tflippy_hemotoxin" then
		SendTable.Weapon="weapon_ttt_tflippy_hemotoxin";
	--
	elseif IC=="weapon_zm_improvised" then
		SendTable.Weapon="weapon_zm_improvised";
	elseif IC=="weapon_ttt_knife"||IC=="ttt_knife_proj" then
		SendTable.Weapon="weapon_ttt_knife";
	elseif IC=="ttt_c4"||IC=="ttt_flame" then
		SendTable.Weapon="weapon_ttt_c4";
	elseif IC=="ttt_firegrenade_proj"||IC=="env_fire" then
		SendTable.Weapon="weapon_zm_molotov";
	elseif IC=="worldspawn" then
		SendTable.Weapon="Fall";
	elseif IC=="prop_physics" then
		if dmginfo:GetDamageType()==134217792 then
			SendTable.Weapon="Barrel";
		else
			SendTable.Weapon="Prop";
		end;
	else
		SendTable.Weapon="None";
	end;

	return SendTable.Weapon;
end;

hook.Add("DoPlayerDeath","killer_notify",function(victim,killer,dmginfo)
	if IsValid(victim)&&(IsValid(killer)&&killer:IsPlayer())&&victim!=killer then
		--[[Debug
		for name,func in pairs(FindMetaTable("CTakeDamageInfo")) do
			if isfunction(func)&&string.StartWith(name,"Get") then
				if #name<17 then name=name.."\t" end;
				print(name,func(dmginfo));
			end;
		end;
		--]]
		local SendTable={};
		SendTable.Nick=killer:Nick();
		SendTable.SteamID64=killer:SteamID64();
		SendTable.Role=killer:GetRole();
		SendTable.LastHit=victim:LastHitGroup();
		SendTable.Weapon=GetNiceWeaponClass(dmginfo,killer);
		SendTable.DNA,SendTable.DNA_Nick,SendTable.DNA_Role,SendTable.DNA_SteamID64=AttackerHasVictimDNA(killer,victim);
		if SendTable.DNA==2 then
			SendTable.DNA=1;
			SendTable.EntClass=SendTable.DNA_Nick;
			SendTable.DNA_Nick=nil;
		end;

		//PrintTable(SendTable);

		net.Start("killer_notify");
		net.WriteString(util.TableToJSON(SendTable));
		net.Send(victim);
	end;
end);