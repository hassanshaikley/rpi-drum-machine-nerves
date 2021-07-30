# To Do

- Review the code
- Create benchmarks you want to run on the RPI (just bc they're faster on my machine doesn't mean they will be faster on the PI)

## Questions
- Are there more performany architectures ?
  - It is a simple app but would using a different, maybe more multithreaded, architecture be desirable
- Is there a more readable way to write scenic code?
- Are there ways we can use Streams?
- Can we make Scenic more performant?


## Benchmarks:
- See if tails recursion is faster on the PI
- Look for methods that copy 
- Cache result of bpm_to_ms with metaprogramming during compile time and see if that is faster
- Would using a process for each instrument be faster? It kind of feels wrong

- Encode iteration row changed from returning strings or use macro to generate the functions
- Need to run the benchmarks on the PI itself
- Note that we don't care about memory

