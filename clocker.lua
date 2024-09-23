-- clocker v0.0.2
-- @thorinside
--
-- llllllll.co/t/clocker
--
--
--
--    ▼ instructions below ▼
--
-- E1: Adjust Tempo
-- K2: Start
-- K3: Stop

local beatclock = require 'beatclock'
local clk = beatclock.new()
local midi_device
local screen_refresh_metro

local beats_per_bar = 4 -- Assuming 4/4 time signature
local is_waiting = false
local is_running = false
local current_tempo = 120 -- Default tempo
local tempo_increment = 1

local system_font

function init()
  local font_lookup = tab.invert(screen.font_face_names)
  system_font = font_lookup["norns"] or font_lookup["04B_03__"]
  
  -- Add clock parameters
  clk:add_clock_params()

  -- Set the clock source to Link
  params:set("clock_source", 3) -- Adjust index if necessary

  -- Initialize MIDI device
  midi_device = midi.connect(1) -- Adjust as needed

  -- Get the current tempo from parameters
  current_tempo = params:get("clock_tempo")

  -- Start a metro to refresh the screen
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    redraw()
  end
  screen_refresh_metro:start(1/15) -- Refresh 15 times per second
  
  -- Stop Link for now
  clock.link.stop()
end

function clock.transport.start()
  clk:start()
  on_start()
end

function clock.transport.stop()
  on_stop()
end

function on_start()
  is_running = true
  is_waiting = true
  redraw()
  start_midi_at_next_bar()
end

function on_stop()
  is_running = false
  midi_device:send({0xFC}) -- MIDI Stop
  clk:stop()
  is_waiting = false
  redraw()
end

function start_midi_at_next_bar()
  clock.run(function()
    -- Get the current beat phase
    local current_beat = (clk.beat - 1) % beats_per_bar
    local beats_to_next_bar = beats_per_bar - current_beat

    if beats_to_next_bar == 0 then
      beats_to_next_bar = beats_per_bar
    end

    -- Wait until the next bar
    clock.sync(beats_to_next_bar)

    -- Send MIDI Start message
    midi_device:send({0xFA}) -- MIDI Start

    -- Reset and start the clock
    clk:reset()
    clk:start()

    is_waiting = false
    redraw()
  end)
end

function key(n, z)
  if z == 1 then -- Key pressed
    if n == 2 then -- Start transport
      clock.link.start()
    elseif n == 3 then -- Stop transport
      clock.link.stop()
    end
  end
end

function enc(n, d)
  if n == 1 then -- Encoder 1 adjusts tempo
    -- Adjust current_tempo by tempo_increment increments
    current_tempo = util.clamp(current_tempo + d * tempo_increment, 20, 300)
    -- Set the new tempo
    params:set("clock_tempo", current_tempo)
    -- Redraw the screen to update tempo display
    redraw()
  end
end

function redraw()
  screen.font_face(system_font)
  screen.clear()
  screen.move(64, 20)
  screen.text_center("Clocker")

  -- Display transport status
  screen.move(64, 32)
  if is_waiting then
    screen.text_center("Starting at next bar...")
  else
    if is_running then
      screen.text_center("Transport Running")
    else
      screen.text_center("Transport Stopped")
    end
  end

  -- Display current tempo
  screen.move(64, 44)
  screen.text_center("Tempo: " .. string.format("%.2f", params:get("clock_tempo")))

  screen.update()
end
