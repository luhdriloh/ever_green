function butterfly_init(x, y)
	return {
    x = x * 8,
    y = y * 8,
    ox = x * 8,  -- origin (center of figure-8)
    oy = y * 8,
    t = rnd(6),
    sp = 27,
    spd = .001 + rnd(0.005),
    rx = 2 + rnd(8),  -- horizontal radius
    ry = 2 + rnd(4),   -- vertical radius
		vx = 0,
		flx = true,

		update = function(self)
			local px = self.x

			self.t += self.spd
			-- self.x = self.ox + self.rx * sin(self.t)
			-- self.y = self.oy + self.ry * sin(self.t * 2)

			self.x = self.ox + self.rx * sin(self.t) + 4*sin(self.t*3)
			self.y = self.oy + self.ry * sin(self.t*2) + 3*cos(self.t*5)

			self.vx = self.x - px

			-- flap wings (toggle every 4 frames)
			self.t2 = (self.t2 or 0) + 1
			if self.t2 >= 4 then
				self.t2 = 0
				self.sp = 55 - self.sp
			end
		end,

		draw = function(self)
			local flip = self.vx > 0.0 and true or false
			spr(self.sp, self.x, self.y, 1, 1, flip)
		end,
	}
end

