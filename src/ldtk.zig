const std = @import("std");

pub const Project = struct {
    allocator: std.mem.Allocator,
    json: std.json.Parsed(std.json.Value),

    pub fn init(allocator: std.mem.Allocator, file_path: []const u8) !Project {
        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        const file_stat = try file.stat();
        const content = try file.readToEndAlloc(allocator, file_stat.size);
        defer allocator.free(content);
        const json = try std.json.parseFromSlice(std.json.Value, allocator, content, .{});
        return Project{ .allocator = allocator, .json = json };
    }

    pub fn deinit(self: *Project) void {
        self.json.deinit();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var project = try Project.init(allocator, "level.ldtk");
    defer project.deinit();
    const json = project.json.value;
    if (json.object.get("iid")) |iid| {
        std.debug.print("All your {s} are belong to us.\n", .{iid.string});
    } else {
        std.debug.print("iid field not found\n", .{});
    }
}
