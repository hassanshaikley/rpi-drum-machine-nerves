# RPI Drum Machine Nerves

![Image of the drum machine](beat_it.png)

This is a drum machine intended to run on an RPI. I currently have tested this on a RPI 3 B+.

Last time I tried, the RPI 2 was only capable of handling 1 measure with 4 beats. It's possible that it can handle it now I just haven't gotten around to testing it.

## Local Dependencies

- afplay for local testing on a mac. If you'd like to use another library modify `lib/audio_player.ex`.

## Device Dependencies

- Official Rasberry PI 7 inch touch screen (roughly \$65 USD)
- RPI 3 ($20-$40 USD)
- headphones or speakers

# Running it locally on mac/linux

```
$> mix deps.get
$> iex -S mix
```
