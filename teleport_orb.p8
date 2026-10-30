function teleport_orb_init(xpos, ypos)
  return {
    x = xpos,
    y = ypos,
    sp = 13,
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

    set = function(self, xpos, ypos)
      self.inuse = true
      self.x = xpos
      self.y = ypos
    end,

    draw = function(self)
      if (self.inuse) then
        spr(self.sp, self.x, self.y)
      end
    end
  }
end