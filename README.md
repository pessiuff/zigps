
# Growtopia Private Server in Zig

A side project focused on implementing a GTPS in Zig. It was developed for Linux on a Linux system and might not work on Windows if I decide to use platform dependent code. If you're on Windows, you should use WSL.


## Installation

- Install Zig (preferably v0.15.2).
- ```git clone https://github.com/pessiuff/zig_gtps.git```
- (Optional) Compile ENet yourself and place it into ```c_lib```. There is a pre-compiled version inside but I don't recommend using any precompiled executable or library.
- Run ```./build_run.sh``` in the ```zig_gtps``` directory.
