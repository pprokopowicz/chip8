const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});
const constant = @import("constant");
const std = @import("std");
const log = std.log;

const WINDOW_WIDTH = constant.DISPLAY_WIDTH;
const WINDOW_HEIGHT = constant.DISPLAY_HEIGHT;
const WINDOW_NAME = "Chip8";
const TEXTURE_WIDTH = constant.INTERNAL_DISPLAY_WIDTH;
const TEXTURE_HEIGHT = constant.INTERNAL_DISPLAY_HEIGHT;

const DisplayError = @import("display_error.zig").DisplayError;
pub const DisplayEvent = @import("display_event.zig").DisplayEvent;

pub const Display = struct {
    window: ?*sdl.struct_SDL_Window,
    renderer: ?*sdl.struct_SDL_Renderer,
    texture: [*c]sdl.struct_SDL_Texture,

    pub fn new() !Display {
        sdl.SDL_SetMainReady();

        try initialize();
        errdefer sdl.SDL_Quit();

        const window = try new_window();
        errdefer sdl.SDL_DestroyWindow(window);

        const renderer = try new_renderer(window);
        errdefer sdl.SDL_DestroyRenderer(renderer);

        const texture = try new_texture(renderer);
        errdefer sdl.SDL_DestroyTexture(texture);

        log.info("New Display initialized!", .{});

        return Display{
            .window = window,
            .renderer = renderer,
            .texture = texture,
        };
    }

    fn initialize() !void {
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
            const err = sdl.SDL_GetError();
            log.info("Failed to initialize with error: {s}", .{err});
            return DisplayError.FailedToInitialize;
        }
    }

    fn new_window() !?*sdl.struct_SDL_Window {
        const window = sdl.SDL_CreateWindow(WINDOW_NAME, WINDOW_WIDTH, WINDOW_HEIGHT, 0);

        if (window == null) {
            const err = sdl.SDL_GetError();
            log.info("Failed to create window with error: {s}", .{err});
            return DisplayError.FailedToCreateWindow;
        }

        return window;
    }

    fn new_renderer(window: ?*sdl.struct_SDL_Window) !?*sdl.struct_SDL_Renderer {
        const renderer = sdl.SDL_CreateRenderer(window, null);

        if (renderer == null) {
            const err = sdl.SDL_GetError();
            log.info("Failed to create renderer with error: {s}", .{err});
            return DisplayError.FailedToCreateRenderer;
        }

        return renderer;
    }

    fn new_texture(renderer: ?*sdl.struct_SDL_Renderer) ![*c]sdl.struct_SDL_Texture {
        const texture = sdl.SDL_CreateTexture(renderer, sdl.SDL_PIXELFORMAT_RGBA8888, sdl.SDL_TEXTUREACCESS_STREAMING, TEXTURE_WIDTH, TEXTURE_HEIGHT);

        if (texture == null) {
            const err = sdl.SDL_GetError();
            log.info("Failed to create texture with error: {s}", .{err});
            return DisplayError.FailedToCreateTexture;
        }

        _ = sdl.SDL_SetTextureScaleMode(texture, sdl.SDL_SCALEMODE_NEAREST);

        return texture;
    }

    pub fn quit(self: Display) void {
        sdl.SDL_DestroyTexture(self.texture);
        sdl.SDL_DestroyRenderer(self.renderer);
        sdl.SDL_DestroyWindow(self.window);
        sdl.SDL_Quit();
    }

    pub fn render(self: Display, vram: []u1) void {
        _ = sdl.SDL_RenderClear(self.renderer);

        self.buildTexture(vram);

        var dest = sdl.SDL_FRect{ .x = 0, .y = 0, .w = WINDOW_WIDTH, .h = WINDOW_HEIGHT };

        _ = sdl.SDL_RenderTexture(self.renderer, self.texture, null, &dest);
        _ = sdl.SDL_RenderPresent(self.renderer);
    }

    fn buildTexture(self: Display, vram: []u1) void {
        var pixels: ?[*]u32 = null;
        var pitch: c_int = 0;

        _ = sdl.SDL_LockTexture(self.texture, null, @as([*c]?*anyopaque, @ptrCast(&pixels)), &pitch);

        var y: usize = 0;
        while (y < TEXTURE_HEIGHT) : (y += 1) {
            var x: usize = 0;
            while (x < TEXTURE_WIDTH) : (x += 1) {
                if (vram[y * TEXTURE_WIDTH + x] == 1) {
                    pixels.?[y * TEXTURE_WIDTH + x] = 0xFFFFFFFF;
                } else {
                    pixels.?[y * TEXTURE_WIDTH + x] = 0x000000FF;
                }
            }
        }
        sdl.SDL_UnlockTexture(self.texture);
    }

    pub fn parse_event(self: Display, event: *DisplayEvent) void {
        _ = self;

        var sdl_event: sdl.SDL_Event = undefined;

        while (sdl.SDL_PollEvent(&sdl_event)) {
            switch (sdl_event.type) {
                sdl.SDL_EVENT_QUIT => event.* = DisplayEvent.quit,
                sdl.SDL_EVENT_KEY_DOWN => {
                    if (sdl_event.key.scancode == sdl.SDL_SCANCODE_ESCAPE) {
                        event.* = DisplayEvent.quit;
                    } else {
                        event.* = DisplayEvent{ .key_down = key_code(sdl_event) };
                    }
                },
                sdl.SDL_EVENT_KEY_UP => {
                    event.* = DisplayEvent{ .key_up = key_code(sdl_event) };
                },
                else => event.* = DisplayEvent.none,
            }
        }
    }

    fn key_code(event: sdl.SDL_Event) u32 {
        return @intCast(event.key.scancode);
    }
};
