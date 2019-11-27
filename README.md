Readme text goes here


From template

# Dependencies

- afplay
- Optimziing : http://learningelixir.joekain.com/optimizing-elixir-posts/


## MIDI

[WAtch this playlist]
https://www.youtube.com/watch?v=0L7WAMFWSgY&list=PL4_gPbvyebyH2xfPXePHtx8gK5zPBrVkg

- First part is the status byte
    - Frist number is the command
        8 note off
        9 note on
        A aftertouch
        B control change
        C program change
        D channel pressure
        E pitch blend
    - Second numbver is the channel
        0-F which is 16 channels, for many keyboards you gotta add 1 to the channel (so 0-16)
        
- Second part is one or more data bytes
        Can represent key number, velocity or position of pitch bend
    - Leftmost (highest ) bit is always 0 - this limits number from 0 - 7F (0-127)

Questions: What is the velocity of a sound?


## Sound

Pitch - how high / low a sound is
Frequnecy - the rate of a vibration
     How often it completes a cycle (one sin wave)
     (commonly Hz - hertz - full cycles per one second)
     High a has double the frequncy of the lower A (an octave is double above or half below i think)
     Frequency of A0-A8
        27.5
        55.0
        110.0
        220.0
        440.0
        880.0
        1760.0
        3520.0
        7040.0

        Every octave has 12 pitches

        TO FIND B4
            1/12 = .083 
            
            .083 * 2 = .166
            y = 27.5(2)^4.166
            y = 493.88 Hz


            To find C4
            .249
            27.5*(2)^4.249 -> 522 ?

            https://pages.mtu.edu/~suits/notefreqs.html

    ## Still need to figure out how to get at least 1 XLR input

    Some people suggest https://focusrite.com/usb-audio-interface/scarlett/scarlett-solo but nothing for elixir specifically
   https://www.amazon.com/PreSonus-AudioBox-USB-96-Interface/dp/B06ZZCR6P4?psc=1&SubscriptionId=AKIAJUWNRSEGZOYYBKJQ&tag=omacro0c-20&linkCode=xm2&camp=2025&creative=165953&creativeASIN=B06ZZCR6P4

XLR is the name of the cable 


To get the frequency of audio may need https://en.wikipedia.org/wiki/Fourier_transform



# Optimization

https://github.com/devonestes/fast-elixir#map-lookup-vs-pattern-matching-lookup-code