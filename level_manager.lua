-- dictates the level
--    player start
--    teleport orbs
--    moving platforms

function level_manager()
  return {
    player = nil,
    finish_door = nil,
    dialog_posts = nil,
    orbs = nil,
    equipment_gui = nil,
    platforms = nil,
    buttons = nil,
    background = 1,
    level = 1,
    callbacks = {},

    init = function(self)
      self.callbacks = {
        function() self:add_teleport_orb() end
      }
      self.player = plinit()
      self.finish_door = finish_door_init(self.player, function() self:advance_level() end)
      self.equipment_gui = equipment_gui_init(self.orbs, self.player)
      particle_manager = particle_manager_init()
      -- for initializing dialog library
      dtb_init(3)
      -- initialize particle renderer
      prev_time = time()
      delta_time = time() - prev_time
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
      self.dialog_posts = {}

      local level_data = level_start_state[self.level]

      for i=1, level_data.teleport_orbs do
        local new_orb = teleport_orb_init(0, 0, self.platforms)
        add(self.orbs, new_orb)
      end

      local players = { self.player }
      for i=1, level_data.clone_orbs do
        local new_orb = clone_orb_init(0, 0, self.platforms)
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

      self.equipment_gui:level_set(self.orbs, self.player)

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
          elseif dialog_post_flag_val == flag_val and sprite_num == 10 then
            mset(x_coord, y_coord, 0)
            add(self.dialog_posts, dialog_post_init(self.player, sprite_num, x, y, level_data.dialog))
          elseif dialog_post_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            add(self.dialog_posts, dialog_post_init(self.player, sprite_num, x, y, level_data.orb_dialog, self.callbacks[level_data.callback_index]))
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
      frame += 1
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

      for dialog_post in all(self.dialog_posts) do
        dialog_post:update()
      end

      self.finish_door:update()
      self.equipment_gui:update()
      particle_manager:update()
      dtb_update()
    end,

    draw = function(self)
      cls(self.background)
      for platform in all(self.platforms) do
        platform:draw()
      end

      for button in all(self.buttons) do
        button:draw()
      end

      self.finish_door:draw()
      
      for dialog_post in all(self.dialog_posts) do
        dialog_post:draw()
      end

      particle_manager:draw()
      map(map_x, map_y, 0, 0, 16, 16, 147)

      self.player:draw()

      for orb in all(self.orbs) do
        orb:draw()
      end
      self.equipment_gui:draw()
      map(map_x, map_y, 0, 0, 16, 16, 8)
      dtb_draw()
    end,

        -- callbacks
    add_teleport_orb = function(self)
      local new_orb = teleport_orb_init(0, 0, self.platforms)
      new_orb.selected = true
      add(self.orbs, new_orb)
    end,
  }
end

-- start position is based on the 16 by 16 map 
level_start_state = {
  {
    dialog = 1,
    teleport_orbs = 0,
    clone_orbs = 0,
    background = 0,
  },
  {
    dialog = 2,
    teleport_orbs = 0,
    clone_orbs = 0,
    background = 0,
  },
  {
    dialog = 3,
    teleport_orbs = 0,
    clone_orbs = 0,
    background = 0,
  },
  {
    dialog = 4,
    orb_dialog = 5,
    callback_index = 1,
    teleport_orbs = 0,
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
    teleport_orbs = 2,
    clone_orbs = 0,
    background = 0,
  },
  { -- 10
    teleport_orbs = 2,
    clone_orbs = 0,
    background = 0,
  },
  { -- 11
    teleport_orbs = 2,
    clone_orbs = 0,
    background = 0,
  },
  { -- 12
    dialog = 3,
    teleport_orbs = 0,
    clone_orbs = 1,
    background = 0,
  },
  { -- 13
    dialog = 4,
    teleport_orbs = 0,
    clone_orbs = 1,
    background = 0,
  },
  { -- 14
    teleport_orbs = 0,
    clone_orbs = 2,
    background = 0,
  },
  { -- 15
    teleport_orbs = 1,
    clone_orbs = 1,
    background = 0,
  },
  { -- 16
    teleport_orbs = 1,
    clone_orbs = 1,
    background = 0,
  },
}