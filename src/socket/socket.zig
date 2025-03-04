const std = @import("std");
const log = std.log;
const net = std.net;
const posix = std.posix;
const Response = @import("response.zig").Response;

pub const SocketConfig = @import("socket_config.zig").SocketConfig;

pub const Socket = struct {
    config: SocketConfig,
    address: std.net.Address,
    socket: posix.socket_t,

    pub fn new(config: SocketConfig) !Socket {
        const parsed_address = try std.net.Address.parseIp4(config.address, config.port);
        const sock = try posix.socket(posix.AF.INET, posix.SOCK.DGRAM, 0);

        errdefer posix.close(sock);

        return Socket{ .config = config, .address = parsed_address, .socket = sock };
    }

    pub fn bind(self: *Socket) !void {
        try posix.bind(self.socket, &self.address.any, self.address.getOsSockLen());
    }

    pub fn send(self: *Socket, message: []const u8, address: *net.Address) !usize {
        return try posix.sendto(
            self.socket,
            message,
            0,
            &address.any,
            address.getOsSockLen(),
        );
    }

    pub fn receive(self: *Socket, buf_len: comptime_int) !Response {
        var buffer: [buf_len]u8 = undefined;

        var client_address: std.posix.sockaddr = undefined;
        var client_address_length: std.posix.socklen_t = undefined;

        log.info("Waiting for data on port {}", .{self.config.port});

        const len = try posix.recvfrom(
            self.socket,
            buffer[0..],
            0,
            &client_address,
            &client_address_length,
        );

        const message = buffer[0..len];
        const net_client_address = net.Address.initPosix(@alignCast(&client_address));

        return Response.new(message, net_client_address);
    }

    pub fn close(self: *Socket) void {
        posix.close(self.socket);
    }
};
