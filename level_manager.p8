-- dictates the level
--    player start
--    teleport orbs
--    moving platforms

function level_manager()
  return {
    player = nil,
    finish_door = nil,
    dialog_post = nil,
    orbs = nil,
    equipment_gui = nil,
    platforms = nil,
    buttons = nil,
    background = 1,
    level = 1,

    init = function(self)
      self.player = plinit()
      self.finish_door = finish_door_init(self.player, function() self:advance_level() end)
      self.dialog_post = dialog_post_init(self.player)
      self.equipment_gui = equipment_gui_init(self.orbs)
    end,

    advance_level = function(self)
      self.level += 1
      self:create_level()
    end,

    create_level = function(self)
      -- cleanup
      self.buttons = {}
      self.platforms = {}
      self.orbs = {}
      self.dialog_post:level_set(-20, -20)

      local level_data = level_start_state[self.level]

      for i=1, level_data.teleport_orbs do
        new_orb = teleport_orb_init(0, 0, self.platforms)
        add(self.orbs, new_orb)
      end

      local players = { self.player }
      for i=1, level_data.clone_orbs do
        new_orb = clone_orb_init(0, 0, self.platforms)
        add(players, new_orb.clone)
        add(self.orbs, new_orb)
      end

      -- Set map value 
      -- 8 Columns of levels in the map editor
      -- offset is pixel space
      map_x = ((self.level - 1) % 8) * 16
      map_x_offset = map_x * 8
      map_y = flr((self.level - 1) / 8) * 16
      map_y_offset = map_y * 8

      self.equipment_gui:set_orbs(self.orbs)

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
            self.player:level_set(x, y, self.orbs, self.platforms)
          elseif dialog_post_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.dialog_post:level_set(x, y, level_data.dialog)
          elseif platform_sprite_to_direction[sprite_num] then
            mset(x_coord, y_coord, 0)
            add(self.platforms, platform_init(self.player, self.platforms, x, y, platform_sprite_to_direction[sprite_num]))
          elseif button_info[sprite_num] then
            mset(x_coord, y_coord, 0)
            add(self.buttons, button_init(players, self.platforms, x, y, button_info[sprite_num]))
          end
        end
      end
      
      -- give buttons a reference to all the platforms

      -- self.player:level_set(level_data.x, level_data.y, orbs)
      self.background = level_data.background
    end,

    update = function(self)
      for button in all(self.buttons) do
        button:update()
      end

      self.player:update()

      for orb in all(self.orbs) do
        orb:update()
      end

      for platform in all(self.platforms) do
        platform:update()
      end

      self.finish_door:update()
      self.dialog_post:update()
      self.equipment_gui:update()
    end,

    draw = function(self)
      cls(self.background)
      map(map_x, map_y, 0, 0, 16, 16, 147)
      for platform in all(self.platforms) do
        platform:draw()
      end

      for button in all(self.buttons) do
        button:draw()
      end

      self.finish_door:draw()
      self.dialog_post:draw()
      self.equipment_gui:draw()

      for orb in all(self.orbs) do
        orb:draw()
      end

      self.player:draw()
      map(map_x, map_y, 0, 0, 16, 16, 8)
    end
  }
end

-- start position is based on the 16 by 16 map 
level_start_state = {
  {
    dialog = 1,
    teleport_orbs = 2,
    clone_orbs = 0,
    background = 0,
  },
  {
    teleport_orbs = 1,
    clone_orbs = 0,
    background = 0,
  },
  {
    teleport_orbs = 1,
    clone_orbs = 0,
    background = 0,
  },
  {
    teleport_orbs = 1,
    clone_orbs = 0,
    background = 0,
  },
  {
    teleport_orbs = 1,
    clone_orbs = 0,
    background = 0,
  },
    {
    teleport_orbs = 1,
    clone_orbs = 0,
    background = 0,
  },
}