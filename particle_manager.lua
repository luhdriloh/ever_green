function particle_manager()
  return {
    land_emitters = {},
    star_emitters = {},
    orb_emitters = {},
    orb_highlight_emitters = {},
    door_emitters = {},
    door = nil,
    orbs = nil,

    init = function(self)
      self:create_orb_emitters()
      self:create_orb_highlight_emitters()
      -- self:create_door_emitters()
    end,

    update = function(self)
      -- update time for ps particle library
      update_time()
      for e in all(self.land_emitters) do
        ps_set_pos(e.emitter, e.player.x+4, e.player.y+7)
        e.emitter.update(e.emitter, delta_time)
      end

      for e in all(self.door_emitters) do
        e.update(e, delta_time)
      end

      for orb in all(self.orbs) do
        local emitter = self.orb_highlight_emitters[orb.index]
        if orb.placed then
          ps_set_pos(emitter, orb.x+4, orb.y+4)
        end
        emitter.update(emitter, delta_time)
      end

      foreach(self.star_emitters, function(obj) obj.update(obj, delta_time) end)
      foreach(self.orb_emitters, function(obj) obj.update(obj, delta_time) end)
    end,

    draw = function(self)
      foreach(self.land_emitters, function(obj) obj.emitter:draw() end)
      foreach(self.orb_emitters , function(obj) obj:draw() end)
      foreach(self.star_emitters, function(obj) obj:draw() end)
      foreach(self.orb_highlight_emitters, function(obj) obj:draw() end)
      foreach(self.door_emitters, function(obj) obj:draw() end)
    end,

    -- set up emitter for when the player lands
    land = function(self, player)
      local emitter_for_player = nil
      for e in all(self.land_emitters) do
        if e.player == player then
          emitter_for_player = e.emitter
          break
        end
      end

      if emitter_for_player == nil then
        self:create_land_emitter(player)
      elseif emitter_for_player != nil then
        emitter_for_player.start_emit(emitter_for_player)
      end
    end,

    -- set up emitter for teleportation burst
    use_orb = function(self, o, color, index)
      local emitter = self.orb_emitters[index]
      ps_set_colours(emitter, {7, 6, color})
      ps_set_pos(emitter, o.x+4, o.y+4)
      emitter.start_emit(emitter)
    end,

    orb_highlights = function(self, orb, color)
      local emitter = self.orb_highlight_emitters[orb.index]

      ps_set_pos(emitter, orb.x+4, orb.y+4)
      ps_set_colours(emitter, {7, color})

      if orb.placed then
        emitter.start_emit(emitter)
      else
        emitter.stop_emit(emitter)
      end
    end,

    set_door = function(self, o)
      self.door = o
      for emitter in all(self.door_emitters) do
        ps_set_pos(emitter, o.x+4, o.y+3)
        emitter.start_emit(emitter)
      end
    end,

    stars = function(self)
      local front = emitter.create(64, 64, 0.2, 0)
      ps_set_speed(front, 0, 0)
      ps_set_area(front, 128, 128)
      ps_set_colours(front, {7})
      ps_set_size(front, 0, 0, 1, 0)
      ps_set_life(front, .2, 30)
      ps_set_angle(front, 0, 0)
      add(self.star_emitters, front)
      local midfront = front.clone(front)
      ps_set_frequency(midfront, 0.1)
      ps_set_life(midfront, .2, 30)
      ps_set_colours(midfront, {6})
      add(self.star_emitters, midfront)
      local midback = front.clone(front)
      ps_set_life(midback, .2, 30)
      ps_set_colours(midback, {5})
      ps_set_frequency(midback, 0.08)
      add(self.star_emitters, midback)
      local back = front.clone(front)
      ps_set_frequency(back, 0.01)
      ps_set_size(back, 0, 0, 1, 0)
      ps_set_life(back, .2, 30)
      ps_set_colours(back, {15})
      add(self.star_emitters, back)
    end,

    create_orb_highlight_emitters = function(self)
      local center = emitter.create(64, 64, .6, 0)
      ps_set_size(center, 0)
      ps_set_colours(center, {7, 12})
      ps_set_rnd_colour(center, true)
      ps_set_life(center, .4)
      ps_set_speed(center, 60, -40)
      center.stop_emit(center)
      add(self.orb_highlight_emitters, center)
      local two = center.clone(center)
      two.stop_emit(two)
      add(self.orb_highlight_emitters, two)
    end,

    create_door_emitters = function(self)
      local spinner = emitter.create(64, 84, .4, 0)
      ps_set_life(spinner, .7)
      ps_set_speed(spinner, 10)
      ps_set_colours(spinner, {6, 7, 9})
      ps_set_size(spinner, 1, 0, 2, 1)
      ps_set_angle(spinner, 0, 360)
      ps_set_rnd_colour(spinner, true)
      ps_set_gravity(spinner, true)
      add(self.door_emitters, spinner)
    end,

    create_orb_emitters = function(self, o)
      local burst = emitter.create(-60, 64, 0, 30)
      ps_set_size(burst, 1, 0, 3, 0)
      ps_set_speed(burst, 0)
      ps_set_life(burst, .2, .5)
      ps_set_colours(burst, {7, 6, 11})
      ps_set_burst(burst, true, 10)
      ps_set_area(burst, 6, 6)
      ps_set_rnd_colour(burst, true)
      add(self.orb_emitters, burst)
      local burst_two = burst.clone(burst)
      add(self.orb_emitters, burst_two)
    end,

    create_land_emitter = function(self, player)
      local land_emitter = emitter.create(player.x + 4, player.y+7, 1, 0)
        
      ps_set_life(land_emitter, .1, .3)
      ps_set_angle(land_emitter, 30, 150)
      ps_set_rnd_colour(land_emitter, true)
      ps_set_colours(land_emitter, { 6, 7 })
      ps_set_size(land_emitter, 2, 0, 1, 0)
      ps_set_speed(land_emitter, 25, 5, 10, 10)
      ps_set_gravity(land_emitter, true)
      ps_set_burst(land_emitter, true, 20)
      add(self.land_emitters, {player=player, emitter=land_emitter})
    end,
  }
end