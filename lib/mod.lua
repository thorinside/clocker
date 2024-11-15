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

local clocker = {}

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

local function add_params()
      params:add_separator("clocker")
      params:add_binary("clocker_link_toggle", "Toggle Transport", "toggle", 0)
      params:set_action("clocker_link_toggle",function(x)
          local source = params:string("clock_source")
          if x == 0 then
                if source == "internal" then clock.internal.stop()
                elseif source == "link" then clock.link.stop() end
          elseif x == 1 then
                if source == "internal" then clock.internal.start()
                elseif source == "link" then clock.link.start() end
          end
      end)
end

-- Hook into script initialization
mod.hook.register("script_pre_init", "clocker script pre init", function()
  add_params()
end)

mod.hook.register("script_post_init", "clocker script post init", function()
  local old_start = clock.transport.start
  local old_stop = clock.transport.stop
  clock.transport.start = function()
    clocker.on_start()
    if old_start then old_start() end
  end
  clock.transport.stop = function()
    clocker.on_stop()
    if old_stop then old_stop() end
  end
end)

-- Function to start the transport
clocker.on_start = function()
  params:set("clocker_link_toggle", 1)
  if not state.is_running then
    clock.run(clocker.wait_for_quantum)
  end
end

clocker.wait_for_quantum = function() 
  state.pending_midi_start = true -- Send MIDI Start at next bar
  clock.sync(norns.state.clock.link_quantum)
  state.is_running = true
  state.pending_midi_start = false
  send_midi_start()
end

-- Function to stop the transport
clocker.on_stop = function()
  params:set("clocker_link_toggle", 0)
  if state.is_running then
    state.is_running = false
    send_midi_stop()
  end
end

return clocker