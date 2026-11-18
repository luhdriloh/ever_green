function clone_orb_init(x, y, platforms, index)
  return {
    x = x * 8,
    y = y * 8,
    grounded = false,
    platforms = platforms,
    dy = 0,
    sp = 30,
    step = 0,
    pointer_sp = 21,
    selected = false,
    placed = false,
    index = index,
    clone_active = false,
    clone = plinit(),

    use = function(self, o)
      if self.clone_active then
        particle_manager:use_orb(self.clone, { orange, dark_orange }, 1)
        self.clone.x = -10
        self.clone.y = -10
        self.clone_active = false
      elseif not self.placed then
        self.placed = true
        self:set(o.x, o.y)
        particle_manager:orb_highlights(self, orange)
      elseif self.placed then
        self.placed = false
        self.clone_active = true
        particle_manager:use_orb(self, { orange, dark_orange }, 1)
        self.clone:level_set(self.x, self.y, nil, self.platforms, true, true)
        particle_manager:orb_highlights(self, green)
        self.sp = orange_orb_animstate.idle.start
      end
    end,

    set = function(self, x, y)
      self.x = x
      self.y = y
    end,

    update = function(self)
      if self.placed then
        update_frame(self, orange_orb_animstate.idle)
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
          spr(self.pointer_sp, self.x, self.y - 4)
        end
      end

     if self.clone_active then
      if self.selected and frame % 30 < 15 then
        spr(self.pointer_sp, self.clone.x, self.clone.y - 4)
      end
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

orange_orb_animstate = {
  idle = {
    name = "idle",
    start = 30,
    last = 31,
    per_frame = 10,
  },
}