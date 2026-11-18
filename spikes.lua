function spike_init(player, x, y, sp)
  return {
    x = x * 8,
    y = y * 8,
    sp = sp,
    player = player,

    update = function(self)
      local b = spike_bounds[self.sp]
      if not b then
        return
      end

      -- spike hitbox in world space
      local sl = self.x + b.x + map_x_offset
      local st = self.y + b.y + map_y_offset
      local sr = self.x + b.x2 + map_x_offset
      local sb = self.y + b.y2 + map_y_offset

      -- player hitbox in world space
      local px = self.player.x + map_x_offset
      local py = self.player.y + map_x_offset
      local pl = px + 2
      local pr = px + 5
      local pt = py + 2
      local pb = py + 7

      -- AABB overlap
      if pl <= sr and pr >= sl and pt <= sb and pb >= st then
        self.player:respawn()
      end
    end,

    draw = function(self)
      spr(self.sp, self.x, self.y)
    end,
  }
end