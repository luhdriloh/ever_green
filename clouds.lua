function clouds_init()
  -- return {
  --   -- init
  --   clouds = {},

  --   level_set = function(self)
  --     self.clouds = {}

  --     local cloud_num = 1 + rnd(4)
  --     for i=1,cloud_num do
  --       add(self.clouds, {
  --         x = rnd(160),
  --         y = 8 + rnd(60),
  --         w = 16 + rnd(24),
  --         spd = 0.05 + rnd(0.25)
  --       })
  --     end
  --   end,

  --   update = function(self)
  --     for c in all(self.clouds) do
  --       c.x -= c.spd
  --       if c.x + c.w < 0 then
  --         c.x = 128 + rnd(32)
  --         c.y = 8 + rnd(40)
  --         c.w = 16 + rnd(24)
  --       end
  --     end
  --   end,

  --   draw = function(self)
  --     for c in all(self.clouds) do
  --       local sx = flr(c.x)
  --       local r = c.w / 3
  --       circfill(sx, c.y, r, 13)
  --       circfill(sx + r, c.y - r/2, r*0.8, 13)
  --       circfill(sx + r*2, c.y, r*0.7, 13)
  --     end
  --   end,
  -- }

  return {
    clouds = {},
    level_set = function(self)
      self.clouds = {}
      local n = 3 + rnd(5)
      for i=1,n do
        add(self.clouds, {
          x = rnd(128),
          y = rnd(90),
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
    end
  }
end