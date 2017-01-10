ENT.Type 			= "anim";
ENT.Base 			= "base_anim";
ENT.PrintName		= "Mr. Saturn";
ENT.Author			= "Aska";
ENT.Purpose			= "DAKOTA!";
ENT.Category		= "MOTHER";

ENT.Spawnable			= true;

ENT.AutomaticFrameAdvance = true;


MRSATURNHATTABLE = {};

MRSATURNHATTABLE.hats = {}; //HATS?! (shh it's a sekrt (no really))
MRSATURNHATTABLE.hats[1] = {mdl = "models/player/items/engineer/engineer_cowboy_hat.mdl", pos = Vector(0, -2, -5), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[2] = {mdl = "models/player/items/engineer/engineer_train_hat.mdl", pos = Vector(0, -2, -4.6), ang = Angle(0, 0, 0),body = true};
MRSATURNHATTABLE.hats[3] = {mdl = "models/player/items/engineer/mining_hat.mdl", pos = Vector(0, 0, -76), ang = Angle(0, 0, 0), body = false};
MRSATURNHATTABLE.hats[4] = {mdl = "models/player/items/all_class/all_halo.mdl", pos = Vector(0, 0, -6.5), ang = Angle(-20, 0, 0), body = true};
MRSATURNHATTABLE.hats[5] = {mdl = "models/player/items/heavy/heavy_stocking_cap.mdl", pos = Vector(0, 1.5, -3.5), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[6] = {mdl = "models/player/items/heavy/heavy_ushanka.mdl", pos = Vector(0, -2.25, -5), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[7] = {mdl = "models/player/items/medic/medic_tyrolean.mdl", pos = Vector(0, 0, -3.8), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[8] = {mdl = "models/player/items/pyro/pyro_chicken.mdl", pos = Vector(0, -3.25, -4.25), ang = Angle(15, 12, 0), body = true};
MRSATURNHATTABLE.hats[9] = {mdl = "models/player/items/demo/top_hat.mdl", pos = Vector(0, -2.125, -81), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[10] = {mdl = "models/player/items/scout/newsboy_cap.mdl", pos = Vector(0, -.5, -78), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[11] = {mdl = "models/player/items/spy/spy_hat.mdl", pos = Vector(0, 0, -80), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[12] = {mdl = "models/player/items/sniper/straw_hat.mdl", pos = Vector(0, 2.5, -82), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[13] = {mdl = "models/player/items/spy/derby_hat.mdl", pos = Vector(0, 0, -80), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[14] = {mdl = "models/player/items/soldier/soldier_pot.mdl", pos = Vector(.9, -.5, 0), ang = Angle(0, 0, 0), body = true};
MRSATURNHATTABLE.hats[15] = {mdl = "models/player/items/soldier/soldier_viking.mdl", pos = Vector(1.2, -1.25, 2), ang = Angle(0, 0, 0), body = true};


function ENT:OnRemove()
	if (SERVER) then
		local ply = self.PlayerSaturn;
		if (IsValid(ply)) then
			ply:SetParent();
			ply:Spectate(OBS_MODE_NONE);
			ply:UnSpectate();
			ply:Spawn();
			ply:StripWeapons();
			ply:SetMoveType(MOVETYPE_WALK);
			if ( IsValid(ply:GetNWEntity("SaturnControl")) ) then
				ply:SetPos(ply:GetNWEntity("SaturnControl"):GetPos());
				ply:GetNWEntity("SaturnControl"):Remove();
			end
			ply:SendLua("LocalPlayer().SaturnMenu.Fade = \"out\";");
			for k, v in pairs(ply.SaturnReturnWeps) do
				ply:Give(v);
			end
			self:Explode();
		end
		self:RemoveBalloon();
	else
		if (IsValid(self.Hat)) then
			self.Hat:Remove();
		end
	end
end
