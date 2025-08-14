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

    pub fn toHex(self: Color, allocator: *const std.mem.Allocator) ![]u8 {
        const buf = try allocator.alloc(u8, 9);
        _ = try std.fmt.bufPrint(buf, "#{X:0>2}{X:0>2}{X:0>2}{X:0>2}", .{
            self.r, self.g, self.b, self.a,
        });
        return buf;
    }

    pub fn init() Color {
        return Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
    }

    pub fn eql(self: Color, other: Color) bool {
        return self.r == other.r and self.g == other.g and
            self.b == other.b and self.a == other.a;
    }
};

pub fn Rect(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        width: T,
        height: T,

        pub fn init(x_val: T, y_val: T, w: T, h: T) Self {
            return Self{ .x = x_val, .y = y_val, .width = w, .height = h };
        }

        pub fn initFromPosition(pos: Point(T), w: T, h: T) Self {
            return Self{ .x = pos.x, .y = pos.y, .width = w, .height = h };
        }

        pub fn initZero() Self {
            return Self{ .x = 0, .y = 0, .width = 0, .height = 0 };
        }

        pub fn eql(self: Self, other: Self) bool {
            return self.x == other.x and self.y == other.y and
                self.width == other.width and self.height == other.height;
        }
    };
}

pub const IntRect = Rect(i32);
pub const UIntRect = Rect(u32);
pub const FloatRect = Rect(f32);

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

// ::FieldType
pub const FieldType = enum {
    Int,
    Float,
    Bool,
    String,
    Color,
    Point,
    Enum,
    FilePath,
    Tile,
    EntityRef,
    ArrayInt,
    ArrayFloat,
    ArrayBool,
    ArrayString,
    ArrayColor,
    ArrayPoint,
    ArrayEnum,
    ArrayFilePath,
    ArrayTile,
    ArrayEntityRef,
};

// ::FieldValue
pub const FieldValue = union(enum) {
    Int: i32,
    Float: f32,
    String: []const u8,
    Bool: bool,
    Color: Color,
    Point: IntPoint,
    Enum: []const u8,
    FilePath: FilePath,
    Tile: IntPoint,
    EntityRef: IID,
    ArrayInt: std.ArrayList(i32),
    ArrayFloat: std.ArrayList(f32),
    ArrayBool: std.ArrayList(bool),
    ArrayString: std.ArrayList([]const u8),
    ArrayColor: std.ArrayList(Color),
    ArrayPoint: std.ArrayList(IntPoint),
    ArrayEnum: std.ArrayList([]const u8),
    ArrayFilePath: std.ArrayList(FilePath),
    ArrayTile: std.ArrayList(IntPoint),
    ArrayEntityRef: std.ArrayList(IID),

    pub fn deinit(self: FieldValue, allocator: std.mem.Allocator) void {
        switch (self) {
            .String => |s| allocator.free(s),
            .FilePath => |fp| fp.deinit(allocator),
            .ArrayInt => |arr| arr.deinit(),
            .ArrayFloat => |arr| arr.deinit(),
            .ArrayBool => |arr| arr.deinit(),
            .ArrayString => |arr| {
                for (arr.items) |s| allocator.free(s);
                arr.deinit();
            },
            .ArrayColor => |arr| arr.deinit(),
            .ArrayPoint => |arr| arr.deinit(),
            .ArrayEnum => |arr| {
                for (arr.items) |s| allocator.free(s);
                arr.deinit();
            },
            .ArrayFilePath => |arr| {
                for (arr.items) |fp| fp.deinit(allocator);
                arr.deinit();
            },
            .ArrayTile => |arr| arr.deinit(),
            .ArrayEntityRef => |arr| {
                for (arr.items) |s| allocator.free(s);
                arr.deinit();
            },
            else => {},
        }
    }
};

// ::FieldDef
pub const FieldDef = struct {
    identifier: []const u8,
    field_type: FieldType,
    default_value: ?FieldValue,

    pub fn deinit(self: FieldDef, allocator: std.mem.Allocator) void {
        allocator.free(self.identifier);
        if (self.default_value) |value| {
            value.deinit(allocator);
        }
    }
};

// ::Field
pub const Field = struct {
    def: *const FieldDef,
    value: FieldValue,

    pub fn deinit(self: Field, allocator: std.mem.Allocator) void {
        self.value.deinit(allocator);
    }

    pub fn getName(self: Field) []const u8 {
        return self.def.identifier;
    }

    pub fn getType(self: Field) FieldType {
        return self.def.field_type;
    }
};

// ::FieldsContainer
pub const FieldsContainer = struct {
    fields: std.HashMap([]const u8, Field, std.hash_map.StringContext, std.hash_map.default_max_load_percentage),

    pub fn init(allocator: std.mem.Allocator) FieldsContainer {
        return FieldsContainer{
            .fields = std.HashMap([]const u8, Field, std.hash_map.StringContext, std.hash_map.default_max_load_percentage).init(allocator),
        };
    }

    pub fn deinit(self: *FieldsContainer, allocator: std.mem.Allocator) void {
        var iterator = self.fields.iterator();
        while (iterator.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(allocator);
        }
        self.fields.deinit();
    }

    pub fn getField(self: FieldsContainer, name: []const u8) ?Field {
        return self.fields.get(name);
    }

    pub fn hasField(self: FieldsContainer, name: []const u8) bool {
        return self.fields.contains(name);
    }

    pub fn allFields(self: FieldsContainer) std.HashMap([]const u8, Field, std.hash_map.StringContext, std.hash_map.default_max_load_percentage).Iterator {
        return self.fields.iterator();
    }
};

// ::IntGrid
pub const IntGridValue = struct {
    value: i32,
    name: []const u8,
    color: Color,

    pub const NONE = IntGridValue{
        .value = 0,
        .name = "",
        .color = Color.init(),
    };

    pub fn init(val: i32, n: []const u8, c: Color) IntGridValue {
        return IntGridValue{ .value = val, .name = n, .color = c };
    }
};

// ::LayerDefs
pub const LayerType = enum {
    IntGrid,
    Entities,
    Tiles,
    AutoLayer,
};

pub const LayerDef = struct {
    identifier: []const u8,
    layer_type: LayerType,
    uid: i32,
    grid_size: i32,
    opacity: f32,
    px_offset: IntPoint,
    intgrid_values: std.ArrayList(IntGridValue),
    tileset_uid: ?i32,

    pub fn init(allocator: std.mem.Allocator) LayerDef {
        return LayerDef{
            .identifier = "",
            .layer_type = LayerType.IntGrid,
            .uid = 0,
            .grid_size = 16,
            .opacity = 1.0,
            .px_offset = IntPoint.initZero(),
            .intgrid_values = std.ArrayList(IntGridValue).init(allocator),
            .tileset_uid = null,
        };
    }

    pub fn deinit(self: *LayerDef, allocator: std.mem.Allocator) void {
        allocator.free(self.identifier);
        self.intgrid_values.deinit();
    }
};

// ::EntityDef
pub const EntityDef = struct {
    identifier: []const u8,
    uid: i32,
    size: IntPoint,
    color: Color,
    field_defs: std.ArrayList(FieldDef),

    pub fn init(allocator: std.mem.Allocator) EntityDef {
        return EntityDef{
            .identifier = "",
            .uid = 0,
            .size = IntPoint.init(16, 16),
            .color = Color.init(),
            .field_defs = std.ArrayList(FieldDef).init(allocator),
        };
    }

    pub fn deinit(self: *EntityDef, allocator: std.mem.Allocator) void {
        allocator.free(self.identifier);
        for (self.field_defs.items) |*field_def| {
            field_def.deinit(allocator);
        }
        self.field_defs.deinit();
    }
};

// ::EnumDef
pub const EnumDef = struct {
    identifier: []const u8,
    uid: i32,
    values: std.ArrayList([]const u8),

    pub fn init(allocator: std.mem.Allocator) EnumDef {
        return EnumDef{
            .identifier = "",
            .uid = 0,
            .values = std.ArrayList([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *EnumDef, allocator: std.mem.Allocator) void {
        allocator.free(self.identifier);
        for (self.values.items) |value| {
            allocator.free(value);
        }
        self.values.deinit();
    }
};

// ::Tileset
pub const Tileset = struct {
    identifier: []const u8,
    uid: i32,
    rel_path: FilePath,
    px_width: i32,
    px_height: i32,
    tile_grid_size: i32,
    spacing: i32,
    padding: i32,

    pub fn deinit(self: *Tileset, allocator: std.mem.Allocator) void {
        allocator.free(self.identifier);
        self.rel_path.deinit(allocator);
    }

    pub fn getTexRect(self: Tileset, tile_id: i32) IntRect {
        const tiles_per_row = self.px_width / self.tile_grid_size;
        const tile_x = tile_id % tiles_per_row;
        const tile_y = tile_id / tiles_per_row;

        const x = tile_x * (self.tile_grid_size + self.spacing) + self.padding;
        const y = tile_y * (self.tile_grid_size + self.spacing) + self.padding;

        return IntRect.init(x, y, self.tile_grid_size, self.tile_grid_size);
    }
};

fn parseLayerType(type_str: []const u8) LayerType {
    if (std.mem.eql(u8, type_str, "IntGrid")) return LayerType.IntGrid;
    if (std.mem.eql(u8, type_str, "Entities")) return LayerType.Entities;
    if (std.mem.eql(u8, type_str, "Tiles")) return LayerType.Tiles;
    if (std.mem.eql(u8, type_str, "AutoLayer")) return LayerType.AutoLayer;
    return LayerType.IntGrid;
}

// ::Project
pub const Project = struct {
    allocator: std.mem.Allocator,
    default_pivot: FloatPoint,
    file_path: FilePath,
    layers_defs: std.ArrayList(LayerDef),
    tilesets: std.ArrayList(Tileset),
    entities_defs: std.ArrayList(EntityDef),
    enums: std.ArrayList(EnumDef),
    default_cell_size: i32,
    background_color: Color,
    json_version: []const u8,

    pub fn init(allocator: std.mem.Allocator) !Project {
        return Project{
            .allocator = allocator,
            .default_pivot = FloatPoint.init(0.5, 1.0),
            .default_cell_size = 16,
            .layers_defs = std.ArrayList(LayerDef).init(allocator),
            .tilesets = std.ArrayList(Tileset).init(allocator),
            .entities_defs = std.ArrayList(EntityDef).init(allocator),
            .enums = std.ArrayList(EnumDef).init(allocator),
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

        _ = try file.readAll(content);
        try project.parseJson(content);
        return project;
    }

    pub fn loadFromMemory(allocator: std.mem.Allocator, json_content: []const u8) !Project {
        var project = Project.init(allocator);
        try project.parseJson(json_content);
        return project;
    }

    fn parseJson(self: *Project, content: []const u8) !void {
        var parsed = try std.json.parseFromSlice(std.json.Value, self.allocator, content, .{});
        defer parsed.deinit();

        const root = parsed.value.object;
        if (root.get("jsonVersion")) |version| {
            self.json_version = try self.allocator.dupe(u8, version.string);
        }

        if (root.get("defaultPivotX")) |pivot_x| {
            if (root.get("defaultPivotY")) |pivot_y| {
                const x_val: f32 = switch (pivot_x) {
                    .float => @floatCast(pivot_x.float),
                    .integer => @floatFromInt(pivot_x.integer),
                    else => 0.5,
                };
                const y_val: f32 = switch (pivot_y) {
                    .float => @floatCast(pivot_y.float),
                    .integer => @floatFromInt(pivot_y.integer),
                    else => 1.0,
                };
                self.default_pivot = FloatPoint.init(x_val, y_val);
            }
        }

        if (root.get("defaultGridSize")) |grid_size| {
            self.default_cell_size = @intCast(grid_size.integer);
        }

        if (root.get("bgColor")) |bg_color| {
            self.background_color = Color.initFromHex(bg_color.string);
        }

        if (root.get("defs")) |defs| {
            try self.parseDefinitions(defs.object);
        }
    }

    fn parseDefinitions(self: *Project, defs: std.json.ObjectMap) !void {
        if (defs.get("layers")) |layers| {
            for (layers.array.items) |layer_json| {
                var layer_def = LayerDef.init(self.allocator);

                if (layer_json.object.get("identifier")) |id| {
                    layer_def.identifier = try self.allocator.dupe(u8, id.string);
                }

                if (layer_json.object.get("uid")) |uid| {
                    layer_def.uid = @intCast(uid.integer);
                }

                if (layer_json.object.get("gridSize")) |grid_size| {
                    layer_def.grid_size = @intCast(grid_size.integer);
                }

                if (layer_json.object.get("displayOpacity")) |opacity| {
                    layer_def.opacity = switch (opacity) {
                        .float => @floatCast(opacity.float),
                        .integer => @floatFromInt(opacity.integer),
                        else => 1.0,
                    };
                }

                if (layer_json.object.get("type")) |layer_type| {
                    layer_def.layer_type = parseLayerType(layer_type.string);
                }

                try self.layers_defs.append(layer_def);
            }
        }

        if (defs.get("entities")) |entities| {
            for (entities.array.items) |entity_json| {
                var entity_def = EntityDef.init(self.allocator);

                if (entity_json.object.get("identifier")) |id| {
                    entity_def.identifier = try self.allocator.dupe(u8, id.string);
                }

                if (entity_json.object.get("uid")) |uid| {
                    entity_def.uid = @intCast(uid.integer);
                }

                if (entity_json.object.get("width")) |width| {
                    if (entity_json.object.get("height")) |height| {
                        entity_def.size = IntPoint.init(@intCast(width.integer), @intCast(height.integer));
                    }
                }

                if (entity_json.object.get("color")) |color| {
                    entity_def.color = Color.initFromHex(color.string);
                }

                try self.entities_defs.append(entity_def);
            }
        }

        if (defs.get("tilesets")) |tilesets| {
            for (tilesets.array.items) |tileset_json| {
                var tileset = Tileset{
                    .identifier = "",
                    .uid = 0,
                    .rel_path = FilePath{ .path = "" },
                    .px_width = 0,
                    .px_height = 0,
                    .tile_grid_size = 16,
                    .spacing = 0,
                    .padding = 0,
                };

                if (tileset_json.object.get("identifier")) |id| {
                    tileset.identifier = try self.allocator.dupe(u8, id.string);
                }

                if (tileset_json.object.get("uid")) |uid| {
                    tileset.uid = @intCast(uid.integer);
                }

                if (tileset_json.object.get("relPath")) |path| {
                    tileset.rel_path = try FilePath.init(self.allocator, path.string);
                }

                if (tileset_json.object.get("pxWid")) |width| {
                    tileset.px_width = @intCast(width.integer);
                }

                if (tileset_json.object.get("pxHei")) |height| {
                    tileset.px_height = @intCast(height.integer);
                }

                if (tileset_json.object.get("tileGridSize")) |grid_size| {
                    tileset.tile_grid_size = @intCast(grid_size.integer);
                }

                try self.tilesets.append(tileset);
            }
        }

        if (defs.get("enums")) |enums| {
            for (enums.array.items) |enum_json| {
                var enum_def = EnumDef.init(self.allocator);

                if (enum_json.object.get("identifier")) |id| {
                    enum_def.identifier = try self.allocator.dupe(u8, id.string);
                }

                if (enum_json.object.get("uid")) |uid| {
                    enum_def.uid = @intCast(uid.integer);
                }

                if (enum_json.object.get("values")) |values| {
                    for (values.array.items) |value| {
                        try enum_def.values.append(try self.allocator.dupe(u8, value.string));
                    }
                }

                try self.enums.append(enum_def);
            }
        }
    }

    pub fn deinit(self: *Project) void {
        self.file_path.deinit(self.allocator);
        self.allocator.free(self.json_version);
        for (self.layers_defs.items) |*layer_def| {
            layer_def.deinit(self.allocator);
        }
        self.layers_defs.deinit();
        for (self.tilesets.items) |*tileset| {
            tileset.deinit(self.allocator);
        }
        self.tilesets.deinit();
        for (self.entities_defs.items) |*entity_def| {
            entity_def.deinit(self.allocator);
        }
        self.entities_defs.deinit();
        for (self.enums.items) |*enum_def| {
            enum_def.deinit(self.allocator);
        }
        self.enums.deinit();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var project = try Project.loadFromFile(allocator, "level.ldtk");
    defer project.deinit();

    std.debug.print("JSON Version: {s}\n", .{project.json_version});
    std.debug.print("Default Cell Size: {d}\n", .{project.default_cell_size});
    std.debug.print("Default Pivot: ({d}, {d})\n", .{ project.default_pivot.x, project.default_pivot.y });
    std.debug.print("Background Color: r={d}, g={d}, b={d}, a={d}\n\n", .{ project.background_color.r, project.background_color.g, project.background_color.b, project.background_color.a });

    for (project.layers_defs.items, 0..) |layer_def, i| {
        std.debug.print("Layer {d}:\n", .{i});
        std.debug.print("  Identifier: {s}\n", .{layer_def.identifier});
        std.debug.print("  UID: {d}\n", .{layer_def.uid});
        std.debug.print("  Type: {}\n", .{layer_def.layer_type});
        std.debug.print("  Grid Size: {d}\n", .{layer_def.grid_size});
        std.debug.print("  Opacity: {d}\n", .{layer_def.opacity});
        std.debug.print("  Pixel Offset: ({d}, {d})\n", .{ layer_def.px_offset.x, layer_def.px_offset.y });
        if (layer_def.tileset_uid) |tileset_uid| {
            std.debug.print("  Tileset UID: {d}\n", .{tileset_uid});
        } else {
            std.debug.print("  Tileset UID: null\n", .{});
        }
        std.debug.print("  IntGrid Values: {d} items\n", .{layer_def.intgrid_values.items.len});
        for (layer_def.intgrid_values.items) |intgrid_value| {
            std.debug.print("    Value: {d}, Name: {s}, Color: r={d}, g={d}, b={d}, a={d}\n", .{ intgrid_value.value, intgrid_value.name, intgrid_value.color.r, intgrid_value.color.g, intgrid_value.color.b, intgrid_value.color.a });
        }
        std.debug.print("\n", .{});
    }

    for (project.entities_defs.items, 0..) |entity_def, i| {
        std.debug.print("Entity {d}:\n", .{i});
        std.debug.print("  Identifier: {s}\n", .{entity_def.identifier});
        std.debug.print("  UID: {d}\n", .{entity_def.uid});
        std.debug.print("  Size: ({d}, {d})\n", .{ entity_def.size.x, entity_def.size.y });
        std.debug.print("  Color: r={d}, g={d}, b={d}, a={d}\n", .{ entity_def.color.r, entity_def.color.g, entity_def.color.b, entity_def.color.a });
        std.debug.print("  Field Definitions: {d} items\n", .{entity_def.field_defs.items.len});
        for (entity_def.field_defs.items) |field_def| {
            std.debug.print("    Field: {s}, Type: {}\n", .{ field_def.identifier, field_def.field_type });
        }
        std.debug.print("\n", .{});
    }

    for (project.tilesets.items, 0..) |tileset, i| {
        std.debug.print("Tileset {d}:\n", .{i});
        std.debug.print("  Identifier: {s}\n", .{tileset.identifier});
        std.debug.print("  UID: {d}\n", .{tileset.uid});
        std.debug.print("  Relative Path: {s}\n", .{tileset.rel_path.path});
        std.debug.print("  Pixel Width: {d}\n", .{tileset.px_width});
        std.debug.print("  Pixel Height: {d}\n", .{tileset.px_height});
        std.debug.print("  Tile Grid Size: {d}\n", .{tileset.tile_grid_size});
        std.debug.print("  Spacing: {d}\n", .{tileset.spacing});
        std.debug.print("  Padding: {d}\n", .{tileset.padding});
        std.debug.print("\n", .{});
    }

    for (project.enums.items, 0..) |enum_def, i| {
        std.debug.print("Enum {d}:\n", .{i});
        std.debug.print("  Identifier: {s}\n", .{enum_def.identifier});
        std.debug.print("  UID: {d}\n", .{enum_def.uid});
        std.debug.print("  Values: {d} items\n", .{enum_def.values.items.len});
        for (enum_def.values.items) |value| {
            std.debug.print("    {s}\n", .{value});
        }
        std.debug.print("\n", .{});
    }
}
