-- character
function plinit()
  return {
    x = 0,
    y = 0,
    dy = 0,
    flx = true,
    grounded = false,
    on_platform = false,
    can_jump = true,
    active_orb = 1,
    platforms = {},
    clone = false,

    -- animation values
    state = character_animstate.idle,
    sp = character_animstate.idle.start,
    step = 0,
    orbs = nil,

    level_set = function(self, x, y, orbs, platforms, clone, pixel_space)
      self.x = pixel_space and x or x * 8
      self.y = pixel_space and y or y * 8
      self.active_orb = 1
      self.orbs = orbs
      self.platforms = platforms
      self.clone = clone or false

      if self.clone == false and count(self.orbs) > 0 do
        self.orbs[1].selected = true
      end
    end,

    update = function(self)
      local newstate = character_animstate.idle

      -- input
      if btn(0) then
        self.dx = -1
        self.flx = false
        newstate = character_animstate.walk
      elseif btn(1) then
        self.dx = 1
        self.flx = true
        newstate = character_animstate.walk
      else
        self.dx = 0
      end

      if self.clone == false then
        if btnp(3) then -- switch orbs
          local orb_count = count(self.orbs)
          if orb_count > 0 then
            self.orbs[self.active_orb].selected = false
            self.active_orb = 1 + ((self.active_orb) % orb_count)
            self.orbs[self.active_orb].selected = true
          end
        end
        if btnp(4) then -- orb placement
          if count(self.orbs) > 0 then
            self.orbs[self.active_orb]:use(self)
          end
        end
      end

      if btn(5) and self.grounded and self.can_jump then
        self.dy = jump_speed
        self.grounded = false
      end

      -- === X PASS ===
      local old_x = self.x
      if self.dx != 0 then
        self.x = max(self.x + self.dx, -1)
        self.x = min(self.x, 121)
      end

      local x_hit = check_collision(self, solid_flag)
      for platform in all(self.platforms) do
        if check_dynamic_collisions(self, platform) then
          x_hit = true
          break
        end
      end

      if x_hit then
        self.x = old_x
      end

      -- === Y PASS ===
      -- todo: add a death anim if the player is smashed between 2 objects
      apply_gravity_2(self)
      

      -- animation state
      if self.dy < 0 then
        newstate = character_animstate.jump
      elseif self.dy > 0 and not self.grounded then
        newstate = character_animstate.fall
      end

      if self.state.name != newstate.name then
        self.state = newstate
        self.sp = self.state.start
        self.step = 0
      end

      update_frame(self, self.state)
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y, 1, 1, self.flx)
    end
  }
end

-- states
character_animstate = {
  idle = {
    name = "idle",
    start = 16,
    last = 17,
    per_frame = 9
  },
  walk = {
    name = "walk",
    start = 1,
    last = 6,
    per_frame = 2
  },
  jump = {
    name = "jump",
    start = 19, 
    per_frame = 0
  },
  fall = {
    name = "fall",
    start = 20,
    per_frame = 0
  }
}
