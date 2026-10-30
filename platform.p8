function platform_init(player, x, y, platform_data)
    return {
      x = x * 8,
      y = y * 8,
      velocity = 1,
      start_pos = { x=x*8, y=y*8 },
      platform_data = platform_data,
      activated = false,

      update = function(self)
        if activated != true then
          return
        end

        -- compute the new position
        local old_x, old_y = self.x, self.y
        self.x += self.velocity * self.platform_data.x_vel
        self.y += self.velocity * self.platform_data.y_vel

        -- see if we've hit any platform stops 


      end,

      draw = function(self)
        spr(self.platform_data.sp, self.x, self.y)
      end
    }
end