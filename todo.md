This is my list of things of to do 

* particles
* clone ball code
* sign_post code
* butterfly code
* overlay of the orb being used
* moving blocks
* switches



The most common and scalable pattern in PICO-8 is a factory + entity table approach combined with map scanning for placement. Here's how it typically works:

1. Define a spawn/factory function
Instead of hardcoding each object, use a function that creates a table with all the properties you need:

mobs = {}

function add_mob(x, y, typ)
  local m = {x=x, y=y, typ=typ, hp=3, spd=0.5, state="idle"}
  add(mobs, m)
end

Each entry in mobs is a self-contained "entity" — position, sprite type, speed, health, state, whatever your game needs.

2. Scan the map on level load
The standard trick: place special sprites in the map editor, then use sprite flags (fget) to mark them as spawn points. On level load, iterate the map, find them, spawn entities, and erase the tile:

function load_level()
  mobs = {}
  for x in all(16) do
    for y in all(16) do
      local t = mget(x, y)
      if fget(t, 0) then       -- flag 0 = "enemy spawn"
        add_mob(x*8, y*8, t)   -- tile number = mob type
        mset(x, y, 0)          -- erase from map
      end
      if fget(t, 1) then       -- flag 1 = "item spawn"
        add_item(x*8, y*8)
        mset(x, y, 0)
      end
    end
  end
end

This way you design levels visually in the map editor — just paint in the sprites where you want things to appear.  The game reads them at runtime.

3. Update & draw each frame
function _update()
  for m in all(mobs) do
    update_mob(m)  -- movement, AI, state transitions
  end
end

function _draw()
  for m in all(mobs) do
    spr(m.sprite, m.x, m.y, m.flip)
  end
end

4. Per-entity behavior (state machine)
For each mob, a simple state field drives its logic:

function update_mob(m)
  if m.state == "idle" then
    m.timer += 1
    if m.timer > 60 then
      m.state = "patrol"
      m.dir = rnd() < 0.5 and 1 or -1
    end
  elseif m.state == "patrol" then
    m.x += m.spd * m.dir
    if m.x < 16 or m.x > 112 then m.dir = -m.dir end
    -- check if player is nearby → switch to "chase"
  elseif m.state == "chase" then
    -- move toward player
  end
end

Key tips
mget/fget/mset is the backbone of level-driven spawning — it keeps your level data in the map editor instead of hardcoded coordinates.
One table per category (mobs, items, bullets) keeps iteration fast and logic clean.
Kill entities by removing from the table (del(mobs, m)) when they die or leave the screen.
If you have many levels, a stage_init(stage_num) function that calls load_level() and resets player state is the standard structure.
This "scan map → populate tables → iterate tables each frame" pattern is what most PICO-8 games use and scales well even within the token limit.