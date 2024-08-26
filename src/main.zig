const std = @import("std");

const stdin_fd = std.io.getStdIn().handle;

pub fn main() !void {
    const orig_termios = try std.posix.tcgetattr(stdin_fd);
    try enableRawMode(orig_termios);
    defer disableRawMode(orig_termios);

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [1]u8 = undefined;
    while (true) {
        buf[0] = 0;
        _ = try stdin.read(buf[0..]);
        if (buf[0] == 'q') break;
        const ch = buf[0];
        if (std.ascii.isControl(ch)) {
            try stdout.print("{d}\r\n", .{ch});
        } else {
            try stdout.print("{d} ('{c})\r\n", .{ ch, ch });
        }
    }
}

fn enableRawMode(orig_termios: std.posix.termios) !void {
    var raw = orig_termios;

    raw.lflag.ECHO = false;
    raw.lflag.ICANON = false;
    raw.lflag.ISIG = false;
    raw.lflag.IEXTEN = false;

    raw.iflag.IXON = false;
    raw.iflag.ICRNL = false;
    raw.iflag.INPCK = false;
    raw.iflag.ISTRIP = false;
    raw.iflag.BRKINT = false;

    raw.oflag.OPOST = false;

    raw.cflag.CSIZE = .CS8;

    raw.cc[@intFromEnum(std.posix.V.MIN)] = 0;
    raw.cc[@intFromEnum(std.posix.V.TIME)] = 1;

    try std.posix.tcsetattr(stdin_fd, std.posix.TCSA.FLUSH, raw);
}

fn disableRawMode(orig_termios: std.posix.termios) void {
    std.posix.tcsetattr(stdin_fd, std.posix.TCSA.FLUSH, orig_termios) catch std.debug.panic("tcsetattr", .{});
}
