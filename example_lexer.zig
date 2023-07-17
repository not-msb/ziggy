const std = @import("std");
const lexer = @import("lexer.zig");
const cwd = std.fs.cwd();

const MEMORY = 8192;

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
    comptime whitespace: fn(u8) bool = std.ascii.isWhitespace,
    comptime plus: u8 = '+',
    comptime minus: u8 = '-',
    comptime star: fn(u8) bool = is_star,
    comptime slash: fn(u8) bool = is_slash,
    comptime keyword: []const u8 = "key",
    comptime word: fn([]const u8) usize = is_word,
};

pub fn main() !void {
    var buffer: [MEMORY]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const file = try cwd.openFile("input.nor", .{});
    const input = try file.readToEndAlloc(allocator, MEMORY);
    const tokens = try lexer.lex(Foo, allocator, input);

    for (tokens) |token| {
        switch (token) {
            .whitespace => std.debug.print("Token.whitespace\n", .{}),
            .plus => std.debug.print("Token.plus\n", .{}),
            .minus => std.debug.print("Token.minus\n", .{}),
            .star => std.debug.print("Token.star\n", .{}),
            .slash => std.debug.print("Token.slash\n", .{}),
            .keyword => std.debug.print("Token.keyword\n", .{}),
            .word => |word| std.debug.print("Token.word: \"{s}\"\n", .{ word }),
        }
    }
}
