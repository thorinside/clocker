# Clocker Mod

By @thorinside

 
## Introduction

This mod will help you start and stop MIDI instruments along side Ableton Link devices,
allowing Norms to be used as a clocking service of sorts. Operation is simple:

- Put Norns on the same Wifi network as other Ableton Link supporting software
- In Edit > Clock, enable Link, set tempo if desired, enable Midi Clock on desired midi channel(s)
- Once you are running a script, you will find a 'clocker' section in the params where you can toggle the transport
- You can also set up a param mapping to allow you to toggle the transport more easily

Midi Start and Stop messages will be sent. Start will be given one bar after the Ableton Link
start is detected. Stop will be immediate.