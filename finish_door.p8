-- on heart collection the next level starts

function finish_door_init(player, advance_level_callback)
  return {
    x = -20,
    y = -20,
    sp = 11,
    player = player,
    advance_level_callback = advance_level_callback,

    level_set = function(self, x, y)
      self.x = x * 8
      self.y = y * 8
    end,

    update = function(self)
      if abs(player.x - self.x) < 5 and 
         abs(player.y - self.y) < 5 then
        self.advance_level_callback()
      end
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y)
    end
  }
end