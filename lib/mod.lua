-- lib/mod.lua
local mod = require 'core/mods'

-- State to keep things the mod needs
local state = {
  is_waiting = false,
  is_running = false,
  tempo_increment = 1,
  current_tempo = 120,
  pending_midi_start = false,
}

local m = {}

local function send_midi_start()
  if params:string("clock_source") ~= "link" then return end

  for i = 1,16 do
    if norns.state.clock.midi_out[i] == 1 then
      -- Send to this midi port
      midi.vports[i]:start()
    end
  end
end

local function send_midi_stop()
  if params:string("clock_source") ~= "link" then return end
  for i = 1,16 do
    if norns.state.clock.midi_out[i] == 1 then
      -- Send to this midi port
      midi.vports[i]:stop()
    end
  end
end

-- Hook into system startup to initialize
mod.hook.register("system_post_startup", "clocker post startup", function()
end)

-- Hook into script initialization
mod.hook.register("script_post_init", "clocker script post init", function()
  local old_start = clock.transport.start
  local old_stop = clock.transport.stop
  clock.transport.start = function()
    m.on_start()
    if old_start then old_start() end
  end
  clock.transport.stop = function()
    m.on_stop()
    if old_stop then old_stop() end
  end
end)

-- Function to start the transport
m.on_start = function()
  if not state.is_running then
    clock.run(m.wait_for_quantum)
  end
end

m.wait_for_quantum = function() 
  state.pending_midi_start = true -- Send MIDI Start at next bar
  clock.sync(norns.state.clock.link_quantum)
  state.is_running = true
  state.pending_midi_start = false
  send_midi_start()
end

-- Function to stop the transport
m.on_stop = function()
  if state.is_running then
    state.is_running = false
    send_midi_stop()
  end
end

m.init = function()
end

m.deinit = function()
end

-- Register the MOD menu
-- mod.menu.register(mod.this_name, m)

-- API to expose the MOD's state if needed
local api = {}

api.get_state = function()
  return state
end

return api
