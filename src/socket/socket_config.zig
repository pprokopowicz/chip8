pub const SocketConfig = struct {
    address: []const u8,
    port: u16,

    pub fn new(address: []const u8, port: u16) SocketConfig {
        return SocketConfig{
            .address = address,
            .port = port,
        };
    }
};
