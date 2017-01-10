AddCSLuaFile("autorun/sh_saturn_autorun.lua");
AddCSLuaFile("autorun/client/cl_saturn_autorun.lua");
for k, v in pairs(file.Find("models/nintendo/mother/*","GAME")) do
	resource.AddFile("models/nintendo/mother/" .. v);
end
for k, v in pairs(file.Find("materials/mother/*","GAME")) do
	resource.AddFile("materials/mother/" .. v);
end
for k, v in pairs(file.Find("materials/models/nintendo/mother/Saturn/*","GAME")) do
	resource.AddFile("materials/models/nintendo/mother/Saturn/" .. v);
end
for k, v in pairs(file.Find("sound/mother/*","GAME")) do
	resource.AddFile("sound/mother/" .. v);
end
resource.AddFile("materials/models/nintendo/flat.vmt");
resource.AddFile("materials/models/nintendo/flat.vtf");

resource.AddFile("resource/fonts/ORANGEKI.TTF");
resource.AddFile("resource/fonts/saturno.ttf");


//Hooks

local function KeyPress(ply, key)
	sat = ply:GetNWEntity("SaturnControl", nil);
	if (IsValid(sat)) then
		if (key == IN_ATTACK && sat.Walking && CurTime() >= sat.LastPlyCoffee) then //CAAAWWWWFFEEEEEEEE
			sat.LastPlyCoffee = (CurTime() + .2);
			sat.PlyCoffee = true;
			sat.PlayerSCHED = 3;
			sat.SCHEDTime = 0;
		end
		
		if (key == IN_RELOAD) then
			local phys = sat:GetPhysicsObject();
			if (!phys:IsValid()) then
				return;
			end
			local vel = sat:GetVelocity():Length();
			local angvel = phys:GetAngleVelocity():Length();
			if (sat:TouchingGround() && vel <= 30 && angvel <= 200 && !sat.Fishing && !sat.Sitting) then
				sat.CanGetUp = true;
				sat:EmitSound("mother/saturn_getup.wav", 60, 100);
			end
		end
		
		if (key == IN_ATTACK2 && !sat.Walking) then
			sat.ShouldWalk = true;
			sat.SCHEDTime = 0;
		end
	end
end
hook.Add("KeyPress", "MOTHERKeyPress", KeyPress);

local function PlayerDeath(ply)
	sat = ply.PickedUpSaturn;
	if (IsValid(sat)) then
		DropEntityIfHeld(sat);
		sat.ShouldSpaz = false;
		ply.PickedUpSaturn = nil;
		sat:SetOwner(nil);
	end
	sat = ply:GetNWEntity("SaturnControl");
	if (IsValid(sat)) then
		ply:Spectate(OBS_MODE_NONE);
		ply:UnSpectate();
		sat:Explode();
	end
end
hook.Add("PlayerDeath", "MOTHERPlayerDeath", PlayerDeath);

local function GravGunOnPickedUp(ply, ent)
	if (ent:GetClass() == "mr_saturn") then
		if (!ent.CanGrav) then
			DropEntityIfHeld(ent);
			return false; // Doesn't do anything?
		end
		ent:EmitSound("mother/saturn_pickup.wav", 80, 100);
		ent.SCHEDTime = 0;
		ent.ShouldWalk = true;
		ent.ShouldSpaz = true;
		ply.PickedUpSaturn = ent;
		return true;
	end
end
hook.Add("GravGunOnPickedUp", "MOTHERGravGunPickup", GravGunOnPickedUp);

local function GravGunOnDropped(ply, ent)
	if (ent:GetClass() == "mr_saturn") then
		if (!ent.CanGrav) then
			return false;
		end
		ent.ShouldSpaz = false;
		ent.SCHEDTime = 0;
		ent.ShouldWalk = true;
		return true;
	end
end
hook.Add("GravGunOnDropped", "MOTHERGravGunDropped", GravGunOnDropped);

local function EntityTakeDamage(ent,  dmg) // inflictor, attacker, amount,
	if (dmg:GetAttacker():GetClass() == "mr_saturn") then
		dmg:ScaleDamage(.01);
	end
	if (ent.SaturnCoffee) then
		local pos = ent:GetPos();
		local effectdata = EffectData();
		effectdata:SetStart(pos);
		effectdata:SetOrigin(pos);
		effectdata:SetScale(2);
		util.Effect("watersplash", effectdata);
	end
end
hook.Add("EntityTakeDamage", "MOTHEREntityTakeDamage", EntityTakeDamage);

local function ExitSaturn(ply, cmd, args)
	if (IsValid(ply:GetNWEntity("SaturnControl"))) then
		ply:SetParent();
		ply:Spectate(OBS_MODE_NONE);
		ply:UnSpectate();
		ply:Spawn();
		ply:StripWeapons();
		ply:SetMoveType(MOVETYPE_WALK);
		ply:SetPos(ply:GetNWEntity("SaturnControl"):GetPos());
		ply:GetNWEntity("SaturnControl"):Remove();
		for k, v in pairs(ply.SaturnReturnWeps) do
			ply:Give(v);
		end
	end
end
concommand.Add("~MOTHER_stop_driving_saturn", ExitSaturn);
