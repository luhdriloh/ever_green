function platform_init(player, x, y, properties)
    return {
      x = x * 8,
      y = y * 8,
      velocity = -1,
      start_pos = { x=x*8, y=y*8 },
      riders = {}, -- list of objects standing on this platform
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
        if collide then
          self.x, self.y = old_x, old_y
        end

        -- carry riders 
        -- for r in all(self.riders) do
        --   r.x += self.velocity * properties.dx
        --   r.y += self.velocity * properties.dy
        -- end

      end,

    -- call after player update to pick up new riders
    attach = function(self, o)
      -- o is "on" the platform if its feet overlap the platform's top
      local feet_y = o.y + 8
      if feet_y >= self.y and feet_y <= self.y + 8
         and o.x + 4 >= self.x and o.x + 4 <= self.x + 8 then
        -- add if not already a rider
        for r in all(self.riders) do
          if r == o then
            return
          end
        end
        add(self.riders, o)
      else
        -- fell off / walked off → detach
        for i, r in ipairs(self.riders) do
          if r == o then
            del(self.riders, i)
            break
          end
        end
      end
    end,

    draw = function(self)
      spr(self.properties.sp, self.x, self.y)
    end
  }
end