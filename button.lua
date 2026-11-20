function button_init(players, platforms, x, y, button_props)
		return {
			x = x,
      y = y,
			players = players,
			platforms = platforms,
			button_props = button_props,
			active = false,

			update = function(self)
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
				local sp = self.active and self.button_props.sp+1 or self.button_props.sp
				spr(sp, self.x, self.y)
			end,

			set_platforms = function(self, active)
				if self.button_props.color == yellow and active == false then
					return
				end
				-- set platforms of the same color to the appropriate state
				for platform in all(self.platforms) do
					if platform.properties.color == self.button_props.color then
						if platform.properties.color == yellow then
							platform:activate(not platform.active)
						else
							platform:activate(active)
						end
					end
				end
			end
		}
end