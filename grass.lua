function grass_init(player, x, y)
  return {
    x = x * 8,
    y = y * 8,
    player = player,
    is_player_close = false,
    active = false,
    state = grass_animstate.still,
    step = 0,
    sp = 57,
    dir = 1,
    frame = 0,

    update = function(self)
      local old_is_player_close = self.is_player_close
      self.is_player_close = abs(self.player.x - self.x) < 2 and
         abs(self.player.y - self.y) < 2

      if old_is_player_close and not self.is_player_close and not self.active then
        self.active = true
        self.sp = self.state.start
        self.dir = 1
        self.frame = 0
        self.state = grass_animstate.rustle
      end

        if self.active and self.frame >= 12 then
          self.active = false
          self.state = grass_animstate.still
        end

        self.frame += 1
        update_frame_ping_pong(self, self.state)
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y, 1, 1)
    end,
  }
end

grass_animstate = {
  still = {
    name = "still",
    start = 57,
    per_frame = 0
  },
  rustle = {
    name = "rustle",
    start = 57,
    last = 59,
    per_frame = 3
  },
}