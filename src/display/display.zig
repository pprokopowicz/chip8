const sdl = @import("sdl");
const constant = @import("constant");
const std = @import("std");
const log = std.log;

const WINDOW_NAME = "Chip8";
const TEXTURE_WIDTH = constant.INTERNAL_DISPLAY_WIDTH;
const TEXTURE_HEIGHT = constant.INTERNAL_DISPLAY_HEIGHT;

const DisplayError = @import("display_error.zig").DisplayError;
pub const DisplayConfig = @import("display_config.zig").DisplayConfig;

pub const Display = struct {
    config: DisplayConfig,
    window: ?*sdl.Window,
    renderer: ?*sdl.Renderer,
    texture: ?*sdl.Texture,

    pub fn new(config: DisplayConfig) !Display {
        sdl.set_main_ready();

        const window = try new_window(config);
        errdefer sdl.destroy_window(window);

        const renderer = try new_renderer(window);
        errdefer sdl.destroy_renderer(renderer);

        const texture = try new_texture(renderer);
        errdefer sdl.destroy_texture(texture);

        log.info("New Display initialized!", .{});

        return Display{
            .config = config,
            .window = window,
            .renderer = renderer,
            .texture = texture,
        };
    }

    fn new_window(config: DisplayConfig) !?*sdl.Window {
        const window = sdl.create_window(WINDOW_NAME, config.width, config.height, 0);

        if (window == null) {
            const err = sdl.get_error();
            log.warn("Failed to create window with error: {s}", .{err});
            return DisplayError.FailedToCreateWindow;
        }

        return window;
    }

    fn new_renderer(window: ?*sdl.Window) !?*sdl.Renderer {
        const renderer = sdl.create_renderer(window, null);

        if (renderer == null) {
            const err = sdl.get_error();
            log.warn("Failed to create renderer with error: {s}", .{err});
            return DisplayError.FailedToCreateRenderer;
        }

        return renderer;
    }

    fn new_texture(renderer: ?*sdl.Renderer) ![*c]sdl.Texture {
        const texture = sdl.create_texture(renderer, sdl.PixelFormat.rgba8888, sdl.TextureAccess.streaming, TEXTURE_WIDTH, TEXTURE_HEIGHT);

        if (texture == null) {
            const err = sdl.get_error();
            log.warn("Failed to create texture with error: {s}", .{err});
            return DisplayError.FailedToCreateTexture;
        }

        _ = sdl.set_texture_scale_mode(texture, sdl.ScaleMode.nearest);

        return texture;
    }

    pub fn quit(self: Display) void {
        sdl.destroy_texture(self.texture);
        sdl.destroy_texture(self.texture);
        sdl.destroy_window(self.window);
    }

    pub fn render(self: Display, vram: []u1) void {
        _ = sdl.render_clear(self.renderer);

        self.buildTexture(vram);

        const width: f32 = @floatFromInt(self.config.width);
        const height: f32 = @floatFromInt(self.config.height);
        var dest = sdl.FloatRect{ .x = 0, .y = 0, .w = width, .h = height };

        _ = sdl.render_texture(self.renderer, self.texture, null, &dest);
        _ = sdl.render_present(self.renderer);
    }

    fn buildTexture(self: Display, vram: []u1) void {
        var pixels: ?[*]u32 = null;
        var pitch: u32 = 0;

        _ = sdl.lock_texture(self.texture, null, &pixels, &pitch);

        var y: usize = 0;
        while (y < TEXTURE_HEIGHT) : (y += 1) {
            var x: usize = 0;
            while (x < TEXTURE_WIDTH) : (x += 1) {
                if (vram[y * TEXTURE_WIDTH + x] == 1) {
                    pixels.?[y * TEXTURE_WIDTH + x] = self.config.foreground_color;
                } else {
                    pixels.?[y * TEXTURE_WIDTH + x] = self.config.background_color;
                }
            }
        }
        sdl.unlock_texture(self.texture);
    }
};
