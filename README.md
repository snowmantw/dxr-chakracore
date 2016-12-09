
## How ?

### Prerequisites:

1. Docker installed
2. ChakraCore cloned

### Run it

1. Clone the repo with `--recursive` option: `git clone --recursive https://github.com/snowmantw/dxr-chakracore.git`
2. Change working directory to it
3. `./build.sh <path to ChakraCore directory>`

It should automatically run things inside [the patched DXR][1] with two additional `CXX` and `CC` wrappers copied into the `ChakraCore` directory.

The wrappers are necessary to pass DXR flags to the building process of `ChakraCore`.

### Note

The whole building and indexing process will take about 1 hour to finish.

Also, because some mysterious Clang segmentation failure during compilation,
the `ChakraCore` cannot be built as debugging build. The root cause should be [DXR's Clang plugin][2].



## Why ?

I like to have a Web-based codebase so I can search it and share what I found easily.

GitHub code search is too simple, at least for users a premium. 

Besides that, I always want to test how open and easy to use Mozilla's **open source** softwares for other projects not by Mozilla.
Since I believe it is nonsense to claim you embrace open source but your code or libraries or softwares are so fragile and tricky to be used in others' projects.

[1]: https://github.com/snowmantw/dxr/pull/1/files
[2]: https://github.com/mozilla/dxr/blob/9e7abb09ce4995cb436ef9bee20484aff204a1e3/dxr/plugins/clang/dxr-index.cpp
