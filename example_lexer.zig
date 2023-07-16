const std = @import("std");
const lexer = @import("lexer.zig");

fn is_star(byte: u8) bool {
    return byte == '*';
}

fn is_slash(byte: u8) bool {
    return byte == '/';
}

fn is_word(bytes: []const u8) usize {
    var i: usize = 0;
    while (i < bytes.len and std.ascii.isAlphabetic(bytes[i])) : (i += 1) {}
    return i;
}

const Foo = struct {
    comptime plus: u8 = '+',
    comptime minus: u8 = '-',
    comptime star: fn(u8) bool = is_star,
    comptime slash: fn(u8) bool = is_slash,
    comptime word: fn([]const u8) usize = is_word,
};

pub fn main() void {
    lexer.tokenize(Foo, "2//+*+-+*+---//word");
}
