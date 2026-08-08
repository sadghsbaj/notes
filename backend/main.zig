const std = @import("std");

const PORT = 8014;
const DIST = "dist";
const BUF_SIZE = 8192;
const MAX_PATH = std.fs.MAX_PATH_BYTES;

pub fn main() !void {
    const addr = try std.net.Address.parseIp4("0.0.0.0", PORT);
    var server = try addr.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.log.info("notes-server listening on http://0.0.0.0:{d}", .{PORT});
    std.log.info("serving ./{s}/", .{DIST});

    var buf: [BUF_SIZE]u8 = undefined;

    while (true) {
        const conn = server.accept() catch |err| {
            std.log.err("accept failed: {}", .{err});
            continue;
        };
        handle(conn, &buf) catch |err| {
            std.log.err("connection error: {}", .{err});
        };
    }
}

fn handle(conn: std.net.Server.Connection, buf: []u8) !void {
    defer conn.stream.close();

    const n = try conn.stream.read(buf[0..4096]);
    if (n == 0) return;
    const request = buf[0..n];

    const path = parsePath(request) orelse {
        try respond(conn.stream, 400, "Bad Request", "", null);
        return;
    };

    if (std.mem.indexOf(u8, path, "..") != null) {
        try respond(conn.stream, 403, "Forbidden", "", null);
        return;
    }

    var file_path = if (path.len > 0 and path[0] == '/') path[1..] else path;
    if (file_path.len == 0 or std.mem.eql(u8, file_path, "/")) {
        file_path = "index.html";
    }

    serve(conn.stream, file_path, buf) catch |_| {
        if (!std.mem.eql(u8, file_path, "index.html")) {
            serve(conn.stream, "index.html", buf) catch {};
        }
        // else: already tried index.html, connection closed
    };
}

fn serve(stream: std.net.Stream, file_path: []const u8, buf: []u8) !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile(file_path, .{ .mode = .read_only });
    defer file.close();

    const size = (try file.stat()).size;
    const mime = mimeType(file_path);

    var resp_buf: [512]u8 = undefined;
    const cache = b: {
        if (std.mem.eql(u8, file_path, "index.html")) break :b "no-cache";
        break :b "public, max-age=31536000, immutable";
    };

    const header = try std.fmt.bufPrint(
        &resp_buf,
        "HTTP/1.1 200 OK\r\nContent-Type: {s}\r\nContent-Length: {d}\r\nCache-Control: {s}\r\nConnection: close\r\n\r\n",
        .{ mime, size, cache },
    );
    _ = try stream.writeAll(header);

    var sent: u64 = 0;
    while (sent < size) {
        const chunk = @min(@as(u64, BUF_SIZE), size - sent);
        const read = try file.read(buf[0..chunk]);
        _ = try stream.writeAll(buf[0..read]);
        sent += read;
    }
}

fn respond(
    stream: std.net.Stream,
    code: u16,
    reason: []const u8,
    mime: []const u8,
    body: ?[]const u8,
) !void {
    var resp_buf: [256]u8 = undefined;
    const body_bytes = body orelse "";
    const ct = mime;

    if (ct.len == 0) {
        const header = try std.fmt.bufPrint(
            &resp_buf,
            "HTTP/1.1 {d} {s}\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n",
            .{ code, reason, body_bytes.len },
        );
        _ = try stream.writeAll(header);
    } else {
        const header = try std.fmt.bufPrint(
            &resp_buf,
            "HTTP/1.1 {d} {s}\r\nContent-Type: {s}\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n",
            .{ code, reason, ct, body_bytes.len },
        );
        _ = try stream.writeAll(header);
    }

    if (body_bytes.len > 0) {
        _ = try stream.writeAll(body_bytes);
    }
}

fn parsePath(request: []const u8) ?[]const u8 {
    var it = std.mem.splitScalar(u8, request, '\n');
    const first_line = it.first();

    const line = if (first_line.len > 0 and first_line[first_line.len - 1] == '\r')
        first_line[0 .. first_line.len - 1]
    else
        first_line;

    var parts = std.mem.splitScalar(u8, line, ' ');
    _ = parts.first(); // method
    const path = parts.next() orelse return null;

    if (parts.next() == null) return null; // no HTTP version

    return path;
}

fn mimeType(path: []const u8) []const u8 {
    const ext = std.fs.path.extension(path);
    if (std.mem.eql(u8, ext, ".html")) return "text/html; charset=utf-8";
    if (std.mem.eql(u8, ext, ".css")) return "text/css; charset=utf-8";
    if (std.mem.eql(u8, ext, ".js")) return "application/javascript; charset=utf-8";
    if (std.mem.eql(u8, ext, ".mjs")) return "application/javascript; charset=utf-8";
    if (std.mem.eql(u8, ext, ".json")) return "application/json";
    if (std.mem.eql(u8, ext, ".png")) return "image/png";
    if (std.mem.eql(u8, ext, ".svg")) return "image/svg+xml";
    if (std.mem.eql(u8, ext, ".woff")) return "font/woff";
    if (std.mem.eql(u8, ext, ".woff2")) return "font/woff2";
    if (std.mem.eql(u8, ext, ".ico")) return "image/x-icon";
    if (std.mem.eql(u8, ext, ".txt")) return "text/plain; charset=utf-8";
    if (std.mem.eql(u8, ext, ".xml")) return "application/xml";
    if (std.mem.eql(u8, ext, ".webp")) return "image/webp";
    if (std.mem.eql(u8, ext, ".avif")) return "image/avif";
    if (std.mem.eql(u8, ext, ".webmanifest")) return "application/manifest+json";
    if (std.mem.eql(u8, ext, ".mp4")) return "video/mp4";
    if (std.mem.eql(u8, ext, ".webm")) return "video/webm";
    return "application/octet-stream";
}