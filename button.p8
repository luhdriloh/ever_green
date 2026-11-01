function button_init(player, x, y, platforms, button_properties)
		return {
			x = x * 8,
      y = y * 8,
			player = player,
			platforms = platforms,
			button_properties = button_properties,
			active = false,

			update = function(self)
				-- check if the user has pressed the button_properties
				-- check the feet location
				local old_active = self.active
				self.active = check_dynamic_collisions(self.player, self, 2, -2, 5, 0) and true or false

				if old_active != self.active then
					self:set_platforms(self.active)
				end
			end,

			draw = function(self)
				local sp = self.active and self.button_properties.sp+1 or self.button_properties.sp
				spr(sp, self.x, self.y)
			end,

			set_platforms = function(self, active)
				-- set platforms of the same color to the appropriate state
				for platform in all(self.platforms) do
					if platform.properties.color == self.button_properties.color then
						platform.active = active
					end
				end
			end
		}
end