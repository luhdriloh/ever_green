-- main
function _init()
  -- custom color pallette 
  --  https://nerdyteachers.com/PICO-8/Palette/
  -- poke(0x5f2e,1)
  -- pal({[0]=0,1,-11,3,4,5,6,7,-8,-7,-6,11,12,13,14,15},1)

  level_manager = level_manager()
  level_manager:init()
  level_manager:create_level()
end

function _update()
  level_manager:update()
end

function _draw()
  level_manager:draw()
end