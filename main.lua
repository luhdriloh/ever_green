-- main
function _init()
  -- custom color pallette 
  --  https://nerdyteachers.com/PICO-8/Palette/
  poke(0x5f2e, 1)
  pal({[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,134,15},1)

  -- Makes it so that btnp only registers once
  poke(0x5f5c, 255)

  scene = "menu"

  level_manager = level_manager()
  level_manager:init()

  menu_obj = menu()
  menu_obj:init()
end

function _update()
  if scene == "level" then
    level_manager:update()
  elseif scene == "menu" then
    menu_obj:update()
  elseif scene == "level_transition" then
  end
end

function _draw()
  if scene == "menu" then
    menu_obj:draw()
  elseif scene == "level" then
    level_manager:draw()
  end
end