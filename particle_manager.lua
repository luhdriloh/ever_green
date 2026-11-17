function particle_manager_init()
  return {
    run_emitters = {},
    star_emitters = {},

    level_set = function(self)
    end,

    update = function(self)
      -- update time for ps particle library
      update_time()
      for e in all(self.run_emitters) do
        local x_pos = e.player.flx and e.player.x + 1 or e.player.x + 7
        local angle = e.player.flx and 100 or 35

        ps_set_pos(e.emitter, x_pos, e.player.y+7)
        ps_set_angle(e.emitter, angle, 45)
        e.emitter.update(e.emitter, delta_time)
      end

      foreach(self.star_emitters, function(obj) obj.update(obj, delta_time) end)
    end,

    draw = function(self)
      foreach(self.run_emitters, function(obj) obj.emitter:draw() end)
      foreach(self.star_emitters, function(obj) obj:draw() end)
    end,

    -- set up emitter for when the player is running
    run = function(self, player, state)
      local emitter_for_player = nil
      for e in all(self.run_emitters) do
        if e.player == player then
          emitter_for_player = e.emitter
          break
        end
      end

      if emitter_for_player == nil and state then
        local run_emitter = self:create_running_emitter(player)
        add(self.run_emitters, {player=player, emitter=run_emitter})
      elseif emitter_for_player != nil and state then
        emitter_for_player.start_emit(emitter_for_player)
      elseif emitter_for_player != nil and not state then
        emitter_for_player.stop_emit(emitter_for_player)
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

    create_running_emitter = function(self, player)
      local front = emitter.create(player.x, player.y+7, 0.25, 0)
      local angle = player.flx and 100 or 35

      ps_set_colours(front, {7})
      ps_set_size(front, 1, 0, 1, 0)
      ps_set_speed(front, 20, 10, 10, 10)
      ps_set_gravity(front, true)
      return front
    end,

  }
end