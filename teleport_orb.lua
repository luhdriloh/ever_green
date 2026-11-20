function teleport_orb_init(x, y, platforms, index)
  return {
    x = x * 8,
    y = y * 8,
    grounded = false,
    platforms = platforms,
    dy = 0,
    sp = 13,
    step = 0,
    pointer_sp = 21,
    selected = false,
    placed = false,
    index = index,

    set = function(self, x, y)
      self.placed = true
      self.x = x
      self.y = y
    end,

    use = function(self, o)
      if not self.placed then
        sfx(10)
        self:set(o.x, o.y-1)
      elseif self.placed then
        sfx(12)
        particle_manager:use_orb(o, { 11,3 }, 1)
        particle_manager:use_orb(self, { 11,3 }, 2)
        self.placed = false
        o.x = self.x
        o.y = self.y
        o.dy = 0
        self.sp = green_orb_anim.start
      end
    end,

    update = function(self)
      if self.placed then
        update_frame(self, green_orb_anim)
        apply_gravity_2(self)
      end
    end,

    draw = function(self)
      if self.placed then
        spr(self.sp, self.x, self.y)
        if self.selected and frame % 30 < 15 then
          spr(self.pointer_sp, self.x, self.y - 4)
        end
      end
    end,
  }
end

green_orb_anim = {
  start = 13,
  last = 14,
  per_frame = 10,
}