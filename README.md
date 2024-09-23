# Clocker

By @thorinside

 
## Introduction

This script will help you start and stop MIDI instruments along side Ableton Link devices,
allowing Norms to be used as a clocking service of sorts. Operation is simple:

- Put Norns on the same Wifi network as other Ableton Link supporting software
- In Edit > Clock, enable Link, set tempo if desired, enable Midi Clock on desired midi channel
- Start the clock by pressing E2 or start another Link device
- Stop the clock by pressing E3 or stop the other Link device

Midi Start and Stop messages will be sent. Start will be given one bar after the ableton link
start is detected. Stop will be immediate.