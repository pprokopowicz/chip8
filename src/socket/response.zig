const std = @import("std");
const Address = std.net.Address;

pub const Response = struct {
    message: []u8,
    address: Address,

    pub fn new(message: []u8, address: Address) Response {
        return Response{ .message = message, .address = address };
    }
};
