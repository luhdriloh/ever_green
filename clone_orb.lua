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
        particle_manager:use_orb(self.clone, { orange, 4 }, 1)
        self.clone.x = -10
        self.clone.y = -10
        self.clone_active = false
      elseif not self.placed then
        self:set(o.x, o.y)
      elseif self.placed then
        self.placed = false
        self.clone_active = true
        particle_manager:use_orb(self, { orange, 4 }, 1)
        self.clone:level_set(self.x, self.y, nil, self.platforms, true, true)
        self.sp = orange_orb_anim.start
      end
    end,

    set = function(self, x, y)
      self.placed = true
      self.x = x
      self.y = y
    end,

    update = function(self)
      if self.placed then
        update_frame(self, orange_orb_anim)
        apply_gravity_2(self)
      end

      if self.clone.dead then
        particle_manager:use_orb(self.clone, { orange, 4 }, 1)
        self.clone.x = -20
        self.clone_active = false
        self.clone.dead = false
      else

      if self.clone_active then
          self.clone:update()
        end
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
        pal(5, 9)
        pal(1, 9)
        pal(7, 5)
        self.clone:draw()
        pal(0)
      end
    end,
  }
end

orange_orb_anim = {
  start = 30,
  last = 31,
  per_frame = 10,
}