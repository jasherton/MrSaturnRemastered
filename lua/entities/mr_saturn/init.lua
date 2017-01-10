AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
AddCSLuaFile("SCHED.lua");
include("shared.lua");
include("schedules.lua");

resource.AddFile("materials/VGUI/entities/mr_saturn.vmt");
resource.AddFile("materials/VGUI/entities/mr_saturn.vtf");

function ENT:Initialize()
	self:SetModel("models/nintendo/Mother/saturn.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetColor(color_white);
	construct.SetPhysProp(nil, self, 0, nil, {GravityToggle = true, Material = "ice"});
	self.ShootNoise = 0;
	self.Walking = false;
	self.WalkAngle = Angle(0, 0, 0);
	self.LastStep = 0;
	self.CanGrav = true;
	self.CurrentEndFunc = nil;
	self.WallCheck = 0;
	self.ShouldWalk = true; //We just spawned, we should start out walking
	self.WalkTimeMin = .5;
	self.WalkTimeMax = .9;
	self:SetupSchedules();
	
	if (!self.SpawnWithHat) then
		local txt = "Mr. Saturn";
		local rnd = math.random(1, 12); //Mr. Saturn gets a hat almost as often as TF2 players do (hurf durf never)
		if (rnd == 1) then
			local rndhat = math.random(1, #MRSATURNHATTABLE.hats); //So many choices!
			self:SetHat(rndhat);
			txt = "Hatted Mr. Saturn";
			local snd = "win";
			if (IsValid(self.SatSpawningPlayer)) then
				if (self.SatSpawningPlayer.LastSaturnWasHat) then
					snd = "superwin"; //Never gonna happen  :V
				end
				self.SatSpawningPlayer.LastSaturnWasHat = true;
			end
			self:EmitSound("mother/saturn_" .. snd .. ".wav");
		else
			if (IsValid(self.SatSpawningPlayer)) then
				self.SatSpawningPlayer.LastSaturnWasHat = false;
			end
		end
		
		undo.Create(txt)
			undo.AddEntity(self);
			undo.SetPlayer(self.SatSpawningPlayer);
			undo.SetCustomUndoText("Undone " .. txt);
		undo.Finish()
	end
	
	local phys = self:GetPhysicsObject();
	if (phys:IsValid()) then
		phys:Wake();
	end
	self:StartMotionController();
	
end

function ENT:SetHat(num, skin)
	if (num < 0 || num > #MRSATURNHATTABLE.hats) then
		print("INVALID SATURN HAT! : " .. tostring(num));
		return;
	end
	
	skin = (skin || 1);
	
	if (MRSATURNHATTABLE.hats[num].body) then
		self:SetBodygroup(1, 1);
	end
	
	timer.Simple(.1, function()
		umsg.Start("SaturnHat")
			umsg.Entity(self);
			umsg.Long(num);
			umsg.Long(skin);
		umsg.End()
	end);
end

function ENT:FeetPlanted()
	local tr = {};
	tr.start = self:GetPos();
	tr.endpos = (self:GetPos() + ((self:GetUp() * -1) * 16));
	tr.filter = self;
	local trace = util.TraceLine(tr);
	if (trace.Hit && trace.Entity && !trace.Entity:IsPlayer() && !trace.Entity:IsNPC()) then
		return true;
	else
		return false;
	end
end

function ENT:TouchingGround()
	if (self:FeetPlanted()) then
		return false;
	end
	local tr = {};
	tr.start = self:GetPos();
	tr.endpos = (self:GetPos() + Vector(0, 0, -16));
	tr.filter = self;
	local trace = util.TraceLine(tr);
	if (trace.Hit && trace.Entity && !trace.Entity:IsPlayer() && !trace.Entity:IsNPC()) then
		return true;
	else
		return false;
	end
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then
		return;
	end
	local pos = tr.HitPos;
	pos = (pos + (tr.HitNormal * 16));
	local ent = ents.Create("mr_saturn");
	ent:SetPos(pos);
	ent.SatSpawningPlayer = ply;
	ent.SpawnWithHat = false;
	ent:Spawn();
end

function ENT:PhysicsCollide(data, phys)
	if (data.Speed >= 65) then
		if (data.Speed <= 400 && data.DeltaTime > 0.2) then
			self:EmitSound("mother/saturn_collide.wav");
		end
		if (data.Speed > 400) then
			if (data.DeltaTime > 0.2) then
				self:EmitSound("mother/saturn_hit.wav", 80, math.random(80, 120));
			end
			self:StopMotionController();
			construct.SetPhysProp(nil, self, 0, nil, {GravityToggle = true, Material = "metal_bouncy"});
			
			//garry's sent_ball bounce
			local oldvel = data.OurOldVelocity:Length();
			local newvel = phys:GetVelocity();
			newvel:Normalize();
			local vel = ((newvel * oldvel) * 0.75);
			phys:SetVelocity(vel);
		else
			self:StartMotionController();
		end
	end
	if (self.Descending) then
		self.SCHEDTime = 0;
	end
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg);
	self.Walking = false;
	self.SCHEDTime = 0;
	self.ShouldWalk = true;
	if (dmg:IsExplosionDamage()) then
		local rnd = math.random(1, 10);
		if (rnd == 1) then
			local ef = EffectData()
			local pos = (self:GetPos() + Vector(0, 0, 25));
			ef:SetStart(Vector(255, 200, 175));
			ef:SetOrigin(pos);
			ef:SetScale(1);
			util.Effect("balloon_pop", ef);
			util.Effect("balloon_pop", ef);
			util.Effect("balloon_pop", ef);
			ef:SetStart(Vector(255, 0, 0));
			util.Effect("balloon_pop", ef);
			self:EmitSound("mother/saturn_hit.wav", 80, math.random(35, 60));
			self:Remove();
		end
	end
	if (!dmg:IsBulletDamage()) then
		self:EmitSound("mother/saturn_hit.wav", 80, math.random(80, 120));
	else
		if (CurTime() >= self.ShootNoise) then
			self.ShootNoise = (CurTime() + .4);
			self:EmitSound("mother/saturn_hit.wav", 80, math.random(80, 120));
		end
	end
end

function ENT:MakeBalloon(force, length, offset)
	local balloon = ents.Create("gmod_balloon");
	if (!balloon:IsValid()) then
		return;
	end
	
	balloon:SetModel("models/MaxOfS2D/balloon_classic.mdl");
	balloon:SetPos(self:GetPos() + Vector(0, 0, length));
	balloon:Spawn();
	balloon:SetRenderMode(RENDERMODE_TRANSALPHA);
	balloon:SetColor(Color(250, 0, 100, 255));
	balloon:SetForce(force);
	
	local ent1, ent2 = self, balloon;
	
	local bone = self:LookupBone("nose1");
	local bpos, bang = self:GetBonePosition(bone);
	local bone1, bone2 = 0, 0;
	
	bpos = (bpos + offset);
	
	local pos1, pos2 = bpos, balloon:GetPos();
	pos1 = self:WorldToLocal(pos1);
	pos2 = balloon:WorldToLocal((pos2 + Vector(0, 0, 0)));
	
	local length = length;
	
	local forcelimit, width, material, rigid = 0, .1, "cable/cable2", false;
	
	constraint.Rope(ent1, ent2, bone1, bone2, pos1, pos2, length, 0, forcelimit, width, material, rigid);
	
	self.balloon = balloon;
end

function ENT:RemoveBalloon()
	if (IsValid(self.balloon)) then
		self.balloon:TakeDamage(1); // *pop*
		self.balloon = nil;
	end
end

function ENT:GetUpSC()
	local shadow = {};
	shadow.secondstoarrive = math.Rand(.2, .4);
	shadow.pos = self:GetPos();
	shadow.angle = self:GetAngles();
	shadow.angle.p = 0;
	shadow.angle.r = 0;
	shadow.maxangular = 5000;
	shadow.maxangulardamp = 10000;
	shadow.maxspeed = 0;
	shadow.maxspeeddamp = 0;
	shadow.dampfactor = 1;
	shadow.teleportdistance = 0;
	shadow.deltatime = delta;
	return shadow;
end

function ENT:DoAnimations()
	local anim = "idle";
	if (self.Idling || (IsValid(self.PlayerSaturn) && self.Walking)) then
		anim = "idle2";
	end
	if (self.Turning) then
		anim = "walk";
		self:SetPlaybackRate(.8);
	end
	if (self.ShouldSpaz) then //We're being held...
		anim = "walk"; //walking takes priority
		self:SetPlaybackRate(5);
	end
	local vel = self:GetVelocity():Length();
	if (self:FeetPlanted() && vel >= 15) then
		local chk = (vel * .02);
		chk = math.Clamp(chk, .025, 4);
		anim = "walk";
		self:SetPlaybackRate(chk);
	end
	anim = self:LookupSequence(anim);
	self:ResetSequence(anim);
end

function ENT:ResetGetUp()
	self.ShouldGetUp = false;
	self.CanGetUp = false;
	timer.Destroy(tostring(self) .. "GetUpTimer");
end

function ENT:Think()
	if (self:WaterLevel() >= 1) then //We are in water
		construct.SetPhysProp(nil, self, 0, nil, {GravityToggle = true, Material = "rubber"});
		local anim = self:LookupSequence("walk");
		self:SetPlaybackRate(5);
		self:ResetSequence(anim);
		self:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, 100));
		self:NextThink(CurTime());
		return true;
	end

	if ((self.Fishing || self.Flying) && !IsValid(self.balloon)) then
		self.balloon = nil;
		self.ShouldWalk = true;
		self.SCHEDTime = 0;
	end
	
	self:DoAnimations();
	
	local phys = self:GetPhysicsObject();
	if (!phys:IsValid()) then
		return;
	end
	
	//schedule stuff
	local vel = self:GetVelocity():Length();
	local angvel = phys:GetAngleVelocity():Length();
	local pos, fwd = self:GetPos(), self:GetForward();
	
	local timeleft = (self.SCHEDTime - CurTime());
	
	if (self.Flying && IsValid(self.balloon)) then
		if (timeleft <= 8) then
			self.Descending = true; //going down!
		end
		if (self.FlyCheck && self:TouchingGround()) then
			self.SCHEDTime = 0;
			self.CanGetUp = true;
		end
		local num = 30;
		local vel = Vector(0, 0, 0);
		local fwd = self:GetUp();
		local right = self:GetRight();
		local back, left = (fwd * -1), (right * -1);
		if (IsValid(self.PlayerSaturn)) then
			local ply = self:GetOwner();
			if (ply:KeyDown(IN_FORWARD)) then
				vel = (vel + fwd);
			end
			if (ply:KeyDown(IN_BACK)) then
				vel = (vel + back);
			end
			if (ply:KeyDown(IN_MOVERIGHT)) then
				vel = (vel + right);
			end
			if (ply:KeyDown(IN_MOVELEFT)) then
				vel = (vel + left);
			end
		else
			vel = fwd;
			num = 2;
		end
		local phys = self.balloon:GetPhysicsObject();
		if (phys:IsValid()) then
			vel.z = 0;
			phys:ApplyForceCenter((vel * num));
		end
	end
	
	if (self.Descending && IsValid(self.balloon)) then
		self.balloon:SetForce(122);
	end
	
	local u = phys:GetAngles():Up()
	if (u.z > .9) then
	
		if (self.Walking) then
			local num = 100;
			if (IsValid(self.PlayerSaturn)) then
				local ply = self:GetOwner();
				local ang = phys:GetAngles();
				local angturn = 15;
				if (ply:KeyDown(IN_FORWARD)) then
					if (ply:KeyDown(IN_SPEED)) then
						num = 180;
						angturn = 20;
					end
				else
					num = 0;
				end
				if (ply:KeyDown(IN_BACK)) then
					num = -100;
				end
				if (ply:KeyDown(IN_MOVERIGHT)) then
					self.WalkAngle = Angle(0, (ang.y -angturn), 0);
					self.Turning = true;
				end
				if (ply:KeyDown(IN_MOVELEFT)) then
					self.WalkAngle = Angle(0, (ang.y + angturn), 0);
					self.Turning = true;
				end
				if (!ply:KeyDown(IN_MOVELEFT) && !ply:KeyDown(IN_MOVERIGHT) || (ply:KeyDown(IN_FORWARD) || ply:KeyDown(IN_BACK))) then
					self.Turning = false;
				end
			end
			local vel = (fwd * num);
			if (self:IsOnFire()) then
				vel = (vel * 2.5); //GO NUTS!!!!1
			end
			phys:ApplyForceCenter(vel);
		end
		
		self:ResetGetUp();
		
		local pos, fwd = self:GetPos(), self:GetForward();

		//Hop check
		local tr = util.QuickTrace((pos + Vector(0, 0, -7)), (fwd * 16), self);
		local chk = ((pos + Vector(0, 0, 16)) + (fwd * 16));
		chk = util.PointContents(chk);
		if (tr.HitWorld) then
			if (chk != CONTENTS_SOLID) then
				phys:ApplyForceCenter(Vector(0, 0, 300));
				timer.Simple(.25, function()
					if (IsValid(self)) then
						phys:ApplyForceCenter((fwd * 100));
					end
				end);
			end
		end
		
		//Turn Check
		local tr = util.QuickTrace((pos + Vector(0, 0, -7)), (fwd * 128), self);
		local chk = ((pos + Vector(0, 0, 16)) + (fwd * 128));
		chk = util.PointContents(chk);
		if (tr.HitWorld && chk == CONTENTS_SOLID && !IsValid(self.PlayerSaturn)) then //You're walking into a wall man...
			if (CurTime() >= self.WallCheck) then
				self.WallCheck = (CurTime() + 1);
				self.WalkTimeMin = .1;
				self.WalkTimeMax = .1;
				self.WalkAngle.y = (self.WalkAngle.y + 180); //away from the wall, son
			end
		else
			local mn, mx = .5, .9;
			if (IsValid(self.PlayerSaturn)) then
				mn, mx = .1, .3;
			end
			self.WalkTimeMin = mn;
			self.WalkTimeMax = mx;
		end
		
	else //We're knocked over
		local vel = self:GetVelocity():Length();
		local angvel = phys:GetAngleVelocity():Length();
		if (self:TouchingGround() && !self.ShouldGetUp && vel <= 30 && angvel <= 200 && !self.Fishing && !self.Sitting) then
			self.ShouldGetUp = true;
			timer.Create(tostring(self) .. "GetUpTimer", math.random(3, 6), 1, function()
				if (IsValid(self)) then
					self.CanGetUp = true;
					self.ShouldGetUp = false;
					self:EmitSound("mother/saturn_getup.wav", 60, 100);
				end
			end);
		end
	end
	if ((self:FeetPlanted() && vel <= 100 && angvel <= 75) || self.Fishing || self.Sitting || self.Flying) then
		self:RandomSchedule();
	end
	if (!self:FeetPlanted()) then
		self.ShouldWalk = true;
	end
	self:NextThink(CurTime());
	return true;
end

function ENT:PhysicsSimulate(phys, delta)
	phys:Wake();
	if (self:WaterLevel() >= 1) then
		return;
	end
	//Simulated friction, since we need to use ice as our physprop (it negates the collsion dust)
	local forward, right = 0;
	local vel = phys:GetVelocity();
	local forwardvel = phys:GetAngles():Forward():Dot(vel);
	local rightvel = phys:GetAngles():Right():Dot(vel);
	local spd = vel:Length();
	
	local wlkchk = phys:GetAngles():Up().z;
	if (self.Walking && wlkchk > .9) then
		phys:ComputeShadowControl(self:WalkSC(delta));
	end
	if (self.CanGetUp) then
		phys:ComputeShadowControl(self:GetUpSC(delta));
	end
	if (self.Fishing || self.Sitting) then
		phys:ComputeShadowControl(self:FishSC(delta));
	end
	if (self.Flying) then
		phys:ComputeShadowControl(self:FlySC(delta));
	end
	
	//We be rollin, they laughin
	if (self:TouchingGround() || spd >= 200) then
		construct.SetPhysProp(nil, self, 0, nil, {GravityToggle = true, Material = "rubber"});
	end
	
	//We're firmly planted on the ground
	if (self:FeetPlanted()) then
		if (spd < 200 && wlkchk > .9) then
			construct.SetPhysProp(nil, self, 0, nil, {GravityToggle = true, Material = "ice"});
			forward = (forwardvel * .25) * -1;
			right = (rightvel * .25);
			if (self.Fishing || self.Sitting) then
				self:SetLocalVelocity(Vector(0, 0, 0));
				phys:ApplyForceCenter(Vector(0, 0, 400));
			end
		end
	else
		if (self.Walking && !self.CanGetUp) then
			if (self.CurrentEndFunc) then
				local f, err = pcall(self.CurrentEndFunc, self);
				if (!f) then
					print("ERROR: " .. err);
					return;
				end
			end
			self.Walking = false;
			self.SCHEDTime = 0;
		end
	end
	
	local linear = (Vector(forward, right, 0) * delta * 1000);
	
	return Vector(0, 0, 0), linear, SIM_LOCAL_ACCELERATION;
end

function ENT:Explode()
	local ef = EffectData()
	local pos = (self:GetPos() + Vector(0, 0, 25));
	ef:SetStart(Vector(255, 200, 175));
	ef:SetOrigin(pos);
	ef:SetScale(1);
	util.Effect("balloon_pop", ef);
	util.Effect("balloon_pop", ef);
	util.Effect("balloon_pop", ef);
	ef:SetStart(Vector(255, 0, 0));
	util.Effect("balloon_pop", ef);
	self:EmitSound("mother/saturn_hit.wav", 80, math.random(35, 60));
	self:Remove();
end


//Sneaky admin can spawn a Mr. Saturn with any hat they want if they're sneaky
function GiveHattedSaturn(ply, cmd, args)
	if (!ply:IsAdmin()) then //tsk tsk
		return;
	end
	if (!args[1]) then
		return;
	end
	local skin = (args[2] || nil);
	local nargs = tonumber(args[1]);
	local txt = "Hatted Mr. Saturn";
	if (nargs < 0 || nargs > #MRSATURNHATTABLE.hats) then
		txt = "Mr. Saturn";
	end
	local tr = ply:GetEyeTrace();
	if (!tr.Hit) then
		return;
	end
	local pos = tr.HitPos;
	local pos = (pos + (tr.HitNormal * 16));
	local ent = ents.Create("mr_saturn");
	ent:SetPos(pos);
	ent.SpawnWithHat = true;
	ent:Spawn();
	ent:SetHat(tonumber(args[1]), skin);
	undo.Create(txt)
		undo.AddEntity(ent);
		undo.SetPlayer(ply);
		undo.SetCustomUndoText("Undone " .. txt);
	undo.Finish()
end
concommand.Add("MOTHER_mr_saturn_hat", GiveHattedSaturn);
