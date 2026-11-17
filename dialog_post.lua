function dialog_post_init(player, sp, x, y, counter, activation_callback)
  return {
    x = x * 8,
    y = y * 8,
    sp = sp,
    press_button_sp = 26,
    player = player,
    dialog_counter = counter,
    activation_callback = activation_callback,
    dialogue_active = false,
    is_player_close = false,
    dialog_text = {
      "😐 hi little forest gnome, i'm the great forest diety 웃 and I need your help getting my powers back. if you accept this quest run to the doorway, it will take you to the next forest area!",
      "😐 press x to jump on the ledges",
      "did you see the platform move! try standing on the blue button to see if anything happens!",
      "this one is tricky. let me help you with some of my teleport powers. go grab that green teleport orb!",
      "you did it! heres how to use my powers. first press 🅾️ to place down the teleport orb, and then press 🅾️ again to teleport to it. also checkout the top right corner to see your active power orb, its as easy as that! play around with your new powers and see if you can get out of here!",
      "here, take one of my clone orbs to help you out! you can create a clone of yourself by toggling the orb twice! toggle it a third time to deactivate it. try it!",
      "i think you're going to need another clone orb for this one, take another!",
    },

    update = function(self)
      local old_is_player_close = self.is_player_close
      self.is_player_close = abs(self.player.x - self.x) < 8 and
         abs(self.player.y - self.y) < 8

      if self.is_player_close then
        self.player.can_jump = false
        self.player.can_use_orbs = false
      elseif not self.is_player_close and old_is_player_close then
        self.player.can_jump = true
        self.player.can_use_orbs = true
      end

      if self.is_player_close and self.player.grounded and btnp(5) and not self.dialogue_active then
        self.dialogue_active = true

        if self.activation_callback != nil then
          self.activation_callback()
        end

        dtb_disp(self.dialog_text[self.dialog_counter], function()
          self.dialogue_active = false
          if self.sp != 10 then
            self.x = -10
          end
        end)
      end
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y)
      if self.is_player_close then
        spr(self.press_button_sp, self.x+9, self.y-8)
      end
    end
  }
end

