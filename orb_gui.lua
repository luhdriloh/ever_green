function orb_gui_init(player, orbs)
  return {
    x_start = 120,
    y_start = 0,
    outline_sp = 29,
    player = player,
    orbs = {},

    level_set = function(self, orbs, player)
      self.orbs = orbs
      self.player = player
    end,

    update = function(self)
    end,

    draw = function(self)
      local y = self.y_start

      for orb in all(self.orbs) do
        spr(orb.sp, self.x_start, y)
        if orb.selected then
          if orb.placed or frame % 30 < 15 then
            spr(self.outline_sp, self.x_start, y)
          end
          
          local clone_active = orb.clone_active != nil and orb.clone_active or false
          if not orb.placed and not clone_active then
            local x_pos = self.player.flx and (self.player.x - 4) or (self.player.x + 4)
            local y_pos = self.player.sp == 17 and self.player.y + 2 or self.player.y + 1
            spr(orb.sp, x_pos, self.player.y + 1)
          end
        end

        y += 8
      end
    end,
  }
end