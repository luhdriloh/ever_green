-- dictates the level
--    player start
--    teleport orbs
--    moving platforms

function level_manager()
  return {
    player = nil,
    players = nil,
    door = nil,
    dialog_posts = nil,
    orbs = nil,
    equipment_gui = nil,
    platforms = nil,
    buttons = nil,
    grass = nil,
    background = 0,
    level = 1,
    clouds = {},
    butterflies = {},
    spikes = {},
    callbacks = {},
    transition = nil,
    trans_frame = 0,
    wipe_x = 0,
    wipe_dir = 1,
    show_text = false,
    text_frame = 0,
    pending_level = nil,
    grow = 0,

    init = function(self)
      self.callbacks = {
        function() self:add_teleport_orb() end,
        function() self:add_clone_orb() end
      }
      self.player = plinit()
      self.door = finish_door_init(self.player, function() self:advance_level() end)
      self.equipment_gui = equipment_gui_init(self.orbs, self.player)
      self.clouds = clouds_init()
      particle_manager = particle_manager()
      particle_manager:init()
      particle_manager:stars()
      -- for initializing dialog library
      dtb_init(3)
      -- initialize particle renderer
      prev_time = time()
      delta_time = time() - prev_time
    end,

    advance_level = function(self)
      self.pending_level = self.level + 1
      self.grow = 0
      self.transition = "out"
    end,

    update_transition = function(self)
      if not self.transition then return end

      local x = self.door.x + 4
      local y = self.door.y + 4
      local max_grow = max(max(x, 127-x), max(y, 127-y))

      if self.transition == "out" then
        self.grow += 4
        if self.grow >= max_grow then
          self.transition = "text"
          self.text_frame = 0
        end
      elseif self.transition == "text" then
        self.text_frame += 1
        if self.text_frame == 30 then
          self.level = self.pending_level
          self:create_level()
          self.grow = 0
          self.transition = "in"
        end
      elseif self.transition == "in" then
        self.grow += 4
        if self.grow >= max_grow then
          self.transition = nil
        end
      end
    end,

    draw_transition = function(self)
      if not self.transition then return end
      local x = self.door.x
      local y = self.door.y

      if self.transition == "out" then
        rectfill(x - self.grow, y - self.grow, x + self.grow, y + self.grow, 0)
      elseif self.transition == "text" then
        rectfill(0, 0, 127, 127, 0)
        print("level " .. self.pending_level, 48, 60, 15)
      elseif self.transition == "in" then
        local max_grow = max(max(x, 127-x), max(y, 127-y))
        local g = max_grow - self.grow
        rectfill(x - g, y - g, x + g, y + g, 0)
      end
    end,

    create_level = function(self)
      -- cleanup
      self.buttons = {}
      self.platforms = {}
      self.orbs = {}
      self.dialog_posts = {}
      self.grass = {}
      self.butterflies = {}
      self.spikes = {}
      self.players = {}

      local level_data = level_start_state[self.level]
      local count = 1

      for i=1, level_data.teleport_orbs do
        local new_orb = teleport_orb_init(0, 0, self.platforms, count)
        count += 1
        add(self.orbs, new_orb)
      end

      add(self.players, self.player)
      for i=1, level_data.clone_orbs do
        local new_orb = clone_orb_init(0, 0, self.platforms, count)
        count += 1
        add(self.players, new_orb.clone)
        add(self.orbs, new_orb)
      end

      particle_manager.orbs = self.orbs

      -- Set map value 
      -- 8 Columns of levels in the map editor
      -- offset is pixel space
      map_x = ((self.level - 1) % 8) * 16
      map_x_offset = map_x * 8
      map_y = flr((self.level - 1) / 8) * 16
      map_y_offset = map_y * 8

      self.equipment_gui:level_set(self.orbs, self.player)
      self.clouds:level_set()

      -- loop through the map space to see if we find any flags that we need to spawn
      for x=0, 15 do
        for y=0, 15 do
          local x_coord = x + map_x
          local y_coord = y + map_y
          local sprite_num = mget(x_coord, y_coord)
          
          local flag_val = fget(sprite_num)
          if finish_door_flag_val == flag_val then
            mset(x_coord, y_coord, 0)
            self.door:level_set(x, y)
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
            add(self.buttons, button_init(self.players, self.platforms, x, y, button_info[sprite_num]))
          elseif grass_sprite == sprite_num then
            mset(x_coord, y_coord, 0)
            add(self.grass, grass_init(self.player, x, y))
          elseif butterfly_sprite == sprite_num then
            mset(x_coord, y_coord, 0)
            add(self.butterflies, butterfly_init(x, y))
          elseif spike_bounds[sprite_num] then
            mset(x_coord, y_coord, 0)
            add(self.spikes, spike_init(self.player, x, y, sprite_num))
          end
        end
      end
      
      -- give buttons a reference to all the platforms

      -- self.player:level_set(level_data.x, level_data.y, orbs)
      self.background = level_data.background
    end,

    update = function(self)
      frame += 1

      if self.transition then 
        self:update_transition()
        return
      end


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

      for g in all(self.grass) do
        g:update()
      end

      foreach(self.butterflies, function(butterfly) butterfly:update() end)
      foreach(self.spikes, function(spike) spike:update() end)
      self.door:update()
      self.equipment_gui:update()
      self.clouds:update()
      particle_manager:update()
      dtb_update()
    end,

    draw = function(self)
      cls(self.background)

      self.clouds:draw()
      particle_manager:draw()

      map(map_x, map_y, 0, 0, 16, 16, 147)

      for platform in all(self.platforms) do
        platform:draw()
      end

      for button in all(self.buttons) do
        button:draw()
      end

      self.door:draw()
      
      for dialog_post in all(self.dialog_posts) do
        dialog_post:draw()
      end

      self.player:draw()

      for g in all(self.grass) do
        g:draw()
      end

      for orb in all(self.orbs) do
        orb:draw()
      end

      foreach(self.butterflies, function(butterfly) butterfly:draw() end)
      foreach(self.spikes, function(spike) spike:draw() end)

      self.equipment_gui:draw()
      map(map_x, map_y, 0, 0, 16, 16, 8)
      dtb_draw()
            
      if self.transition then 
        self:draw_transition()
      end
    end,

    -- callbacks
    add_teleport_orb = function(self)
      local new_orb = teleport_orb_init(0, 0, self.platforms, 1)
      new_orb.selected = true
      add(self.orbs, new_orb)
    end,

    add_clone_orb = function(self)
      local new_orb = clone_orb_init(0, 0, self.platforms, 1)
      new_orb.selected = true
      add(self.players, new_orb.clone)
      add(self.orbs, new_orb)
    end,
  }
end

-- start position is based on the 16 by 16 map 
level_start_state = {
  {
    dialog = 1,
    teleport_orbs = 1,
    clone_orbs = 1,
    background = 1,
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
  { -- 9
    dialog = 6,
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
    dialog = 7,
    orb_dialog = 8,
    callback_index = 2,
    teleport_orbs = 0,
    clone_orbs = 0,
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