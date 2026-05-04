const std = @import("std");
const log = std.log;

pub fn file_data(file_path: []u8, allocator: std.mem.Allocator, io: std.Io) ![]u8 {
    errdefer log.warn("Failed to load file data at path: {s}", .{file_path});

    var file = try std.Io.Dir.cwd().openFile(io, file_path, .{});
    defer file.close(io);

    const file_size = try file.length(io);

    const buffer = try allocator.alloc(u8, file_size);

    _ = try file.readPositionalAll(io, buffer, 0);

    return buffer;
}
