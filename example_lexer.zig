const std = @import("std");
const tools = @import("tools.zig");
const cwd = std.fs.cwd();

const MEMORY = 8192;

const Foo = struct {
    comptime whitespace: fn(u8) bool = std.ascii.isWhitespace,
    comptime let: []const u8 = "let",
    comptime equal: u8 = '=',
    comptime semicolon: u8 = ';',
    comptime integer: fn(u8) bool = std.ascii.isDigit,
    comptime identifier: fn(u8) bool = std.ascii.isAlphabetic,
};

const Token = tools.createToken(Foo);

fn filter(token: Token) bool {
    return token != Token.whitespace;
}

pub fn main() !void {
    var buffer: [MEMORY]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const file = try cwd.openFile("input.nor", .{});
    const input = try file.readToEndAlloc(allocator, MEMORY);
    var tokens = try tools.lex(Foo, allocator, input);
    tokens = try tools.filter(Token, allocator, tokens, filter);

    for (tokens) |token| {
        switch (token) {
            .whitespace => std.debug.print("Token.whitespace\n", .{}),
            .integer => std.debug.print("Token.integer\n", .{}),
            .identifier => std.debug.print("Token.identifier\n", .{}),
            .let => std.debug.print("Token.let\n", .{}),
            .equal => std.debug.print("Token.equal\n", .{}),
            .semicolon => std.debug.print("Token.semicolon\n", .{}),
        }
    }
}
