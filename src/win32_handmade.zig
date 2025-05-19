const std = @import("std");
const assert = std.debug.assert;

const win32 = struct {
    usingnamespace @import("win32").zig;
    usingnamespace @import("win32").system.diagnostics.debug;
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").ui.windows_and_messaging;
    usingnamespace @import("win32").graphics.gdi;
};

pub const UNICODE = true;

pub var bitmap_info: ?win32.BITMAPINFO = null;
pub var bitmap_memory: ?*?*anyopaque = null;
pub var bitmap_handle: ?win32.HBITMAP = null;
pub var bitmap_device_context: ?win32.HDC = null;

// TODO: global for now.
pub var running = true;

pub fn resizeDIBSection(width: i32, height: i32) void {
    // TODO: bullet proof this
    // don't free first, free after, first if that fails

    bitmap_info = .{
        .bmiHeader = win32.BITMAPINFOHEADER {
            .biSize = @as(@sizeOf(@TypeOf(bitmap_info.bmiHeader)), u32),
            .biWidth = width,
            .biHeight = height,
            .biPlanes = 1,
            .biBitCount = 32,
            .biCompression = @as(win32.BI_RGB, u32),
            .biXPelsPerMeter = 0,
            .biYPelsPerMeter = 0,
            .biClrUsed = 0,
            .biClrImportant = 0
        }
    };

    if(bitmap_device_context == null) {
        bitmap_device_context = win32.CreateCompatibleDC(0);
    }

    win32.CreateDIBSection(device_context.?, &bitmap_info, .RGB_COLORS, &bitmap_memory, 0, 0,);
}

pub fn updateWindow(
    device_context: ?win32.HDC,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
) void {
    win32.StretchDIBits(device_context, x, y, width, height, x, y, width, height, lpBits: ?*const anyopaque, lpbmi: ?*const BITMAPINFO, .RGB_COLORS, win32.SRCCOPY,);
}

pub export fn wWinMain(
    instance: ?win32.HINSTANCE,
    prev_instance: ?win32.HINSTANCE,
    commandline: ?win32.PWSTR,
    show_code: c_int,
) c_int {
    // _ = instance;
    _ = prev_instance;
    _ = commandline;
    _ = show_code;

    // std.debug.print("{}", .{@sizeOf(win32.LRESULT)});

    const window_class: win32.WNDCLASS = .{
        .style = .{
            .OWNDC = 1,
            .HREDRAW = 1,
            .VREDRAW = 1,
        },
        .lpfnWndProc = WinProc,
        .hInstance = instance,
        .lpszClassName = win32.L("HandMadeHeroWindowClass"),
        .cbWndExtra = 0,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .cbClsExtra = 0,
    };
    const reg_window = win32.RegisterClassW(&window_class);
    assert(reg_window != 0);

    const window_handle: ?win32.HWND = win32.CreateWindowEx(
        .{},
        window_class.lpszClassName,
        win32.L("Handmade Hero"),
        win32.WINDOW_STYLE{
            .VISIBLE = 1,
            .TABSTOP = 1,
            .GROUP = 1,
            .THICKFRAME = 1,
            .SYSMENU = 1,
            .DLGFRAME = 1,
            .BORDER = 1,
        },
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        null,
        null,
        instance,
        null,
    );
    assert(window_handle != null);

    while (running) {
        win32.OutputDebugStringA("Handle message \n");

        var message: win32.MSG = undefined;
        const message_result = win32.GetMessage(
            &message,
            null,
            0,
            0,
        );

        // EXIT/CLOSE
        if (message_result <= 0) break;

        _ = win32.TranslateMessage(&message);
        _ = win32.DispatchMessageW(&message);
    }

    return 0;
}

fn WinProc(
    window: win32.HWND,
    message: u32,
    w_param: win32.WPARAM,
    l_param: win32.LPARAM,
) callconv(.C) win32.LRESULT {
    var result: win32.LRESULT = 0;

    switch (message) {
        win32.WM_SIZE => {
            var client_rect: ?win32.RECT = undefined;
            _ = win32.GetClientRect(window, &client_rect);
            assert(client_rect == null);

            const height = client_rect.?.bottom - client_rect.?.top;
            const width = client_rect.?.right - client_rect.?.left;
            resizeDIBSection(width, height);
            win32.OutputDebugStringA("WM_SIZE\n");
            std.log.info("WM_SIZE", .{});
        },
        win32.WM_DESTROY, win32.WM_CLOSE => {
            running = false;
        },
        win32.WM_ACTIVATEAPP => {
            win32.OutputDebugStringA("WM_ACTIVATEAPP\n");
            std.log.info("WM_ACTIVATEAPP", .{});
        },
        win32.WM_PAINT => {
            std.log.info("WM_PAINT", .{});
            var paint: win32.PAINTSTRUCT = undefined;

            const device_context: ?win32.HDC = win32.BeginPaint(window, &paint);
            if (device_context != null) {
                const x = paint.rcPaint.left;
                const y = paint.rcPaint.top;
                const height = paint.rcPaint.bottom - paint.rcPaint.top;
                const width = paint.rcPaint.right - paint.rcPaint.left;

                updateWindow(
                    device_context
                    window,
                    x,
                    y,
                    width,
                    height,
                );
                const color = if (@rem(height, 2) == 0) win32.BLACKNESS else win32.WHITENESS;

                _ = win32.PatBlt(
                    device_context,
                    x,
                    y,
                    width,
                    height,
                    color,
                );
            }

            _ = win32.EndPaint(window, &paint);
        },
        else => {
            result = win32.DefWindowProc(window, message, w_param, l_param);
        },
    }

    return result;
}
