const std = @import("std");
const libstemmer = @cImport({
    @cInclude("libstemmer.h");
});

pub const Encoding = enum {
    utf_8,
    iso_8859_1,
    iso_8859_2,
    koi8_r,

    fn c_name(self: Encoding) [*c]const u8 {
        switch (self) {
            .utf_8 => return "UTF_8",
            .iso_8859_1 => return "ISO_8859_1",
            .iso_8859_2 => return "ISO_8859_2",
            .koi8_r => return "KOI8_R",
        }
    }
};

pub const Language = enum {
    arabic,
    armenian,
    basque,
    catalan,
    danish,
    dutch,
    english,
    finnish,
    french,
    german,
    greek,
    hindi,
    hungarian,
    indonesian,
    irish,
    italian,
    lithuanian,
    nepali,
    norwegian,
    porter,
    portuguese,
    romanian,
    russian,
    serbian,
    spanish,
    swedish,
    tamil,
    turkish,
    yiddish,

    fn c_name(self: Language) [*c]const u8 {
        switch (self) {
            .arabic => return "arabic",
            .armenian => return "armenian",
            .basque => return "basque",
            .catalan => return "catalan",
            .danish => return "danish",
            .dutch => return "dutch",
            .english => return "english",
            .finnish => return "finnish",
            .french => return "french",
            .german => return "german",
            .greek => return "greek",
            .hindi => return "hindi",
            .hungarian => return "hungarian",
            .indonesian => return "indonesian",
            .irish => return "irish",
            .italian => return "italian",
            .lithuanian => return "lithuanian",
            .nepali => return "nepali",
            .norwegian => return "norwegian",
            .porter => return "porter",
            .portuguese => return "portuguese",
            .romanian => return "romanian",
            .russian => return "russian",
            .serbian => return "serbian",
            .spanish => return "spanish",
            .swedish => return "swedish",
            .tamil => return "tamil",
            .turkish => return "turkish",
            .yiddish => return "yiddish",
        }
    }
};

// Note: Stemmers are heavy-weight objects; it's recommended to create one, use it for a
// large volume of work, and then delete it.
pub const Stemmer = struct {
    stemmer: ?*libstemmer.sb_stemmer,

    pub fn init(language: Language, encoding: Encoding) !Stemmer {
        const stemmer = libstemmer.sb_stemmer_new(language.c_name(), encoding.c_name());
        if (stemmer == null) {
            return error.StemmerInitFailed; // Out of memory or invalid language/encoding pair
        }
        return .{ .stemmer = stemmer };
    }

    pub fn deinit(self: *Stemmer) void {
        if (self.stemmer) |stemmer| {
            libstemmer.sb_stemmer_delete(stemmer);
        }
    }

    // Stem a word. The word must be in the encoding specified when the stemmer was created,
    // and must be lowercased (i.e. 'A'...'Z' are not allowed; asserted).
    //
    // Warning: This might allocate! The returned string is only valid until
    // the next call to stem, or until the stemmer is deleted.
    pub fn stem(self: *Stemmer, word: []const u8) error{OutOfMemory}![]const u8 {
        std.debug.assert(isLowercase(word));
        const result = libstemmer.sb_stemmer_stem(
            self.stemmer,
            @as([*c]libstemmer.sb_symbol, @ptrCast(@constCast(word.ptr))),
            @intCast(word.len),
        );
        if (result == null) return error.OutOfMemory;
        const length = @as(usize, @intCast(libstemmer.sb_stemmer_length(self.stemmer)));
        return result[0..length];
    }

    fn isLowercase(input: []const u8) bool {
        for (input) |c| {
            switch (c) {
                'A'...'Z' => return false,
                else => {},
            }
        }
        return true;
    }
};

fn testStemmerAgainst(
    stemmer: *Stemmer,
    expected_pairs: []const struct { []const u8, []const u8 },
) !void {
    for (expected_pairs) |pair| {
        const stemmed = try stemmer.stem(pair.@"0");
        try std.testing.expectEqualSlices(u8, pair.@"1", stemmed);
    }
}

test "english" {
    var stemmer = try Stemmer.init(Language.english, Encoding.utf_8);
    defer stemmer.deinit();

    try testStemmerAgainst(&stemmer, &.{
        .{ "consignment", "consign" },
        .{ "consistency", "consist" },
        .{ "kneaded", "knead" },
        .{ "fly", "fli" },
        .{ "knightsbridge", "knightsbridg" },
    });
}

test "french" {
    var stemmer = try Stemmer.init(Language.french, Encoding.utf_8);
    defer stemmer.deinit();

    try testStemmerAgainst(&stemmer, &.{
        .{ "continuellement", "continuel" },
        .{ "contournant", "contourn" },
        .{ "contradictoirement", "contradictoir" },
    });
}
