pub const AudioConfig = struct {
    is_muted: bool,

    pub fn new(is_muted: bool) AudioConfig {
        return AudioConfig{
            .is_muted = is_muted,
        };
    }
};
