-- character
function plinit()
  return {
    x = 0,
    y = 0,
    dy = 0,
    flx = true,
    grounded = false,
    can_jump = true,
    active_orb = 1,
    platforms = {},

    -- animation values
    state = character_animstate.idle,
    sp = character_animstate.idle.start,
    step = 0,
    orbs = nil,

    level_set = function(self, x, y, orbs, platforms)
      self.x = x * 8
      self.y = y * 8
      self.active_orb = 1
      self.orbs = orbs
      self.platforms = platforms
    end,

    update = function(self)
      local newstate = character_animstate.idle
      local oldx = self.x
      local oldy = self.y
      local olddy = self.dy

      -- gravity
      apply_gravity(self)

      -- grounded
      self.grounded = check_character_grounded(self)
      if self.grounded then
        self.dy = 0
      end

      if btn(0) then -- left
        self.x = max(self.x - 1, -1)
        self.flx = false
        newstate = character_animstate.walk
      elseif btn(1) then -- right
        self.x = min(self.x + 1, 121)
        self.flx = true
        newstate = character_animstate.walk
      end

      if btnp(3) then -- switch orbs
      end
      if btnp(4) then -- orb placement
        if count(self.orbs) > 0 then
          self.orbs[self.active_orb]:use(self)
        end
      end
      if btn(5) and self.grounded and self.can_jump then -- jump
        self.dy = jump_speed
        self.grounded = false
      end

      -- jump / fall state
      if self.dy < 0 then
        newstate = character_animstate.jump
      elseif self.dy > 0 then
        newstate = character_animstate.fall
      end

      -- collision checks
      local collide = check_collision(self, solid_flag)
      local dynamic_collide = false
      for platform in all(self.platforms) do
        dynamic_collide = dynamic_collide or check_dynamic_collisions(self, platform)
      end

      if collide or dynamic_collide then
        self.x = oldx
      end

      -- check if in a new animation
      if self.state.name != newstate.name then
        self.state = newstate
        self.sp = self.state.start
        self.step = 0
      end

      -- update frame
      update_frame(self, self.state)
    end,

    draw = function(self)
      if count(self.orbs) > 0 then
        self.orbs[self.active_orb]:draw()
      end
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
