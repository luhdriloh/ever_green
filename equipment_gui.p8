function equipment_gui_init(orbs)
  return {
    x_start = 15,
    y_start = 0,
    outline_sp = 29,
    frame = 0,
    orbs = {},

    set_orbs = function(self, orbs)
      self.orbs = orbs
    end,

    update = function(self)
      self.frame += 1
    end,

    draw = function(self)
      local x = self.x_start * 8
      local y = self.y_start * 8

      for orb in all(self.orbs) do
        spr(orb.sp, x, y)
        if orb.selected do
          if self.frame % 30 < 15 then
            spr(self.outline_sp, x, y)
          end
        end

        y += 8
      end
    end,
  }
end