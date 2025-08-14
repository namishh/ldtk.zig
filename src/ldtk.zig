const std = @import("std");

// ::POINTS
pub fn Point(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn init(x_val: T, y_val: T) Self {
            return Self{ .x = x_val, .y = y_val };
        }

        pub fn initZero() Self {
            return Self{ .x = 0, .y = 0 };
        }

        pub fn eql(self: Self, other: Self) bool {
            return self.x == other.x and self.y == other.y;
        }
    };
}

pub const IntPoint = Point(i32);
pub const UIntPoint = Point(u32);
pub const FloatPoint = Point(f32);

// ::COLOR STRUCT
pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn initRGBA(r_val: u8, g_val: u8, b_val: u8, a_val: u8) Color {
        return Color{ .r = r_val, .g = g_val, .b = b_val, .a = a_val };
    }

    pub fn initFromHex(hex: []const u8) Color {
        var color = Color.init();
        if (hex.len >= 7) {
            color.r = std.fmt.parseInt(u8, hex[1..3], 16) catch 0;
            color.g = std.fmt.parseInt(u8, hex[3..5], 16) catch 0;
            color.b = std.fmt.parseInt(u8, hex[5..7], 16) catch 0;
        }
        // if alpha channel exists
        if (hex.len >= 9) {
            color.a = std.fmt.parseInt(u8, hex[7..9], 16) catch 0xff;
        }
        return color;
    }

    pub fn initFromHexInt(hex: i32) Color {
        return Color{
            .r = @intCast((hex >> 16) & 0xFF),
            .g = @intCast((hex >> 8) & 0xFF),
            .b = @intCast(hex & 0xFF),
            .a = 0xff,
        };
    }

    pub fn init() Color {
        return Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
    }

    pub fn eql(self: Color, other: Color) bool {
        return self.r == other.r and self.g == other.g and
            self.b == other.b and self.a == other.a;
    }
};

pub const FilePath = struct {
    path: []const u8,

    pub fn init(allocator: std.mem.Allocator, path_str: []const u8) !FilePath {
        const owned_path = try allocator.dupe(u8, path_str);
        return FilePath{ .path = owned_path };
    }

    pub fn deinit(self: FilePath, allocator: std.mem.Allocator) void {
        allocator.free(self.path);
    }
};

/// Instance ID type
pub const IID = []const u8;

pub const Project = struct {
    allocator: std.mem.Allocator,
    default_pivot: FloatPoint,
    file_path: FilePath,
    default_cell_size: i32,
    background_color: Color,
    json_version: []const u8,

    pub fn init(allocator: std.mem.Allocator) !Project {
        return Project{
            .allocator = allocator,
            .default_pivot = FloatPoint.init(0.5, 1.0),
            .default_cell_size = 16,
            .file_path = FilePath{ .path = "" },
            .background_color = Color.init(),
            .json_version = "",
        };
    }

    pub fn loadFromFile(allocator: std.mem.Allocator, file_path: []const u8) !Project {
        var project = try Project.init(allocator);
        project.file_path = try FilePath.init(allocator, file_path);

        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const content = try allocator.alloc(u8, file_size);
        defer allocator.free(content);

        try project.parseJson(content);

        _ = try file.readAll(content);
        return project;
    }

    pub fn loadFromMemory(allocator: std.mem.Allocator, json_content: []const u8) !Project {
        var project = Project.init(allocator);
        try project.parseJson(json_content);
        return project;
    }

    fn parseJson(self: *Project, content: []const u8) !void {
        _ = self;
        _ = content;
    }

    pub fn deinit(self: *Project) void {
        self.file_path.deinit(self.allocator);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var project = try Project.loadFromFile(allocator, "level.ldtk");
    defer project.deinit();
}
