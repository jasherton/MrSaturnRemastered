include("SCHED.lua");

local movetypes = {
	MOVETYPE_WALK,
	MOVETYPE_NOCLIP
};

local function DoSCHEDCommand(ply, cmd, args)
	if (!args[1]) then
		return;
	end
	local num = tonumber(args[1] + 1);
	local ent = ply:GetNWEntity("SaturnControl");
	if (IsValid(ent) && num != ent.PlayerSCHED) then
		ent.PlayerSCHED = num;
		ent.SCHEDTime = 0;
	end
end
concommand.Add("~MOTHER_do_player_command", DoSCHEDCommand);

local function EndSCHEDCommand(ply, cmd, args)
	local ent = ply:GetNWEntity("SaturnControl");
	if (IsValid(ent) && !ent.Walking) then
		ent.ShouldWalk = true;
		ent.SCHEDTime = 0;
	end
end
concommand.Add("~MOTHER_end_player_command", EndSCHEDCommand);

local function GetUpCommand(ply, cmd, args)
	local ent = ply:GetNWEntity("SaturnControl");
	local phys = ent:GetPhysicsObject();
		if (!phys:IsValid()) then
			return;
		end
		local vel = ent:GetVelocity():Length();
		local angvel = phys:GetAngleVelocity():Length();
		if (ent:TouchingGround() && vel <= 30 && angvel <= 200 && !ent.Fishing && !ent.Sitting) then
			ent.CanGetUp = true;
			ent:EmitSound("mother/saturn_getup.wav", 60, 100);
		end
end
concommand.Add("~MOTHER_get_up_command", GetUpCommand);

function ENT:CheckForSchedule(chk)
	local sched = self.SCHED;
	if (self.ShouldWalk) then //We should start walking
		self.ShouldWalk = false;
		return sched[1];
	end
	if (chk > #sched) then //All the others failed, just walk
		return sched[1];
	end
	sched = sched[chk];
	local rnd = math.random(1, sched.chance);
	if (rnd == 1) then //We did it!
		return sched;
	else //Check the next one
		return self:CheckForSchedule(chk + 1);
	end
end

function ENT:RandomSchedule()
	if (CurTime() <= self.SCHEDTime) then
		return;
	end
	if (IsValid(self.PlayerSaturn) && self.ShouldWalk) then //We should start walking
		self.ShouldWalk = false;
		self.PlayerSCHED = 1;
	end
	if (self.CurrentEndFunc) then
		local f, err = pcall(self.CurrentEndFunc, self);
		if (!f) then
			print("ERROR: " .. err);
			return;
		end
	end
	local sched = self:CheckForSchedule(2);
	//sched = self.SCHED[5];
	if (IsValid(self.PlayerSaturn)) then
		sched = self.SCHED[self.PlayerSCHED];
	end
	local t = sched.time;
	if (type(t) == "table") then
		t = math.Rand(t[1], t[2]);
	end
	if (sched.func) then
		local f, err = pcall(sched.func, self);
		if (!f) then
			return;
		end
		self.CurrentEndFunc = sched.endfunc;
	end
	if (!self.TimeOverride) then
		self.SCHEDTime = (CurTime() + t);
	end
	self.TimeOverride = false;
end


/*---------------------------------------
			Shadow Control
-----------------------------------------*/

function ENT:WalkSC(delta)
	local shadow = {};
	shadow.secondstoarrive = math.Rand(self.WalkTimeMin, self.WalkTimeMax);
	shadow.pos = Vector(0, 0, 0);
	shadow.angle = self.WalkAngle;	
	shadow.maxangular = 5000;
	shadow.maxangulardamp = 10000;
	shadow.maxspeed = 0;
	shadow.maxspeeddamp = 0;
	shadow.dampfactor = 1;
	shadow.teleportdistance = 0;
	shadow.deltatime = delta;
	return shadow;
end

function ENT:FishSC(delta)
	local shadow = {};
	shadow.secondstoarrive = math.Rand(.5, .9);
	shadow.pos = Vector(0, 0, 0);
	shadow.angle = Angle(-90, 0, self.FishAngle);
	shadow.maxangular = 5000;
	shadow.maxangulardamp = 10000;
	shadow.maxspeed = 0;
	shadow.maxspeeddamp = 0;
	shadow.dampfactor = 1;
	shadow.teleportdistance = 0;
	shadow.deltatime = delta;
	return shadow;
end

function ENT:FlySC(delta)
	local shadow = {};
	shadow.secondstoarrive = math.Rand(.5, .9);
	shadow.pos = Vector(0, 0, 0);
	shadow.angle = Angle(90, 0, self.FishAngle);
	shadow.maxangular = 5000;
	shadow.maxangulardamp = 10000;
	shadow.maxspeed = 0;
	shadow.maxspeeddamp = 0;
	shadow.dampfactor = 1;
	shadow.teleportdistance = 0;
	shadow.deltatime = delta;
	return shadow;
end


/*---------------------------------------
			Schedule Functions
-----------------------------------------*/

function ENT:WalkAround()
	local pos = self:GetPos();
	self.Walking = true;
	if (!IsValid(self.PlayerSaturn)) then
		self.WalkAngle = Angle(0, math.random(0, 360), 0);
		local chk = math.random(1, 2);
		if (chk == 1) then
			for k, v in ipairs(player.GetAll()) do
				local pos, pos2 = self:GetPos(), v:GetPos();
				local dist = pos:Distance(pos2);
				if (dist <= 300) then
					self.WalkAngle = (pos2 - pos):GetNormal():Angle(); //Let's hang around them a bit
				end
			end
		end
	end
end

function ENT:EndWalkAround()
	self.Walking = false;
end

function ENT:StartFish()
	self.FishAngle = math.random(0, 360);
	self.Fishing = true;
	if (!IsValid(self.balloon)) then
		self:MakeBalloon(12, 100, Vector(0, 0, 0));
	end
end

function ENT:EndFish()
	self.ShouldWalk = true; //We should walk after we're done fishing
	self.CanGetUp = true;
	self:EmitSound("mother/saturn_getup.wav", 60, 100);
	self.Fishing = false;
	self:RemoveBalloon();
end

function ENT:StartIdle()
	self.Idling = true;
end

function ENT:EndIdle()
	self.Idling = false;
end

function ENT:StartSit()
	self.FishAngle = math.random(0, 360);
	self.Sitting = true;
end

function ENT:EndSit()
	self.ShouldWalk = true;
	self.CanGetUp = true;
	self:EmitSound("mother/saturn_getup.wav", 60, 100);
	self.Sitting = false;
end

function ENT:StartFly()
	local off = self:GetForward();
	off = ((off * -1) * 12);
	self:MakeBalloon(165, 48, off);
	self.ShouldWalk = true;
	self.Flying = true;
	timer.Create(tostring(self) .. "BalloonTimer1", 1.6, 1, function()
		if (IsValid(self.balloon)) then
			self.balloon:SetForce(150);
			self.FlyCheck = true;
			timer.Create(tostring(self) .. "BalloonTimer2", 7.5, 1, function()
				if (IsValid(self.balloon)) then
					self.balloon:SetForce(159);
				end
			end);
		end
	end);
end

function ENT:EndFly()
	self.ShouldWalk = true;
	self.Flying = false;
	self.Descending = false;
	self.FlyCheck = false;
	self.WalkAngle.r = 0;
	timer.Remove(tostring(self) .. "BalloonTimer1");
	timer.Remove(tostring(self) .. "BalloonTimer2");
	self:RemoveBalloon();
end

function ENT:FindCoffeeWanterPerson() //yOU waNt cOFfeE?!
	local ply = nil;
	local chk = 0;
	for k, v in ipairs(player.GetAll()) do
		if (v:Alive() && movetypes[v:GetMoveType()] && self.PlayerSaturn != v) then
			local pos, pos2 = self:GetPos(), v:GetPos();
			local dist = pos:Distance(pos2);
			if (chk == 0) then
				chk = dist;
			end
			if (dist <= 300 && dist <= chk) then
				chk = dist;
				ply = v;
			end
		end
	end
	return ply;
end

function ENT:SpawnCoffee()	
	local pos = self:GetPos()
	local coffee = ents.Create("prop_physics");
	coffee:SetModel("models/props_junk/garbage_coffeemug001a.mdl");
	coffee:SetPos((pos + Vector(0, 0, 4)));
	coffee.SaturnCoffee = true;
	coffee:Spawn();
	constraint.NoCollide(self, coffee);
	timer.Simple(2.5, function()
		if (IsValid(coffee)) then	
			coffee:TakeDamage(1);
			coffee:Fire("break");
		end
	end);
	return coffee;
end

function ENT:StartCoffee()
	self.TimeOverride = true;
	if (IsValid(self.PlayerSaturn)) then
		self.ShouldWalk = true;
	end
	local ply = self:FindCoffeeWanterPerson();
	if (!IsValid(ply)) then
		self.SCHEDTime = 0;
		if (IsValid(self.PlayerSaturn) && self.PlyCoffee) then
			self.PlyCoffee = false;
			local vel = self:GetForward();
			local coffee = self:SpawnCoffee();
			local phys = coffee:GetPhysicsObject();
			if (phys:IsValid()) then
				phys:ApplyForceCenter(((vel * 750) + Vector(0, 0, 250)));
			end
		end
		return;
	end
	self.PlyCoffee = false;
	self.CoffeeWanter = ply; //We bRinG U sUM!
	self.SCHEDTime = (CurTime() + 1);
	local pos, pos2 = self:GetPos(), ply:GetPos();
	local ang = (pos2 - pos):Angle();
	ang.r, ang.p = 0;
	self:SetAngles(ang);
	umsg.Start("SaturnUWANTCOFFEE", ply);
	umsg.End();
	timer.Create(tostring(self) .. "SaturnThrowCoffee", 1, 1, function()
		if (!IsValid(self)) then
			return;
		end
		local ply = self.CoffeeWanter;
		if (ply == nil || !IsValid(ply) || !ply:Alive()) then
			self.SCHEDTime = 0;
			timer.Remove(tostring(self) .. "SaturnThrowCoffee");
			return;
		end
		local dist = pos:Distance(pos2);
		if (dist > 300) then
			self.SCHEDTime = 0;
			timer.Remove(tostring(self) .. "SaturnThrowCoffee");
			return;
		end
		local coffee = self:SpawnCoffee();
		local phys = coffee:GetPhysicsObject();
		if (phys:IsValid()) then
			phys:ApplyForceCenter((((pos2 - pos) + Vector(0, 0, 50)) * 4));
		end
	end);
end

function ENT:EndCoffee()
	self.ShouldWalk = true;
	self.TimeOverride = false;
	self.CoffeeWanter = nil;
	timer.Remove(tostring(self) .. "SaturnThrowCoffee");
end

