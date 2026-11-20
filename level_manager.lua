-- dictates the level
--    player start
--    teleport orbs
--    moving platforms

function level_manager()
  return {
    -- set up level items
    player = nil,
    players = nil,
    orbs = nil,
    orbs_gui = nil,
    buttons = nil,
    platforms = nil,
    door = nil,
    dialog_posts = nil,
    grass = nil,
    butterflies = nil,
    spikes = nil,
    callbacks = nil,

    level = 11,
    background = 0,

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
      self.orbs_gui = orb_gui_init(self.orbs, self.player)
      clouds = clouds_init()
      particle_manager = particle_manager()
      particle_manager:init()
      -- for initializing dialog library
      dtb_init(3)
      -- initialize particle renderer
      prev_time = time()
      delta_time = time() - prev_time

      local S="1,0,0,0,0,0,5,1,2,0,0,0,0,0,5,1,3,0,0,0,0,0,5,1,4,5,1,0,0,0,5,1,0,0,0,1,0,1,14,5,0,0,0,1,0,1,14,5,0,0,0,1,0,1,14,5,0,0,0,1,0,1,14,5,6,0,0,2,0,5,6,13,0,0,0,2,0,5,6,13,0,0,0,2,0,5,6,13,7,8,2,0,0,14,15,6,4,0,0,0,1,14,15,6,0,0,0,0,2,14,15,6,0,0,0,1,1,14,15,6,0,0,0,1,1,14,15,6"
      local K={"dialog","orb_dialog","callback_index","teleport_orbs","clone_orbs","background","light_cloud","dark_cloud"}
      local T=split(S)
      local L={}
      for i=1,16 do
        local t={}
        for j=1,8 do t[K[j]]=T[(i-1)*8+j] end
        L[i]=t
      end
      level_start_state=L
    end,

    advance_level = function(self)
      self.pending_level = self.level + 1
      self.grow = 0
      self.transition = "out"
    end,

    update_transition = function(self)
      if not self.transition then return end

      if self.transition == "out" then
        self.grow += 4
        if self.grow >= 64 then
          self.transition = "text"
          self.text_frame = 0
        end
      elseif self.transition == "text" then
        self.text_frame += 1
        if self.text_frame == 30 then
          self.level = self.pending_level
          self:create_level()
          self.grow = 64
          self.transition = "in"
        end
      elseif self.transition == "in" then
        self.grow -= 4
        if self.grow <= 0 then
          self.transition = nil
        end
      end
    end,

    draw_transition = function(self)
      if not self.transition then return end
      local g = self.grow

      if self.transition == "out" or self.transition == "in" then
        rectfill(0, 0, 127, g, 0)
        rectfill(0, 127-g, 127, 127, 0)
        rectfill(0, 0, g, 127, 0)
        rectfill(127-g, 0, 127, 127, 0)
      elseif self.transition == "text" then
        rectfill(0, 0, 127, 127, 0)
        print("level " .. self.pending_level, 48, 60, 7)
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

      for i=1,level_data.teleport_orbs do
        add(self.orbs, teleport_orb_init(0, 0, self.platforms, #self.orbs+1))
      end

      add(self.players, self.player)
      for i=1, level_data.clone_orbs do
        local o = clone_orb_init(0, 0, self.platforms, #self.orbs+1)
        add(self.orbs, o)
        add(self.players, o.clone)
      end

      particle_manager.orbs = self.orbs

      -- Set map value 
      -- 8 Columns of levels in the map editor
      -- offset is pixel space
      map_x = ((self.level - 1) % 8) * 16
      map_x_offset = map_x * 8
      map_y = flr((self.level - 1) / 8) * 16
      map_y_offset = map_y * 8

      self.orbs_gui:level_set(self.orbs, self.player)
      clouds:level_set(level_data.light_cloud, level_data.dark_cloud)

      -- loop through the map space to see if we find any flags that we need to spawn
      for x=0, 15 do
        for y=0, 15 do
          local x_coord = x + map_x
          local y_coord = y + map_y
          local sprite_num = mget(x_coord, y_coord)
          
          local flag_val = fget(sprite_num)
          mset(x_coord, y_coord, 0)

          if finish_door_flag_val == flag_val then
            self.door:level_set(x, y)
          elseif player_flag_val == flag_val then
            self.player:level_set(x, y, self.orbs, self.platforms)
          elseif dialog_post_flag_val == flag_val and sprite_num == 10 then
            add(self.dialog_posts, dialog_post_init(self.player, sprite_num, x, y, level_data.dialog))
          elseif dialog_post_flag_val == flag_val then
            add(self.dialog_posts, dialog_post_init(self.player, sprite_num, x, y, level_data.orb_dialog, self.callbacks[level_data.callback_index]))
          elseif platform_dir[sprite_num] then
            add(self.platforms, platform_init(self.player, self.platforms, x, y, platform_dir[sprite_num]))
          elseif button_info[sprite_num] then
            add(self.buttons, button_init(self.players, self.platforms, x, y, button_info[sprite_num]))
          elseif grass_sprite == sprite_num then
            add(self.grass, grass_init(self.player, x, y))
          elseif butterfly_sprite == sprite_num then
            add(self.butterflies, butterfly_init(x, y))
          elseif spike_bounds[sprite_num] then
            add(self.spikes, spike_init(self.players, x, y, sprite_num))
          else
            -- if this is not rendered dynamically put the sprite back
            mset(x_coord, y_coord, sprite_num)
          end
        end
      end
      
      self.background = level_data.background
    end,

    update = function(self)
      frame += 1

      if self.transition then 
        self:update_transition()
        return
      end

      self.player:update()

      update_helper(self.buttons)
      update_helper(self.orbs)
      update_helper(self.platforms)
      update_helper(self.dialog_posts)
      update_helper(self.butterflies)
      update_helper(self.spikes)

      self.door:update()
      self.orbs_gui:update()
      clouds:update()
      particle_manager:update()
      dtb_update()
    end,

    draw = function(self)
      if self.transition == nil or self.level != 0 then
        cls(self.background)

        clouds:draw()
        particle_manager:draw()

        map(map_x, map_y, 0, 0, 16, 16, 147)
        draw_helper(self.platforms)
        draw_helper(self.dialog_posts)
        
        self.door:draw()
        self.player:draw()

        draw_helper(self.buttons)
        draw_helper(self.grass)
        draw_helper(self.orbs)
        draw_helper(self.butterflies)
        draw_helper(self.spikes)

        self.orbs_gui:draw()
        map(map_x, map_y, 0, 0, 16, 16, 8)
        dtb_draw()
      end
            
      if self.transition then 
        self:draw_transition()
      end
    end,

    -- callbacks
    add_teleport_orb = function(self)
      local orb = teleport_orb_init(0, 0, self.platforms, 1)
      orb.selected = true
      add(self.orbs, orb)
    end,

    add_clone_orb = function(self)
      local orb = clone_orb_init(0, 0, self.platforms, 1)
      orb.selected = true
      add(self.players, orb.clone)
      add(self.orbs, orb)
    end,
  }
end

-- compressed this in init to save on tokens
-- start position is based on the 16 by 16 map 
-- 0, 1, 13, 6, 14, 12
-- level_start_state = {
--   { -- 1
--     dialog = 1,
--     teleport_orbs = 0,
--     clone_orbs = 0,
--     background = 0,
--     light_cloud = 5,
--     dark_cloud = 1,
--   },
--   { -- 2
--     dialog = 2,
--     teleport_orbs = 0,
--     clone_orbs = 0,
--     background = 0,
--     light_cloud = 5,
--     dark_cloud = 1,
--   },
--   { -- 3
--     dialog = 3,
--     teleport_orbs = 0,
--     clone_orbs = 0,
--     background = 0,
--     light_cloud = 5,
--     dark_cloud = 1,
--   },
--   { -- 4
--     dialog = 4,
--     orb_dialog = 5,
--     callback_index = 1,
--     teleport_orbs = 0,
--     clone_orbs = 0,
--     background = 0,
--     light_cloud = 5,
--     dark_cloud = 1,
--   },
--   { -- 5
--     teleport_orbs = 1,
--     clone_orbs = 0,
--     background = 1,
--     light_cloud = 14,
--     dark_cloud = 5,
--   },
--   { -- 6
--     teleport_orbs = 1,
--     clone_orbs = 0,
--     background = 1,
--     light_cloud = 14,
--     dark_cloud = 5,
--   },
--   { -- 7
--     teleport_orbs = 1,
--     clone_orbs = 0,
--     background = 1,
--     light_cloud = 14,
--     dark_cloud = 5,
--   },
--   { -- 8
--     teleport_orbs = 1,
--     clone_orbs = 0,
--     background = 1,
--     light_cloud = 14,
--     dark_cloud = 5,
--   },
--   { -- 9
--     dialog = 6,
--     teleport_orbs = 2,
--     clone_orbs = 0,
--     background = 5,
--     light_cloud = 6,
--     dark_cloud = 13,
--   },
--   { -- 10
--     teleport_orbs = 2,
--     clone_orbs = 0,
--     background = 5,
--     light_cloud = 6,
--     dark_cloud = 13,
--   },
--   { -- 11
--     teleport_orbs = 2,
--     clone_orbs = 0,
--     background = 5,
--     light_cloud = 6,
--     dark_cloud = 13,
--   },
--   { -- 12
--     dialog = 7,
--     orb_dialog = 8,
--     callback_index = 2,
--     teleport_orbs = 0,
--     clone_orbs = 0,
--     background = 14,
--     light_cloud = 15,
--     dark_cloud = 6,
--   },
--   { -- 13
--     dialog = 4,
--     teleport_orbs = 0,
--     clone_orbs = 1,
--     background = 14,
--     light_cloud = 15,
--     dark_cloud = 6,
--   },
--   { -- 14
--     teleport_orbs = 0,
--     clone_orbs = 2,
--     background = 14,
--     light_cloud = 15,
--     dark_cloud = 6,
--   },
--   { -- 15
--     teleport_orbs = 1,
--     clone_orbs = 1,
--     background = 14,
--     light_cloud = 15,
--     dark_cloud = 6,
--   },
--   { -- 16
--     teleport_orbs = 1,
--     clone_orbs = 1,
--     background = 14,
--     light_cloud = 15,
--     dark_cloud = 6,
--   },
-- }