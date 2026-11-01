-- utility

-- update runs 30 frames per sec
-- lets start with 10 frames a second
anim_speed = 10
jump_speed = -5
step_per_frame = 3
gravity = 12
dyupdate = gravity / 30
max_dy = 7

-- flags
solid_flag = 0
platform_stop_flag = 5
dialog_post_flag = 6
player_flag = 7

-- flag values for equality checks
platform_stop_flag_val = 32
dialog_post_flag_val = 64
player_flag_val = 128

finish_door_flag_val = 6
blue_button_flag_val = 2
red_button_flag_val = 4

-- map values
-- map_x and map_y == TILE SPACE == 1 tile is 8 PIXELS
-- TODO: rename these
map_x = 0
map_x_offset = 0
map_y = 0
map_y_offset = 0

-- map platform color to activated color
blue = 12
red = 8

-- map platform sprite -> direction
platform_sprite_to_direction = {}
platform_sprite_to_direction[34] = { dx=-1, dy=0, color=blue, sp=34 }
platform_sprite_to_direction[50] = { dx=-1, dy=0, color=red, sp=50 }

platform_sprite_to_direction[35] = { dx=0, dy=-1, color=blue, sp=35 }
platform_sprite_to_direction[51] = { dx=0, dy=-1, color=red, sp=51 }

platform_sprite_to_direction[36] = { dx=1, dy=0, color=blue, sp=36 }
platform_sprite_to_direction[52] = { dx=1, dy=0, color=red, sp=52 }

platform_sprite_to_direction[37] = { dx=-0, dy=1, color=blue, sp=37 }
platform_sprite_to_direction[53] = { dx=-0, dy=1, color=red, sp=53 }

-- button info
button_info = {}
button_info[48] = { sp=48, color=red }
button_info[32] = { sp=32, color=blue }

-- dynamically created sprites that we want to be solid
solid_spr = {}
solid_spr[34] = true
solid_spr[35] = true
solid_spr[36] = true
solid_spr[37] = true
solid_spr[50] = true
solid_spr[51] = true
solid_spr[52] = true
solid_spr[53] = true

function apply_gravity(o)
  if o.grounded then
    return
  end

  local newy = o.y + (o.dy + dyupdate)
  o.y = newy
  o.dy = min(o.dy + dyupdate, max_dy)

  -- tile-based ground
  if check_grounded(o.x + map_x_offset, o.y + map_y_offset) then
    o.dy = 0
    o.grounded = true
    while check_grounded(o.x + map_x_offset, o.y - 1 + map_y_offset) do
      o.y -= 1
    end
    return
  end

  -- dynamic ground
  for o2 in all(o.platforms) do
    if check_dynamically_grounded(o, o2) then
      o.dy = 0
      o.grounded = true
      -- snap player bottom to top of o2
      o.y = o2.y  -- min 8 to take into account the height of the player character
      return
    end
  end
end

function apply_gravity_2(o)
  if o.grounded then
    o.dy = 0
    o.grounded = check_character_grounded(o)
    return
  end

  local old_y = o.y
  o.dy = min(o.dy + dyupdate, max_dy)
  o.y = o.y + o.dy

  -- x1_offset = x1_offset or 0
  -- y1_offset = y1_offset or 2
  -- x2_offset = x2_offset or 7
  -- y2_offset = y2_offset or 7
  
  local y_dynamic_hit = false
  local y_map_hit = check_collision(o, solid_flag)
  for platform in all(o.platforms) do
    if check_dynamic_collisions(o, platform, 0, 1, 7, 8) then
      y_dynamic_hit = true
      break
    end
  end

  if y_map_hit and o.dy > 0 then
      -- tile-based ground
    if check_grounded(o.x + map_x_offset, o.y + map_y_offset) then
      o.dy = 0
      o.grounded = true
      while check_grounded(o.x + map_x_offset, o.y + map_y_offset - 1) do
        o.y -= 1
      end
    end
  elseif y_dynamic_hit and o.dy > 0 then
    o.dy = 0
    o.grounded = true
    -- snap to dynamic platform top if dynamic
    for platform in all(o.platforms) do
      if check_dynamically_grounded(o, platform) then
        -- platform:attach(o)
        o.y = platform.y - 8 -- to take account of the placement of the character sprite 8x8/
        break
      end
    end
  elseif (y_map_hit or y_dynamic_hit) and o.dy < 0 then
    o.y = old_y
    o.dy = 0 -- hit ceiling
  else
    o.grounded = check_character_grounded(o)
  end
end

function check_character_grounded(o)
  local dynamically_grounded = false
  for platform in all(o.platforms) do
    dynamically_grounded = check_dynamically_grounded(o, platform) -- update bounds here!!!! todo
  end
  
  return check_grounded(o.x + map_x_offset, o.y + map_y_offset) or dynamically_grounded
end

function check_grounded(x, y)
  local x1 = (x + 1) / 8
  local x2 = (x + 6) / 8
  local y2 = (y + 8) / 8
  local a = fget(mget(x1, y2), solid_flag)
  local b = fget(mget(x2, y2), solid_flag)

  return a or b
end

function update_frame(o, animstate)
  o.step += 1
  if animstate.per_frame == 0 then
    o.sp = animstate.start
  elseif o.step >= animstate.per_frame then
    o.step = 0
    o.sp = (o.sp + 1 - animstate.start) % (animstate.last - animstate.start + 1) + animstate.start
  end
end

function check_collision(o, flag_type, x1_offset, y1_offset, x2_offset, y2_offset)
  local x = o.x + map_x_offset
  local y = o.y + map_y_offset

  x1_offset = x1_offset or 1
  y1_offset = y1_offset or 2
  x2_offset = x2_offset or 6
  y2_offset = y2_offset or 7

  local x1 = (x + x1_offset) / 8
  local y1 = (y + y1_offset) / 8
  local x2 = (x + x2_offset) / 8
  local y2 = (y + y2_offset) / 8

  local a = fget(mget(x1, y1), flag_type)
  local c = fget(mget(x2, y1), flag_type)
  local d = fget(mget(x2, y2), flag_type)
  local b = fget(mget(x1, y2), flag_type)

  if a or b or c or d then
    return true
  else 
    return false
  end
end

function check_dynamic_collisions(o, o2, x1_offset, y1_offset, x2_offset, y2_offset)
  local x = o.x + map_x_offset
  local y = o.y + map_y_offset

  -- player hitbox (subset of the 8x8 sprite)
  x1_offset = x1_offset or 0
  y1_offset = y1_offset or 2
  x2_offset = x2_offset or 7
  y2_offset = y2_offset or 7

  local left1   = x + x1_offset
  local right1  = x + x2_offset
  local top1    = y + y1_offset
  local bottom1 = y + y2_offset

  -- o2 is a full 8x8 sprite
  local left2   = o2.x
  local right2  = o2.x + 7
  local top2    = o2.y
  local bottom2 = o2.y + 7

  -- AABB overlap: all four conditions must be true
  return left1 < right2 and right1 > left2 and top1 < bottom2 and bottom1 > top2
end

function check_dynamically_grounded(o, o2, x1_offset, x2_offset, y2_offset)
  local x = o.x + map_x_offset
  local y = o.y + map_y_offset
  local x2 = o2.x + map_x_offset
  local y2 = o2.y + map_y_offset

  x1_offset = x1_offset or 0
  x2_offset = x2_offset or 7
  y2_offset = y2_offset or 7

  -- player's hitbox bottom edge
  local bottom1 = y + y2_offset
  local top2 = y2

  if top2 > bottom1 or top2 < bottom1 - 6 then
    return false
  end

  -- horizontal overlap (same logic as check_dynamic_collisions)
  local left1  = x + x1_offset
  local right1 = x + x2_offset
  local left2  = x2
  local right2 = x2 + 7

  return left1 < right2 and right1 > left2
end