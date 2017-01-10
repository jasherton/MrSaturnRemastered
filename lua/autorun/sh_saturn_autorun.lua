local function physgunPickup(ply, ent)
	if (IsValid(ent.Saturn)) then
		return false;
	end
	if (ent:GetClass() == "mr_saturn") then
		if (!ent.CanGrav) then
			return false;
		end
		ent.SCHEDTime = 0;
		ent.ShouldWalk = true;
		return true;
	end
	if (ent.IsSaturnHat) then
		return false;
	end
end
hook.Add("PhysgunPickup", "MOTHERPhysgunPickup", physgunPickup);

local function GravGunPunt(ply, ent)
	if (ent:GetClass() == "mr_saturn") then
		if (!ent.CanGrav) then
			return false;
		end
		ent.SCHEDTime = 0;
		ent.ShouldWalk = true;
		ent:EmitSound("mother/saturn_throw.wav", 80, 100);
		if (SERVER) then
			ent.ShouldSpaz = false;
		end
		return true;
	end
end
hook.Add("GravGunPunt", "MOTHERGravGunPunt", GravGunPunt);
