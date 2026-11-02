function teleport_orb_init(x, y, platforms)
  return {
    x = x * 8,
    y = y * 8,
    grounded = false,
    platforms = platforms,
    dy = 0,
    sp = 14,
    inuse = false,

    use = function(self, o)
      if not self.inuse then
        self:set(o.x, o.y)
      elseif self.inuse then
        self:transport(o)
      end
    end,

    transport = function(self, o)
      self.inuse = false
      o.x = self.x
      o.y = self.y
    end,

    set = function(self, x, y)
      self.inuse = true
      self.x = x
      self.y = y
    end,

    update = function(self)
      apply_gravity_2(self)
    end,

    draw = function(self)
      if (self.inuse) then
        spr(self.sp, self.x, self.y)
      end
    end,
  }
end