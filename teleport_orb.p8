function teleport_orb_init(x, y, platforms)
  return {
    x = x * 8,
    y = y * 8,
    grounded = false,
    platforms = platforms,
    dy = 0,
    sp = 13,
    placed = false,

    set = function(self, x, y)
      self.placed = true
      self.x = x
      self.y = y
    end,

    use = function(self, o)
      if not self.placed then
        self:set(o.x, o.y)
      elseif self.placed then
        self:transport(o)
      end
    end,

    transport = function(self, o)
      self.placed = false
      o.x = self.x
      o.y = self.y
    end,

    update = function(self)
      apply_gravity_2(self)
    end,

    draw = function(self)
      if (self.placed) then
        spr(self.sp, self.x, self.y)
      end
    end,
  }
end