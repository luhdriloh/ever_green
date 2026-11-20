-- character
function plinit()
  return {
    x = 0,
    y = 0,
    start_x = 0,
    start_y = 0,
    dx = 0,
    dy = 0,
    flx = true,
    grounded = false,
    on_platform = false,
    freeze = false,
    active_orb = 1,
    platforms = nil,
    clone = false,
    stuck_frames = 0,
    dead = false,
    start_restart = false,
    restart_frames = 0,
    intensity = 0,
    shake_control = 1,
    switch_orbs_frames = 0, -- keeps track of the switch orb animation 3 frames long

    -- animation values
    state = character_idle,
    sp = character_idle.start,
    step = 0,
    orbs = nil,

    level_set = function(self, x, y, orbs, platforms, clone)
      self.x = x
      self.y = y
      self.start_x = self.x
      self.start_y = self.y
      self.active_orb = 1
      self.orbs = orbs
      self.platforms = platforms
      self.clone = clone or false
      self.freeze = false

      if self.clone == false and count(self.orbs) > 0 do
        self.orbs[1].selected = true
      end
    end,

    update = function(self)
      local newstate = character_idle

      -- input
      if btn(0) then
        self.dx = -1
        self.flx = false
        newstate = character_walk
      elseif btn(1) then
        self.dx = 1
        self.flx = true
        newstate = character_walk
      else
        self.dx = 0
      end

      if self.clone == false then
        if btn(2) and self.grounded and self.start_restart then
          self.restart_frames += 1
          self.intensity += self.shake_control
          if self.restart_frames > 60 then
            self.restart_frames = 0
            self.intensity = 0
            self.start_restart = false
            self:respawn()
          end
        elseif not btn(2) then
          self.restart_frames = 0
          self.intensity = 0
          self.start_restart = true
        end

        if btnp(3) and self.grounded then -- switch orbs
          local orb_count = count(self.orbs)
          if orb_count > 0 then
            frame = 0
            self.switch_orbs_frames = 3
            self.orbs[self.active_orb].selected = false
            self.active_orb = 1 + ((self.active_orb) % orb_count)
            self.orbs[self.active_orb].selected = true
          end
        end
        if btnp(4) and not self.freeze then -- orb placement
          if count(self.orbs) > 0 then
            local orb = self.orbs[self.active_orb]
            orb:use(self)
          end
        end
      end

      if btn(5) and self.grounded and not self.freeze then
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
      apply_gravity_2(self)

      -- Stuck checks
      local stuck = check_collision(self, solid_flag)
      for platform in all(self.platforms) do
        if check_dynamic_collisions(self, platform) then
          stuck = true
          break
        end
      end

      if stuck then
        self.stuck_frames += 1
        if self.stuck_frames > 4 then
          self.stuck_frames = 0
          self:respawn()
        end
      else
        self.stuck_frames = 0
      end

      -- animation state
      if self.dy < 0 then
        newstate = character_jump
      elseif self.dy > 0 and not self.grounded then
        newstate = character_fall
      end

      -- jump land particles
      if (self.state.name == 'jump' or self.state.name == 'fall')
        and (newstate.name == 'idle' or newstate.name == 'walk') then
        particle_manager:land(self, true)
      end

      if self.state.name != newstate.name then
        self.state = newstate
        self.sp = self.state.start
        self.step = 0
      end

      update_frame(self, self.state)
      if self.switch_orbs_frames > 0 then
        -- switch orb animation
        self.sp = 18
        self.switch_orbs_frames -= 1
      end
    end,

    draw = function(self)
      if self.intensity > 0 then
        self:shake()
      end
      spr(self.sp, self.x, self.y, 1, 1, self.flx)
      camera()
    end,

    move_player_x = function(self, x_dist)
      local old_x = self.x
      self.x += x_dist

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
    end,

    respawn = function(self)
      -- set all orbs to 'placed' = false
      self.dead = true
      for orb in all(self.orbs) do
        orb.placed = false
        if orb.clone_active != nil then
          orb.clone_active = false
          orb.clone.x = -20
        end
      end
      if not self.clone then
        particle_manager:use_orb(self, { 5, 7 }, 1)
        self.x = self.start_x
        self.y = self.start_y
        particle_manager:use_orb(self, { 5, 7 }, 2)
      end
    end,

    shake = function(self)
      local shake_x=rnd(self.intensity) - (self.intensity /2)

      --offset the camera
      camera(shake_x, 0)

      --ease shake and return to normal
      self.intensity = min(self.intensity, 1.9) * .9
      if self.intensity < .3 then self.intensity = 0 end
    end,
  }
end

-- states
character_idle = {
  name = "idle",
  start = 16,
  last = 17,
  per_frame = 9
}

character_walk = {
  name = "walk",
  start = 1,
  last = 6,
  per_frame = 2
}

character_jump = {
  name = "jump",
  start = 19, 
  per_frame = 0
}

character_fall = {
  name = "fall",
  start = 20,
  per_frame = 0
}
