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
    platforms = nil,
    buttons = nil,
    background = 1,
    level = 1,

    init = function(self)
      self.player = plinit()
      self.finish_door = finish_door_init(self.player, function() self:advance_level() end)
      self.dialog_post = dialog_post_init(self.player)
      self.teleport_orb = teleport_orb_init(0, 0)
      self.clone_orb = teleport_orb_init(0, 0)
      self.platforms = {}
      self.buttons = {}
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

      -- cleanup
      self.platforms = {}
      self.dialog_post:level_set(-20, -20)

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
          local sprite_num = mget(x_coord, y_coord)
          
          local flag_val = fget(sprite_num)
          if finish_door_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.finish_door:level_set(x, y)
          elseif player_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.player:level_set(x, y, orbs, self.platforms)
          elseif dialog_post_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.dialog_post:level_set(x, y, level_data.dialog)
          elseif platform_sprite_to_direction[sprite_num] then
            mset(x_coord, y_coord, 0)
            add(self.platforms, platform_init(self.player, x, y, platform_sprite_to_direction[sprite_num]))
          end

        end
      end
      
      -- give buttons a reference to all the platforms

      -- self.player:level_set(level_data.x, level_data.y, orbs)
      self.background = level_data.background
    end,

    update = function(self)
      for platform in all(self.platforms) do
        platform:update()
      end
      self.player:update()
      self.finish_door:update()
      self.dialog_post:update()
    end,

    draw = function(self)
      cls(self.background)
      map(map_x, map_y, 0, 0, 16, 16)
      for platform in all(self.platforms) do
        platform:draw()
      end
      self.finish_door:draw()
      self.dialog_post:draw()
      self.player:draw()
    end
  }
end

-- start position is based on the 16 by 16 map 
level_start_state = {
  {
    dialog = 1,
    teleport = false,
    clone = false,
    background = 0,
  },
  {
    teleport = true,
    clone = false,
    background = 0,
  },
  {
    teleport = true,
    clone = false,
    background = 0,
  },
  {
    teleport = true,
    clone = false,
    background = 0,
  }
}