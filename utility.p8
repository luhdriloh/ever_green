-- utility

-- update runs 30 frames per sec
-- lets start with 10 frames a second
anim_speed = 10
jump_speed = -5
step_per_frame = 3
gravity = 12
dyupdate = gravity / 30
max_dy = 10

-- flags
solid_flag = 0
dialog_post_flag = 6
player_flag = 7

-- flag values for equality checks
dialog_post_flag_val = 64
player_flag_val = 128

finish_door_flag_val = 6
blue_button_flag_val = 2
red_button_flag_val = 4

left_red_platform_flag_val = 3 + 24
up_red_platform_flag_val = 3 + 8
right_red_platform_flag_val = 3
down_red_platform_flag_val = 3 + 16

left_blue_platform_flag_val = 5 + 24
up_blue_platform_flag_val = 5 + 8
right_blue_platform_flag_val = 5
down_blue_platform_flag_val = 5 + 16

-- map values
map_x = 0
map_x_offset = 0
map_y = 0
map_y_offset = 0

function apply_gravity(o)
  if o.grounded then
    return
  end

  local newy = o.y + (o.dy + dyupdate)
  o.y = newy
  o.dy = min(o.dy + dyupdate, max_dy)

  if check_grounded(o.x + map_x_offset, o.y + map_y_offset) then
    o.dy = 0
    o.grounded = true
  end

  while check_grounded(o.x + map_x_offset, o.y - 1 + map_y_offset) do
    o.y -= 1
  end
end

function check_character_grounded(o)
  return check_grounded(o.x + map_x_offset, o.y + map_y_offset)
end

function check_grounded(x, y)
  local y2 = (y + 8) / 8
  local x1 = (x + 2) / 8
  local x2 = (x + 6) / 8
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

function check_collision(o, flag_type)
  local x = o.x + map_x_offset
  local y = o.y + map_y_offset

  local x1 = (x + 2) / 8
  local y1 = (y + 2) / 8
  local x2 = (x + 6) / 8
  local y2 = (y + 7) / 8

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