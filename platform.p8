function platform_init(player, platforms, x, y, properties)
    return {
      x = x * 8,
      y = y * 8,
      velocity = -1,
      start_pos = { x=x*8, y=y*8 },
      player = player,
      riders = {}, -- list of objects standing on this platform
      platforms = platforms,
      properties = properties,
      active = false,

      update = function(self)
        self.velocity = self.active and 1 or -1

        -- compute the new position
        local old_x, old_y = self.x, self.y
        self.x += self.velocity * self.properties.dx
        self.y += self.velocity * self.properties.dy

        -- see if we've hit any platform stops 
        -- collision checks
        local collide = check_collision(self, platform_stop_flag, 0, 0, 7, 7)
          or check_collision(self, solid_flag, 0, 0, 7, 7)

        -- add dynamic collisions. For other platforms OR the player
        for platform in all(self.platforms) do
          if platform != self then
            collide = collide or check_dynamic_collisions(self, platform, -1, -1, 8, 8)
          end
        end

        if collide then
          self.x, self.y = old_x, old_y
        end

        local player_collide = check_dynamic_collisions(self, self.player, 0, 0, 7, 7)
        local already_riding = false
        if player_collide then
          for r in all(self.riders) do
            already_riding = already_riding or r == self.player
          end
        end

        -- if we didn't move then we don't need to move the riders
        if old_x != self.x or old_y != self.y then
          -- carry riders 
          for r in all(self.riders) do
            r.x += self.velocity * self.properties.dx
            r.y += self.velocity * self.properties.dy
          end

          if player_collide and already_riding == false then
            self.player.x += self.velocity * self.properties.dx
            self.player.y += self.velocity * self.properties.dy
          end
        end

        -- remove players or objects that have jumped off
        self:remove_riders()

      end,

    -- call after player update to pick up new riders
    attach = function(self, o)
      for r in all(self.riders) do
        if r == o then
          return
        end
      end
      add(self.riders, o)
    end,

    remove_riders = function(self)
      for r in all(self.riders) do
        if check_dynamically_grounded(r, self) == false then
          del(self.riders, r)
        end
      end
    end,

    draw = function(self)
      spr(self.properties.sp, self.x, self.y)
    end,
  }
end