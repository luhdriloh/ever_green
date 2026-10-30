function dialog_post_init(player)
  return {
    x = -20,
    y = -20,
    sp = 10,
    press_button_sp = 26,
    player = player,
    dialog_counter = 1,
    dialog_text = {
      "hello how are you doing today, mr ever_green person dude hahahahahhahahahahah adsfasdjkfkjasdfsadfasdfasdfsdafsadfsadfssadfsdaf adsf",
      "sup",
    },

    level_set = function(self, x, y, dialog_counter)
      self.x = x * 8
      self.y = y * 8
      self.dialog_counter = dialog_counter or self.dialog_counter
    end,

    update = function(self)
      local is_player_close = abs(player.x - self.x) < 8 and 
         abs(player.y - self.y) < 8
      
      if is_player_close then
        player.can_jump = false
      else
        player.can_jump = true
      end

      if is_player_close and
        player.grounded == true and
         btn(5) then
        
        dialog({
          txt = self.dialog_text[self.dialog_counter],
          dl = 2,
          w = 112,
          x = 8,
          y = 16,
        })
      end
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y)

      if player.can_jump == false then
        spr(self.press_button_sp, self.x+9, self.y-8)
      end
    end
  }
end

-- table with info posts for each location/level and with its dialog