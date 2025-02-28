const constant = @import("constant");

pub const DisplayConfig = struct {
    width: u32,
    height: u32,
    foreground_color: u32,
    background_color: u32,

    pub fn new(scale: u32, foreground_color: u32, background_color: u32) DisplayConfig {
        const internal_width: u32 = @intCast(constant.INTERNAL_DISPLAY_WIDTH);
        const internal_height: u32 = @intCast(constant.INTERNAL_DISPLAY_HEIGHT);

        return DisplayConfig{
            .width = internal_width * scale,
            .height = internal_height * scale,
            .foreground_color = foreground_color,
            .background_color = background_color,
        };
    }
};
