const std = @import("std");

const Io = std.Io;
const net = std.Io.net;
const http = std.http;
const Dir = std.Io.Dir;
const File = std.Io.File;

const PORT = 8014;
const DIST = "dist";
const BUF_SIZE = 8192;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var threaded = Io.Threaded.init(allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    const addr = net.IpAddress{ .ip4 = .{ .bytes = .{ 0, 0, 0, 0 }, .port = PORT } };
    var server = try addr.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    std.log.info("notes-server listening on http://0.0.0.0:{d}", .{PORT});
    std.log.info("serving ./{s}/", .{DIST});

    while (true) {
        const stream = server.accept(io) catch |err| {
            std.log.err("accept: {}", .{err});
            continue;
        };
        handle(stream, io, allocator) catch |err| {
            std.log.err("connection: {}", .{err});
        };
    }
}

fn handle(stream: net.Stream, io: Io, allocator: std.mem.Allocator) !void {
    defer stream.close(io);

    var read_buf: [BUF_SIZE]u8 = undefined;
    var write_buf: [BUF_SIZE]u8 = undefined;
    var path_buf: [Dir.max_path_bytes]u8 = undefined;

    var reader = stream.reader(io, &read_buf);
    var writer = stream.writer(io, &write_buf);

    var srv = http.Server.init(&reader.interface, &writer.interface);

    var request = srv.receiveHead() catch {
        return;
    };

    const target = request.head.target;

    if (std.mem.indexOf(u8, target, "..") != null) {
        try request.respond("", .{ .status = .forbidden, .keep_alive = false });
        return;
    }

    var fp = if (target.len > 0 and target[0] == '/') target[1..] else target;
    if (fp.len == 0) fp = "index.html";

    const full_path = try std.fmt.bufPrint(&path_buf, DIST ++ "/{s}", .{fp});

    const cwd = Dir.cwd();
    if (cwd.openFile(io, full_path, .{ .allow_directory = false })) |file| {
        defer file.close(io);
        try serve(file, io, allocator, &request, fp);
    } else |_| {
        const idx_path = try std.fmt.bufPrint(&path_buf, DIST ++ "/index.html", .{});
        if (!std.mem.eql(u8, fp, "index.html")) {
            if (cwd.openFile(io, idx_path, .{ .allow_directory = false })) |idx| {
                defer idx.close(io);
                try serve(idx, io, allocator, &request, "index.html");
            } else |_| {
                try request.respond("", .{ .status = .not_found, .keep_alive = false });
            }
        } else {
            try request.respond("", .{ .status = .not_found, .keep_alive = false });
        }
    }
}

fn serve(file: File, io: Io, allocator: std.mem.Allocator, request: *http.Server.Request, path: []const u8) !void {
    const size = (try file.stat(io)).size;
    const mime = mimeType(path);
    const cache = if (std.mem.eql(u8, path, "index.html")) "no-cache" else "public, max-age=31536000, immutable";

    var headers = [_]http.Header{
        .{ .name = "Content-Type", .value = mime },
        .{ .name = "Cache-Control", .value = cache },
    };

    const body = try allocator.alloc(u8, size);
    defer allocator.free(body);
    _ = try file.readPositionalAll(io, body, 0);

    try request.respond(body, .{
        .keep_alive = false,
        .extra_headers = &headers,
    });
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
    return "application/octet-stream";
}