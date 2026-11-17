function particle_manager_init()
  return {
    run_emitters = {},

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
    end,

    draw = function(self)
      foreach(self.run_emitters, function(obj) obj.emitter:draw() end)
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

    create_running_emitter = function(self, player)
      local front = emitter.create(player.x, player.y+7, 0.3, 0)
      local angle = player.flx and 100 or 35

      ps_set_colours(front, {3, 11, 7})
      ps_set_size(front, 1, 0, 1, 0)
      ps_set_life(front, .2, .4)
      ps_set_angle(front, angle, 35)
      ps_set_speed(front, 25, 10, 10, 15)
      ps_set_gravity(front, true)
      return front
    end,

  }
end