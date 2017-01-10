function EFFECT:Init(data) 
	local pos = data:GetOrigin();
	local emitter = ParticleEmitter(pos, true);
	for i = 0, 12 do
		local rnd = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1));
		local particle = emitter:Add("Effects/splash2", (pos + (rnd * 16)));
		if (particle) then
			rnd.z = (rnd.z * 12);
			particle:SetVelocity((rnd * 2));
			particle:SetLifeTime(0);
			particle:SetDieTime(10);
			particle:SetStartAlpha(255);
			local size = math.Rand(8, 9);
			particle:SetStartSize(size);
			particle:SetEndSize(0);
			particle:SetRoll(math.Rand(0, 360));
			particle:SetRollDelta(math.Rand(-2, 2));
			particle:SetAirResistance(2);
			particle:SetGravity(Vector(0, 0, -250));
			particle:SetColor(75, 50, 50);
			particle:SetCollide(true);
			particle:SetAngleVelocity(Angle(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(-50, 50)));
			particle:SetBounce(0);
			particle:SetLighting(false);
		end
	end
	self:EmitSound("ambient/water/water_splash" .. tostring(math.random(1, 3)) .. ".wav");
	emitter:Finish();
end

function EFFECT:Think()
	return false;
end


function EFFECT:Render()
end
