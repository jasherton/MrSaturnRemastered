AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:SpawnFunction(ply, tr)
	if (IsValid(ply:GetNWEntity("SaturnControl")) || !ply:Alive() || ply:GetNWBool("OnSaturn")) then
		return;
	end
	local pos = ply:GetShootPos();
	local ent = ents.Create("mr_saturn");
	ent:SetPos(pos);
	ent.SpawnWithHat = false;
	ent.PlayerSaturn = ply; //:O
	ent:SetOwner(ply);
	ent:Spawn();
	ply:SetParent(ent);
	local wep = {};
	for k, v in pairs(ply:GetWeapons()) do
		table.insert(wep, v:GetClass());
	end
	ply.SaturnReturnWeps = wep;
	ply:StripWeapons();
	ply:SetMoveType(MOVETYPE_OBSERVER);
	ply:Spectate(OBS_MODE_CHASE);
    ply:SpectateEntity(ent);
	ply:SetNWEntity("SaturnControl", ent);
	ply:SendLua("chat.AddText(Color(240, 175, 145), \"You're now a Mr. Saturn!  Use the context menu to access all sorts of nifty Mr. Saturn things!\")");
	
	undo.Create("Undone Controllable Mr. Saturn")
		undo.AddEntity(ent);
		undo.SetPlayer(ply);
		undo.SetCustomUndoText("Undone Controllable Mr. Saturn");
	undo.Finish()
	
end
