const std = @import("std");
const Allocator = std.mem.Allocator;

fn isPrefix(a: []const u8, b: []const u8) bool {
    if (a.len < b.len) return false;
    for (0..b.len) |i| if (a[i] != b[i]) return false;
    return true;
}

fn getMinSize(comptime len: usize) type {
    if (len == 0) return u0;
    return switch (std.math.log2_int_ceil(usize, len - 1)) {
        1...8 => u8,
        9...16 => u16,
        17...32 => u32,
        33...64 => u64,
        else => usize,
    };
}

fn createEnum(comptime T: type) type {
    const tFields = std.meta.fields(T);
    var fields: [tFields.len]std.builtin.Type.EnumField = undefined;

    for (0..tFields.len) |i| {
        fields[i] = .{
            .name = tFields[i].name,
            .value = i,
        };
    }

    return @Type(.{
        .Enum = .{
            .tag_type = getMinSize(tFields.len),
            .fields = &fields,
            .decls = &[0]std.builtin.Type.Declaration{},
            .is_exhaustive = true,
        },
    });
}

pub fn createToken(comptime T: type) type {
    const tFields = std.meta.fields(T);
    var fields: [tFields.len]std.builtin.Type.UnionField = undefined;

    for (0..tFields.len) |i| {
        const fieldType = switch (tFields[i].type) {
            fn ([]const u8) usize => []const u8,
            fn (u8) bool, []const u8, u8 => void,
            else => unreachable,
        };

        fields[i] = .{
            .name = tFields[i].name,
            .type = fieldType,
            .alignment = 0,
        };
    }

    return @Type(.{
        .Union = .{
            .layout = .Auto,
            .tag_type = createEnum(T),
            .fields = &fields,
            .decls = &[0]std.builtin.Type.Declaration{},
        },
    });
}

pub fn lex(comptime T: type, allocator: Allocator, input: []const u8) ![]createToken(T) {
    const Token = createToken(T);
    var tokens = try allocator.alloc(Token, 0);
    var i: usize = 0;

    chars: while (i < input.len) {
        inline for (std.meta.fields(T)) |field| {
            const value = if (field.default_value) |default_value|
                @ptrCast(*const field.type, @alignCast(field.alignment, default_value)).*
            else
                unreachable;

            var matched: bool = true;
            var len: usize = undefined;
            var token: Token = undefined;
            if (field.type == fn ([]const u8) usize and value(input[i..]) != 0) {
                len = value(input[i..]);
                token = @unionInit(Token, field.name, input[i .. i + len]);
            } else if (field.type == fn (u8) bool and value(input[i])) {
                len = 1;
                token = @unionInit(Token, field.name, undefined);
            } else if (field.type == []const u8 and isPrefix(input[i..], value)) {
                len = value.len;
                token = @unionInit(Token, field.name, undefined);
            } else if (field.type == u8 and input[i] == value) {
                len = 1;
                token = @unionInit(Token, field.name, undefined);
            } else matched = false;

            if (matched) {
                tokens = try allocator.realloc(tokens, tokens.len + 1);
                tokens[tokens.len - 1] = token;

                i += len;
                continue :chars;
            }
        }

        unreachable;
    }

    return tokens;
}
