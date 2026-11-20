function particle_manager()
  return {
    land_emitters = {},
    star_emitters = {},
    orb_emitters = {},
    orbs = nil,

    init = function(self)
      self:create_orb_emitters()
      self:stars()
    end,

    update = function(self)
      -- update time for ps particle library
      update_time()
      for e in all(self.land_emitters) do
        ps_set_pos(e.emitter, e.player.x+4, e.player.y+7)
        e.emitter.update(e.emitter, delta_time)
      end

      foreach(self.orb_emitters, function(obj) obj.update(obj, delta_time) end)

      foreach(self.star_emitters, function(obj)
        obj.update(obj, delta_time)
        local t = time()
        local sway = sin(t * 0.05) * 4
        for p in all(obj.particles) do
          p.pos.x += sway * delta_time
        end
      end)
    end,

    draw = function(self)
      foreach(self.land_emitters, function(obj) obj.emitter:draw() end)
      draw_helper(self.orb_emitters)
      draw_helper(self.star_emitters)
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
      ps_set_colours(emitter, color)
      ps_set_pos(emitter, o.x+4, o.y+4)
      emitter.start_emit(emitter)
    end,

    stars = function(self)
      local front = emitter.create(64, 128, .02, 0)
      ps_set_speed(front, 2, 7)
      ps_set_area(front, 128, 30)
      ps_set_colours(front, {6, 7})
      ps_set_size(front, 0, 0, 1, 0)
      ps_set_life(front, 10, 40)
      ps_set_angle(front, 90)
      ps_set_rnd_colour(front, true)
      add(self.star_emitters, front)
    end,

    create_orb_emitters = function(self, o)
      local burst = emitter.create(-60, 64, 0, 30)
      ps_set_size(burst, 1, 0, 3, 0)
      ps_set_speed(burst, 0)
      ps_set_life(burst, .2, .5)
      ps_set_colours(burst, {7, 6, 11})
      ps_set_burst(burst, true, 20)
      ps_set_area(burst, 6, 6)
      ps_set_rnd_colour(burst, true)
      add(self.orb_emitters, burst)

      -- We have 2 orbs - create 2 emitters
      add(self.orb_emitters, burst.clone(burst))
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