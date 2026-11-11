function button_init(players, platforms, x, y, button_properties)
		return {
			x = x * 8,
      y = y * 8,
			players = players,
			platforms = platforms,
			button_properties = button_properties,
			active = false,

			update = function(self)
				-- check if the user has pressed the button_properties
				-- check the feet location
				local old_active = self.active
				self.active = false

				for player in all(self.players) do
					self.active = self.active or check_dynamic_collisions(player, self, 3, -2, 4, 0)
				end

				if old_active != self.active then
					self:set_platforms(self.active)
				end
			end,

			draw = function(self)
				local sp = self.active and self.button_properties.sp+1 or self.button_properties.sp
				spr(sp, self.x, self.y)
			end,

			set_platforms = function(self, active)
				if self.button_properties.color == white and active == false then
					return
				end
				-- set platforms of the same color to the appropriate state
				for platform in all(self.platforms) do
					if platform.properties.color == self.button_properties.color then
						if platform.properties.color == white then
							platform:activate(not platform.active)
						else
							platform:activate(active)
						end
					end
				end
			end
		}
end