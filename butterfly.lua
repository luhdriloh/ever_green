function butterfly_init(x, y)
	return {
    x = x * 8,
    y = y * 8,
    ox = x * 8,
    oy = y * 8,
    t = rnd(6),
    sp = 27,
    spd = .001 + rnd(0.005),
    rx = 2 + rnd(8),
    ry = 2 + rnd(4),
		vx = 0,
		flx = true,
		trail = {},
		trail_t = 0,
		last_trail_x = x * 8,
		last_trail_y = y * 8,

		update = function(self)
			local px = self.x

			self.t += self.spd

			self.x = self.ox + self.rx * sin(self.t) + 4*sin(self.t*3)
			self.y = self.oy + self.ry * sin(self.t*2) + 3*cos(self.t*5)

			self.vx = self.x - px

			self.t2 = (self.t2 or 0) + 1
			if self.t2 >= 4 then
				self.t2 = 0
				self.sp = 55 - self.sp
			end

			-- record trail every 2 frames
			local dx = self.x - self.last_trail_x
			local dy = self.y - self.last_trail_y
			if dx*dx + dy*dy >= 16 then  -- 3^2 = 9
				local tx = self.flx and self.x + 2 or self.x + 6
				add(self.trail, {x = tx, y = self.y + 3})
				self.last_trail_x = self.x
				self.last_trail_y = self.y
			end

			if #self.trail > 3 or (frame % 30 == 0 and #self.trail > 0) then
				del(self.trail, self.trail[1])
			end
		end,
		

		draw = function(self)
			-- trail: white → gray → dark gray → gone
			for i = 1, #self.trail do
				local p = self.trail[i]
				local age = i / #self.trail
				local col = 7
				-- if age > 0.6 then col = 5
				-- elseif age > 0.3 then col = 6 end
				pset(p.x, p.y, col)
			end

			self.flx = self.vx > 0.0 and true or false
			spr(self.sp, self.x, self.y, 1, 1, self.flx)
		end,
	}
end