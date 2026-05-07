const sdl = @import("sdl");
const constant = @import("constant");
const std = @import("std");
const log = std.log;

const WINDOW_NAME = "Chip8";
const TEXTURE_WIDTH = constant.INTERNAL_DISPLAY_WIDTH;
const TEXTURE_HEIGHT = constant.INTERNAL_DISPLAY_HEIGHT;

const DisplayError = @import("display_error.zig").DisplayError;
const RenderError = @import("display_error.zig").RenderError;
pub const DisplayConfig = @import("display_config.zig").DisplayConfig;

pub const Display = struct {
    config: DisplayConfig,
    window: ?*sdl.Window,
    renderer: ?*sdl.Renderer,
    texture: ?*sdl.Texture,

    pub fn new(config: DisplayConfig) !Display {
        sdl.setMainReady();

        const window = try newWindow(config);
        errdefer sdl.destroyWindow(window);

        const renderer = try newRenderer(window);
        errdefer sdl.destroyRenderer(renderer);

        const texture = try newTexture(renderer);
        errdefer sdl.destroyTexture(texture);

        log.info("New Display initialized!", .{});

        return Display{
            .config = config,
            .window = window,
            .renderer = renderer,
            .texture = texture,
        };
    }

    fn newWindow(config: DisplayConfig) !?*sdl.Window {
        const window = sdl.createWindow(WINDOW_NAME, config.width, config.height, 0);

        if (window == null) {
            const err = sdl.getError();
            log.warn("Failed to create window with error: {s}", .{err});
            return DisplayError.FailedToCreateWindow;
        }

        return window;
    }

    fn newRenderer(window: ?*sdl.Window) !?*sdl.Renderer {
        const renderer = sdl.createRenderer(window, null);

        if (renderer == null) {
            const err = sdl.getError();
            log.warn("Failed to create renderer with error: {s}", .{err});
            return DisplayError.FailedToCreateRenderer;
        }

        return renderer;
    }

    fn newTexture(renderer: ?*sdl.Renderer) ![*c]sdl.Texture {
        const texture = sdl.createTexture(renderer, sdl.PixelFormat.rgba8888, sdl.TextureAccess.streaming, TEXTURE_WIDTH, TEXTURE_HEIGHT);

        if (texture == null) {
            const err = sdl.getError();
            log.warn("Failed to create texture with error: {s}", .{err});
            return DisplayError.FailedToCreateTexture;
        }

        _ = sdl.setTextureScaleMode(texture, sdl.ScaleMode.nearest);

        return texture;
    }

    pub fn quit(self: Display) void {
        sdl.destroyTexture(self.texture);
        sdl.destroyRenderer(self.renderer);
        sdl.destroyWindow(self.window);
    }

    pub fn render(self: Display, vram: []u1) !void {
        const is_clear_success = sdl.renderClear(self.renderer);
        if (!is_clear_success) {
            const err = sdl.getError();
            log.warn("Failed to clear renderer with error: {s}", .{err});
            return RenderError.FailedToClearRenderer;
        }

        try self.buildTexture(vram);

        const width: f32 = @floatFromInt(self.config.width);
        const height: f32 = @floatFromInt(self.config.height);
        var dest = sdl.FloatRect{ .x = 0, .y = 0, .w = width, .h = height };

        const is_render_success = sdl.renderTexture(self.renderer, self.texture, null, &dest);
        if (!is_render_success) {
            const err = sdl.getError();
            log.warn("Failed to render texture with error: {s}", .{err});
            return RenderError.FailedToRenderTexture;
        }

        const is_present_success = sdl.renderPresent(self.renderer);
        if (!is_present_success) {
            const err = sdl.getError();
            log.warn("Failed to present renderer with error: {s}", .{err});
            return RenderError.FailedToPresentRenderer;
        }
    }

    fn buildTexture(self: Display, vram: []u1) !void {
        var pixels: ?[*]u32 = null;
        var pitch: u32 = 0;

        const is_success = sdl.lockTexture(self.texture, null, &pixels, &pitch);
        if (!is_success) {
            const err = sdl.getError();
            log.warn("Failed to lock texture with error: {s}", .{err});
            return RenderError.FailedToLockTexture;
        }

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
        sdl.unlockTexture(self.texture);
    }
};
