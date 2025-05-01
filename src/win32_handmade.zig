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

pub export fn wWinMain(instance: ?win32.HINSTANCE, prev_instance: ?win32.HINSTANCE, commandline: ?win32.PWSTR, show_code: c_int) c_int {
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

    while (true) {
        win32.OutputDebugStringA("Handle message \n");

        var message: win32.MSG = undefined;
        const message_result = win32.GetMessage(&message, null, 0, 0);

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
            win32.OutputDebugStringA("WM_SIZE\n");
            std.log.info("WM_SIZE", .{});
        },
        win32.WM_DESTROY => {
            win32.OutputDebugStringA("WM_DESTROY\n");
            std.log.info("WM_DESTROY", .{});
        },
        win32.WM_CLOSE => {
            win32.OutputDebugStringA("WM_CLOSE\n");
            std.log.info("WM_CLOSE", .{});
        },
        win32.WM_ACTIVATEAPP => {
            win32.OutputDebugStringA("WM_ACTIVATEAPP\n");
            std.log.info("WM_ACTIVATEAPP", .{});
        },
        win32.WM_PAINT => {
            std.log.info("WM_PAINT", .{});
            var paint: win32.PAINTSTRUCT = undefined;

            const deviceContext: ?win32.HDC = win32.BeginPaint(window, &paint);
            if (deviceContext != null) {
                const x = paint.rcPaint.left;
                const y = paint.rcPaint.top;
                const height = paint.rcPaint.bottom - paint.rcPaint.top;
                const width = paint.rcPaint.right - paint.rcPaint.left;
                const color = if (@rem(height, 2) == 0) win32.BLACKNESS else win32.WHITENESS;

                _ = win32.PatBlt(
                    deviceContext,
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
