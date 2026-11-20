-- main
function _init()
  -- custom color pallette 
  --  https://nerdyteachers.com/PICO-8/Palette/
  poke(0x5f2e, 1)
  pal({[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,134,15},1)

  -- Makes it so that btnp only registers once
  poke(0x5f5c, 255)
  
  -- set global to indicate scene
  scene = 'level'

  level_manager = level_manager()
  level_manager:init()
  level_manager:advance_level()
end

function _update()
  if scene == 'level' then
    level_manager:update()
  elseif scene == 'menu' then
  elseif scene == 'level_transition' then
  end
end

function _draw()
  if scene == 'menu' then
  elseif scene == 'level' then
    level_manager:draw()
  end
end