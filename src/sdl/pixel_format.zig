const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const PixelFormat = enum(c_uint) {
    unknown = sdl.SDL_PIXELFORMAT_UNKNOWN,
    index1lsb = sdl.SDL_PIXELFORMAT_INDEX1LSB,
    index1msb = sdl.SDL_PIXELFORMAT_INDEX1MSB,
    index2lsb = sdl.SDL_PIXELFORMAT_INDEX2LSB,
    index2msb = sdl.SDL_PIXELFORMAT_INDEX2MSB,
    index4lsb = sdl.SDL_PIXELFORMAT_INDEX4LSB,
    index4msb = sdl.SDL_PIXELFORMAT_INDEX4MSB,
    index8 = sdl.SDL_PIXELFORMAT_INDEX8,
    rgb332 = sdl.SDL_PIXELFORMAT_RGB332,
    xrgb4444 = sdl.SDL_PIXELFORMAT_XRGB4444,
    xbgr4444 = sdl.SDL_PIXELFORMAT_XBGR4444,
    xrgb1555 = sdl.SDL_PIXELFORMAT_XRGB1555,
    xbgr1555 = sdl.SDL_PIXELFORMAT_XBGR1555,
    argb4444 = sdl.SDL_PIXELFORMAT_ARGB4444,
    rgba4444 = sdl.SDL_PIXELFORMAT_RGBA4444,
    abgr4444 = sdl.SDL_PIXELFORMAT_ABGR4444,
    bgra4444 = sdl.SDL_PIXELFORMAT_BGRA4444,
    argb1555 = sdl.SDL_PIXELFORMAT_ARGB1555,
    rgba5551 = sdl.SDL_PIXELFORMAT_RGBA5551,
    abgr1555 = sdl.SDL_PIXELFORMAT_ABGR1555,
    bgra5551 = sdl.SDL_PIXELFORMAT_BGRA5551,
    rgb565 = sdl.SDL_PIXELFORMAT_RGB565,
    bgr565 = sdl.SDL_PIXELFORMAT_BGR565,
    rgb24 = sdl.SDL_PIXELFORMAT_RGB24,
    bgr24 = sdl.SDL_PIXELFORMAT_BGR24,
    xrgb8888 = sdl.SDL_PIXELFORMAT_XRGB8888,
    rgbx8888 = sdl.SDL_PIXELFORMAT_RGBX8888,
    xbgr8888 = sdl.SDL_PIXELFORMAT_XBGR8888,
    bgrx8888 = sdl.SDL_PIXELFORMAT_BGRX8888,
    argb8888 = sdl.SDL_PIXELFORMAT_ARGB8888,
    rgba8888 = sdl.SDL_PIXELFORMAT_RGBA8888,
    abgr8888 = sdl.SDL_PIXELFORMAT_ABGR8888,
    bgra8888 = sdl.SDL_PIXELFORMAT_BGRA8888,
    xrgb2101010 = sdl.SDL_PIXELFORMAT_XRGB2101010,
    xbgr2101010 = sdl.SDL_PIXELFORMAT_XBGR2101010,
    argb2101010 = sdl.SDL_PIXELFORMAT_ARGB2101010,
    abgr2101010 = sdl.SDL_PIXELFORMAT_ABGR2101010,
    rgb48 = sdl.SDL_PIXELFORMAT_RGB48,
    bgr48 = sdl.SDL_PIXELFORMAT_BGR48,
    rgba64 = sdl.SDL_PIXELFORMAT_RGBA64,
    argb64 = sdl.SDL_PIXELFORMAT_ARGB64,
    bgra64 = sdl.SDL_PIXELFORMAT_BGRA64,
    abgr64 = sdl.SDL_PIXELFORMAT_ABGR64,
    rgb48_float = sdl.SDL_PIXELFORMAT_RGB48_FLOAT,
    bgr48_float = sdl.SDL_PIXELFORMAT_BGR48_FLOAT,
    rgba64_float = sdl.SDL_PIXELFORMAT_RGBA64_FLOAT,
    argb64_float = sdl.SDL_PIXELFORMAT_ARGB64_FLOAT,
    bgra64_float = sdl.SDL_PIXELFORMAT_BGRA64_FLOAT,
    abgr64_float = sdl.SDL_PIXELFORMAT_ABGR64_FLOAT,
    rgb96_float = sdl.SDL_PIXELFORMAT_RGB96_FLOAT,
    bgr96_float = sdl.SDL_PIXELFORMAT_BGR96_FLOAT,
    rgba128_float = sdl.SDL_PIXELFORMAT_RGBA128_FLOAT,
    argb128_float = sdl.SDL_PIXELFORMAT_ARGB128_FLOAT,
    bgra128_float = sdl.SDL_PIXELFORMAT_BGRA128_FLOAT,
    abgr128_float = sdl.SDL_PIXELFORMAT_ABGR128_FLOAT,
    yv12 = sdl.SDL_PIXELFORMAT_YV12,
    iyuv = sdl.SDL_PIXELFORMAT_IYUV,
    yuy2 = sdl.SDL_PIXELFORMAT_YUY2,
    uyvy = sdl.SDL_PIXELFORMAT_UYVY,
    yvyu = sdl.SDL_PIXELFORMAT_YVYU,
    nv12 = sdl.SDL_PIXELFORMAT_NV12,
    nv21 = sdl.SDL_PIXELFORMAT_NV21,
    p010 = sdl.SDL_PIXELFORMAT_P010,
    external_oes = sdl.SDL_PIXELFORMAT_EXTERNAL_OES,
    // rgba32 = sdl.SDL_PIXELFORMAT_RGBA32,
    // argb32 = sdl.SDL_PIXELFORMAT_ARGB32,
    // bgra32 = sdl.SDL_PIXELFORMAT_BGRA32,
    // abgr32 = sdl.SDL_PIXELFORMAT_ABGR32,
    // rgbx32 = sdl.SDL_PIXELFORMAT_RGBX32,
    // xrgb32 = sdl.SDL_PIXELFORMAT_XRGB32,
    // bgrx32 = sdl.SDL_PIXELFORMAT_BGRX32,
    // xbgr32 = sdl.SDL_PIXELFORMAT_XBGR32,
};
