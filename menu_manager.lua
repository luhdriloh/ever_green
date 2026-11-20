function menu()
  local m = {}
  m.items = {"start", "level select", "how to play"}
  m.selected = 0
  m.x_wobble = 0
  m.player_sp = 16
  m.butterflies = {}
  m.tab = 0          -- 0=main, 1=level select, 2=how to play
  m.level_sel = 0   -- selected level (0-15)

  -- box layout
  m.top_y = 32
  m.box_x = 36
  m.box_y = 40
  m.box_w = 56
  m.box_h = 24

  -- level grid layout (inside the box)
  m.lvl_cell_w = 11
  m.lvl_cell_h = 11

  function m:init()
    self.selected = 0
    self.tab = 0
    self.level_sel = 0
    for i=1,(2+rnd(4)) do
      add(self.butterflies, butterfly_init(1+rnd(14), 1+rnd(12)))
    end
    clouds:level_set(5, 1)
  end

  function m:update()
    frame += 1

    -- always update background
    clouds:update()
    particle_manager:update()
    update_helper(self.butterflies)
    if frame % 9 == 0 then
      self.player_sp = (self.player_sp + 1) % 2 + 16
    end

    -- tab-specific input
    if self.tab == 0 then
      if btnp(2) then
        self.selected = (self.selected - 1) % #self.items
      elseif btnp(3) then
        self.selected = (self.selected + 1) % #self.items
      elseif btnp(5) then
        if self.selected == 0 then
          scene = "level"
          level_manager:advance_level(true)
        elseif self.selected == 1 then
          self.tab = 1
          self.level_sel = 0
        elseif self.selected == 2 then
          self.tab = 2
        end
      end
    elseif self.tab == 1 then
      if btnp(0) and self.level_sel % 8 > 0 then
        self.level_sel -= 1
      elseif btnp(1) and self.level_sel % 8 < 7 then
        self.level_sel += 1
      elseif btnp(2) and self.level_sel >= 8 then
        self.level_sel -= 8
      elseif btnp(3) and self.level_sel < 8 then
        self.level_sel += 8
      elseif btnp(4) then
        self.tab = 0
      elseif btnp(5) then
        scene = "level"
        level_manager:advance_level(true, self.level_sel)
      end
    elseif self.tab == 2 then
      if btnp(4) then
        self.tab = 0
      end
    end
  end

  function m:draw()
    cls(0)
    clouds:draw()
    particle_manager:draw()

    -- trees
    spr(85, 94, 11*8, 3, 3)
    spr(11, 102, 13*8)

    -- character
    spr(self.player_sp, 18, 13*8, 1, 1, true)

    draw_helper(self.butterflies)

    -- scatter sprites
    foreach({37, 57, 111}, function(x) spr(45, x, 13 * 8) end)
    foreach({3, 68}, function(x) spr(57, x, 13 * 8) end)

    -- ground
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
    print("❎select 🅾️back", bx-2, by + 45, 7)

    -- tab-specific box content
    if self.tab == 0 then
      self:draw_main_box(bx, by, bw, bh)
    elseif self.tab == 1 then
      self:draw_level_box(by)
    elseif self.tab == 2 then
      self:draw_howto_box(bx, by, bw, bh)
    end
  end

  function m:draw_main_box(bx, by, bw, bh)
    local item_h = 8
    local start_y = by + 2
    rectfill(bx, by, bx+bw, by+bh, 1)
    rect(bx, by, bx+bw, by+bh, 7)

    for i, text in ipairs(self.items) do
      local y = start_y + (i-1) * item_h
      -- center the text
      local tx = bx + (bw + 2 - #text*4) / 2
      local color = 7
      if i - 1 == self.selected then
        rectfill(bx+1, y-1, bx+bw-1, y+5, 7)
        color = 1
      end
      print(text, tx, y, color)
    end
  end

  function m:draw_level_box(by)
    local cw, ch = self.lvl_cell_w, self.lvl_cell_h

    -- draw the overall big box
    local box_w = 8 * cw
    local box_x = (128 - box_w) / 2
    rectfill(box_x-1, by-1, box_x+box_w+1, by+1+ch*2, 1)
    rect(box_x-1, by-1, box_x+box_w+1, by+1+ch*2, 7)


    for i = 0, 15 do
      local col = i % 8
      local row = flr(i / 8)


      local x = box_x + col * cw
      local y = by + row * ch
      
      local num = tostring(i + 1)
      local tx = x + (cw - #num * 3) / 2
      tx = #num == 2 and tx+1 or tx 

      local color = 7
      if i == self.level_sel then
        rectfill(x, y, x+cw, y+ch, 7)
        color = 1
      end
      print(num, tx, y+3, color)
    end
  end

  function m:draw_howto_box(bx, by, bw, bh)
    rectfill(bx-24, by-3, bx+82, by+32, 1)
    rect(bx-24, by-3, bx+82, by+32, 7)

    print(" ❎  jump\n 🅾️  use power orb\n⬅️➡️ move\n ⬇️  cycle power orbs\n ⬆️  hold to respawn\n", bx-20, by, 7)
  end

  return m
end
