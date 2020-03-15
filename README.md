# RPI Drum Machine Nerves

![Image of the drum machine](beat_it.png)

This is a drum machine intended to run on an RPI. I currently have tested this on a RPI 2 B+.

There are some known issues; it won't run with all 4 measures. It works with 1 measure due to performance constraints on the RPI 2 B+.

## Local Dependencies

- afplay for local testing on a mac. If you'd like to use another library modify `lib/audio_player.ex`.

## Device Dependencies

- Official Rasberry PI 7 inch touch screen (roughly $68 USD)
- RPI 2 or 3 ($20-$40 USD)
- headphones or speakers