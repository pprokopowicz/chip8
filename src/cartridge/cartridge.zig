const std = @import("std");
const log = std.log;

pub fn file_data(file_path: []u8, allocator: std.mem.Allocator) ![]u8 {
    errdefer log.warn("Failed to load file data at path: {s}", .{file_path});

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);

    _ = try file.readAll(buffer);

    return buffer;
}
