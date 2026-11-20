function grass_init(player, x, y)
  return {
    x = x * 8,
    y = y * 8,
    flx = rnd(10) > 5 and true or false,

    draw = function(self)
      spr(self.sp, self.x, self.y, 1, 1, self.flx)
    end,
  }
end
