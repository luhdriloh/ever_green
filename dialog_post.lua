function dialog_post_init(player, sp, x, y, counter, activate_callback)
  return {
    x = x * 8,
    y = y * 8,
    sp = sp,
    butn_sp = 26,
    player = player,
    dialog_counter = counter,
    activate_callback = activate_callback,
    dialogue_active = false,
    is_player_close = false,
    dialog_text = {
      "😐 hi little forest gnome, i'm the great forest diety 웃 and i need your help getting back the forests light. go through the tree light portals to start collecting light.",
      "press x to jump on the ledges",
      "try standing on the blue button to see if anything happens",
      "have some of my teleport powers. go grab that green teleport orb",
      "press 🅾️ to place down the teleport orb. press 🅾️ again to teleport to it. the top right corner shows you your active power orb",
      "you're going to need another power orb. i've put it in your inventory. press ⬇️ to cycle through your orbs. look at your hands or the big arrow to see which orb is active",
      "go grab that orange clone orb",
      "press 🅾️ to place down the clone orb. press 🅾️ again to activate your clone. press 🅾️ a third time to deactivate your clone and return it to your inventory.",
    },

    update = function(self)
      local old_is_player_close = self.is_player_close
      self.is_player_close = abs(self.player.x - self.x) < 8 and
         abs(self.player.y - self.y) < 8

      if self.is_player_close then
        self.player.freeze = true
      elseif not self.is_player_close and old_is_player_close then
        self.player.freeze = false
      end

      if self.is_player_close and self.player.grounded and btnp(5) and not self.dialogue_active then
        self.dialogue_active = true

        if self.activate_callback != nil then
          self.activate_callback()
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
        spr(self.butn_sp, self.x+9, self.y-8)
      end
    end
  }
end

