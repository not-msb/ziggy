const std = @import("std");

pub fn tokenize(comptime T: type, input: []const u8) void {
    var i: usize = 0;

    while (i < input.len) : (i += 1) {
        inline for (std.meta.fields(T)) |field| {
            //const aligned_value = @alignCast(field.alignment, default_value);
            //const value = @ptrCast(*const field.type, aligned_value);
            const value = if (field.default_value) |default_value|
                @ptrCast(*const field.type, @alignCast(field.alignment, default_value)).*
            else
                unreachable;

            switch (field.type) {
                fn ([]const u8) usize => {
                    const len = value(input[i..]);
                    if (len != 0) {
                        std.debug.print("{s} = \'{d}\'\n", .{ field.name, len });
                        i += len - 1;
                    }
                },
                fn (u8) bool => if (value(input[i])) {
                    std.debug.print("{s} = \'{c}\'\n", .{ field.name, input[i] });
                },
                u8 => if (input[i] == value) {
                    std.debug.print("{s} = \'{c}\'\n", .{ field.name, input[i] });
                },
                else => unreachable,
            }
        }
    }
}
