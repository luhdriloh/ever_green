function menu()
  local m = {}
  m.items = {"start", "level select", "how to play"}
  m.selected = 0
  m.x_wobble = 0

  -- box layout
  m.top_y = 32
  m.box_x = 36
  m.box_y = 40
  m.box_w = 56
  m.box_h = 24

  function m:init()
    self.selected = 0
    clouds:level_set(5, 1)
  end

  function m:update()
    frame += 1
    if btnp(2) then
      self.selected = (self.selected - 1) % #self.items
    elseif btnp(3) then
      self.selected = (self.selected + 1) % #self.items
    elseif btnp(5) then
      if self.selected == 0 then
        scene = "level"
        level_manager:advance_level()
      elseif self.selected == 1 then
        -- TODO: level select
      elseif self.selected == 2 then
        -- TODO: how to play
      end
    end
      
    clouds:update()
    particle_manager:update()
  end

  function m:draw()
    cls(0)
    clouds:draw()
    particle_manager:draw()

    -- y == 13: stratified scatter
    local flowers = {37, 57, 103}
    for i = 1, #flowers do
      spr(45, flowers[i], 13 * 8)
    end

    for x = 0, 15 do
      for y = 0, 15 do
        local x_pos = x * 8
        local y_pos = y * 8
        if y == 15 then
          spr(55, x_pos, y_pos)
        elseif y == 14 then
          spr(40, x_pos, y_pos)
        end
      end
    end


    -- title
    self.x_wobble = sin(frame * 0.02) * 2
    spr(72, 32, 20 + self.x_wobble, 64, 32)

    -- box border
    local bx, by, bw, bh = self.box_x, self.box_y+self.top_y, self.box_w, self.box_h
    rectfill(bx, by, bx+bw, by+bh, 1)

    -- menu items
    local item_h = 8
    local start_y = by + 2
    for i, text in ipairs(self.items) do
      local y = start_y + (i-1) * item_h
      local tx = bx + (bw + 2 - #text*4) / 2 
      if i - 1 == self.selected then
        -- highlight bar (inverted)
        rectfill(bx+1, y-1, bx+bw-1, y+5, 7)
        
        print(text, tx, y, 1)
      else
        print(text, tx, y, 7)
      end
    end
  end

  return m
end