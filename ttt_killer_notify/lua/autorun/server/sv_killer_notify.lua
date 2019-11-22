util.AddNetworkString("KN_SendToVictim");

local DNA_Table={};
local CheckTable=function(ply)
	if #DNA_Table==0 then
		return 0;
	end;
	for _,sid in pairs(DNA_Table) do
		if ply:SteamID64()==sid[1] then
			return 1;
		end;
	end;
	return 0;
end;

local GetFromCorpse=function(ply)
	if #DNA_Table==0 then
		return "";
	end;
	for _,sid in pairs(DNA_Table) do
		if ply:SteamID64()==sid[1] then
			if sid[2]==nil&&sid[3]==nil then
				return "",0;
			elseif sid[2]!=nil&&sid[3]==nil then
				return sid[2];
			else
				return sid[2],sid[3];
			end;
		end;
	end;
	return "";
end;

hook.Add("TTTPrepareRound","KillerNotify",function()
	DNA_Table={};
end);
hook.Add("TTTFoundDNA","KillerNotify",function(ply,dna_owner,ent)
	if !IsValid(dna_owner)||ply==dna_owner||CheckTable(dna_owner)==1 then return end;
	if IsValid(ent)&&ent:GetClass()=="prop_ragdoll" then
		table.insert(DNA_Table,{dna_owner:SteamID64(),CORPSE.GetPlayerNick(ent),ent.was_role});
	else
		table.insert(DNA_Table,{dna_owner:SteamID64(),ent:GetClass()});
	end;
end);
hook.Add("DoPlayerDeath","KillerNotify",function(victim,attacker,dmginfo)
	if (IsValid(victim)&&IsValid(attacker))&&(victim:IsPlayer()&&attacker:IsPlayer())&&victim!=attacker then
		local SendTable={};
		SendTable.Nick=attacker:Nick();
		SendTable.SteamID64=attacker:SteamID64();
		SendTable.Role=attacker:GetRoleString();
		SendTable.LastHit=victim:LastHitGroup();
		local IC=dmginfo:GetInflictor():GetClass();
		if IC=="player" then
			SendTable.Weapon=attacker:GetActiveWeapon():GetClass();
		elseif IC=="weapon_zm_improvised" then
			SendTable.Weapon="weapon_zm_improvised";
		elseif IC=="weapon_ttt_knife"||IC=="ttt_knife_proj" then
			SendTable.Weapon="weapon_ttt_knife";
		elseif IC=="ttt_c4"||IC=="ttt_flame" then
			SendTable.Weapon="weapon_ttt_c4";
		elseif IC=="ttt_firegrenade_proj"||IC=="env_fire" then
			SendTable.Weapon="weapon_zm_molotov";
		elseif IC=="worldspawn" then
			SendTable.Weapon="World";
		elseif IC=="prop_physics" then
			SendTable.Weapon="Prop";
		else
			SendTable.Weapon="None";
		end;
		if attacker:HasWeapon("weapon_ttt_wtester") then
			SendTable.DNA=CheckTable(victim);
			local Check1,Check2=GetFromCorpse(victim);
			if Check2 then
				SendTable.DNA_Nick,SendTable.DNA_Role=GetFromCorpse(victim);
			else
				SendTable.EntClass=GetFromCorpse(victim);
			end;
		else
			SendTable.DNA=0;
		end;
		net.Start("KN_SendToVictim");
		net.WriteString(util.TableToJSON(SendTable));
		net.Send(victim);
		PrintTable(SendTable);
	end;
end);