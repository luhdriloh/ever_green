function clouds_init()
  return {
    clouds = {},
    light_color = 15,
    dark_color = 6,

    level_set = function(self, light_color, dark_color)
      self.clouds = {}
      self.light_color = light_color
      self.dark_color = dark_color
      local n = 3 + rnd(5)
      for i=1,n do
        add(self.clouds, {
          x = rnd(128),
          y = rnd(80),
          type = 1 + flr(rnd(3)),
          spd = 0.05 + rnd(0.25)
        })
      end
    end,

    update = function(self)
      for c in all(self.clouds) do
        c.x -= c.spd
        if c.x < -24 then c.x = 128 end
      end
    end,

    draw = function(self)
      pal(15, self.light_color)
      pal(6, self.dark_color)
      for c in all(self.clouds) do
        if c.type == 1 then
          spr(98, c.x, c.y)
          spr(99, c.x+8, c.y)
        elseif c.type == 2 then
          spr(100, c.x, c.y)
        else
          spr(98, c.x, c.y)
          spr(99, c.x+8, c.y)
          spr(100, c.x+16, c.y)
        end
      end
      pal(0)
    end
  }
end