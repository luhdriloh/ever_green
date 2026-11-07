function clone_orb_init(x, y, platforms)
  return {
    x = x * 8,
    y = y * 8,
    grounded = false,
    platforms = platforms,
    dy = 0,
    sp = 30,
    outline_sp = 29,
    selected = false,
    placed = false,
    clone_active = false,
    clone = plinit(),

    use = function(self, o)
      if self.clone_active then
        self.clone_active = false
      elseif not self.placed then
        self.placed = true
        self:set(o.x, o.y)
      elseif self.placed then
        self.placed = false
        self.clone_active = true
        self.clone:level_set(self.x, self.y, nil, self.platforms, true, true)
      end
    end,

    set = function(self, x, y)
      self.x = x
      self.y = y
    end,

    update = function(self)
      if self.placed then
        apply_gravity_2(self)
      end

      if self.clone_active then
        self.clone:update()
      end
    end,

    draw = function(self)
      if self.placed then
        spr(self.sp, self.x, self.y)
        if self.selected and frame % 30 < 15 then
          spr(self.outline_sp, self.x, self.y)
        end
      end

     if self.clone_active then
        -- pal(1, 6)
        -- pal(5,1)
        -- pal(7, 5)
        -- pal(7,5)
        pal(5, 9)
        pal(1, 9)
        pal(7, 5)
        self.clone:draw()
        pal()
      end
    end,
  }
end