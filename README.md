# libstemmer-zig

A small Zig wrapper around the [Snowball Project](https://snowballstem.org) stemming algorithms (libstemmer.c).

### Installation

Add the package to your `build.zig.zon` file:

```bash
zig fetch --save=libstemmer https://github.com/morgangallant/libstemmer-zig/archive/<commit sha>.tar.gz
```

Then, add it to your `build.zig`:

```zig
const libstemmer = b.dependency("libstemmer", .{ .target = target, .optimize = optimize });
exe.addModule("libstemmer", libstemmer.module("libstemmer"));
```

### Usage

```zig
const libstemmer = @import("libstemmer");
const Stemmer = libstemmer.Stemmer;

var stemmer = try Stemmer.init(
    libstemmer.Language.english,
    libstemmer.Encoding.utf_8,
);
defer stemmer.deinit();

// This `output` is only valid until the next call to `stem`, or
// until the `stemmer.deinit()` is called.
const output = try stemmer.stem("running");
try std.testing.expectEqualSlices(u8, "run", output);
```

### License

Snowball is released under a 3-clause BSD license. The full license text is below, for reference.

```
Copyright (c) 2001, Dr Martin Porter,
Copyright (c) 2002, Richard Boulton.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
