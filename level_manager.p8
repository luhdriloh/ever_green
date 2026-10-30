-- dictates the level
--    player start
--    teleport orbs
--    moving platforms

function level_manager()
  return {
    player = nil,
    finish_door = nil,
    dialog_post = nil,
    teleport_orb = nil,
    clone_orb = nil,
    background = 1,
    level = 1,

    init = function(self)
      self.player = plinit()
      self.finish_door = finish_door_init(self.player, function() self:advance_level() end)
      self.dialog_post = dialog_post_init(self.player)
      self.teleport_orb = teleport_orb_init(0, 0)
      self.clone_orb = teleport_orb_init(0, 0)
    end,

    advance_level = function(self)
      self.level += 1
      self:create_level()
    end,

    create_level = function(self)
      local level_data = level_start_state[self.level]
      local orbs = {}
      if level_data.teleport then
        add(orbs, self.teleport_orb)
      end

      if level_data.clone then
        add(orbs, self.clone_orb)
      end

      -- Set map value 
      -- 8 Columns of levels in the map editor
      map_x = ((self.level - 1) % 8) * 16
      map_x_offset = map_x * 8
      map_y = flr((self.level - 1) / 8) * 16
      map_y_offset = map_y * 8

      -- loop through the map space to see if we find any flags that we need to spawn
      for x=0, 15 do
        for y=0, 15 do
          local x_coord = x + map_x
          local y_coord = y + map_y
          local t = mget(x_coord, y_coord)
          
          local flag_val = fget(t)
          if finish_door_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.finish_door:level_set(x, y)
          elseif player_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.player:level_set(x, y, orbs)
          elseif dialog_post_flag == flag_val then
            self.dialog_post:level_set(x, y, level_data.dialog)
          end

        end
      end
      
      -- self.player:level_set(level_data.x, level_data.y, orbs)
      self.background = level_data.background
    end,

    update = function(self)
      self.player:update()
      self.finish_door:update()
      self.dialog_post:update()
    end,

    draw = function(self)
      cls(self.background)
      map(map_x, map_y, 0, 0, 16, 16)
      self.player:draw()
      self.finish_door:draw()
      self.dialog_post:update()
    end
  }
end

-- start position is based on the 16 by 16 map 
level_start_state = {
  {
    x = 2,
    y = 11,
    dialog = 1,
    heart_x = 15,
    heart_y = 11,
    teleport = false,
    clone = false,
    background = 0,
  },
  {
    x = 1,
    y = 11,
    heart_x = 15,
    heart_y = 3,
    teleport = true,
    clone = false,
    background = 0,
  },
  {
    x = 1,
    y = 7,
    heart_x = 13,
    heart_y = 8,
    teleport = true,
    clone = false,
    background = 0,
  },
  {
    x = 32,
    y = 13,
    heart_x = 45,
    heart_y = 13,
    teleport = true,
    clone = false,
    background = 0,
  }
}