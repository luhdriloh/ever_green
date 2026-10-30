function dialog_post_init(player)
  return {
    x = 0,
    y = 0,
    sp = 10,
    step = 0,
    player = player,
    dialog_counter = 1,
    dialog_text = {
      "hello",
      "sup",
    },

    level_set = function(self, x, y, dialog_counter)
      self.x = x
      self.y = y
      self.dialog_counter = dialog_counter or self.dialog_counter
    end,

    update = function(self)
      if abs(player.x - self.x) < 5 and 
         abs(player.y - self.y) < 5 then
        dialog({
          txt = self.dialog_text[self.dialog_counter]
        })
      end
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y)
    end
  }
end

-- table with info posts for each location/level and with its dialog