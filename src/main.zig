const std = @import("std");
const LdtkProject = @import("ldtk.zig").LdtkProject;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var project = try LdtkProject.loadFromFile(allocator, "level.ldtk");
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

    for (project.worlds.items, 0..) |world, i| {
        std.debug.print("World {d}:\n", .{i});
        std.debug.print("  Identifier: {s}\n", .{world.identifier});
        std.debug.print("  IID: {s}\n", .{world.iid});
        std.debug.print("  Layout: {}\n", .{world.layout});
        std.debug.print("  World Grid Width: {d}\n", .{world.world_grid_width});
        std.debug.print("  World Grid Height: {d}\n", .{world.world_grid_height});
        std.debug.print("  Levels: {d} items\n", .{world.levels.items.len});
        for (world.levels.items, 0..) |level, level_idx| {
            std.debug.print("  Level {d}:\n", .{level_idx});
            std.debug.print("    Name: {s}\n", .{level.name});
            std.debug.print("    IID: {s}\n", .{level.iid});
            std.debug.print("    UID: {d}\n", .{level.uid});
            std.debug.print("    Size: ({d}, {d})\n", .{ level.size.x, level.size.y });
            std.debug.print("    Position: ({d}, {d})\n", .{ level.position.x, level.position.y });
            std.debug.print("    Background Color: r={d}, g={d}, b={d}, a={d}\n", .{ level.bg_color.r, level.bg_color.g, level.bg_color.b, level.bg_color.a });
            std.debug.print("    Depth: {d}\n", .{level.depth});
            std.debug.print("    Has Background Image: {}\n", .{level.hasBgImage()});
            std.debug.print("    Layers: {d} items\n", .{level.layers.items.len});

            for (level.layers.items, 0..) |layer, layer_idx| {
                std.debug.print("    Layer {d}:\n", .{layer_idx});
                std.debug.print("      Name: {s}\n", .{layer.getName()});
                std.debug.print("      IID: {s}\n", .{layer.iid});
                std.debug.print("      Type: {}\n", .{layer.getType()});
                std.debug.print("      UID: {d}\n", .{layer.getUid()});
                std.debug.print("      Grid Size: {d}\n", .{layer.grid_size});
                std.debug.print("      Cell Width: {d}\n", .{layer.c_width});
                std.debug.print("      Cell Height: {d}\n", .{layer.c_height});
                std.debug.print("      Opacity: {d}\n", .{layer.opacity});
                std.debug.print("      Visible: {}\n", .{layer.visible});
                std.debug.print("      Total Offset: ({d}, {d})\n", .{ layer.px_total_offset.x, layer.px_total_offset.y });
                std.debug.print("      Entities: {d} items\n", .{layer.entities.items.len});
                std.debug.print("      Tiles: {d} items\n", .{layer.tiles.items.len});
                std.debug.print("      Auto Tiles: {d} items\n", .{layer.auto_tiles.items.len});
                std.debug.print("      IntGrid: {d} items\n", .{layer.intgrid.items.len});

                for (layer.entities.items, 0..) |entity, entity_idx| {
                    std.debug.print("      Entity {d}:\n", .{entity_idx});
                    std.debug.print("        Name: {s}\n", .{entity.getName()});
                    std.debug.print("        IID: {s}\n", .{entity.iid});
                    std.debug.print("        UID: {d}\n", .{entity.getUid()});
                    std.debug.print("        Position: ({d}, {d})\n", .{ entity.position.x, entity.position.y });
                    std.debug.print("        Size: ({d}, {d})\n", .{ entity.size.x, entity.size.y });
                    std.debug.print("        Pivot: ({d}, {d})\n", .{ entity.pivot.x, entity.pivot.y });

                    var field_iter = entity.allFields();
                    var field_count: u32 = 0;
                    while (field_iter.next()) |_| {
                        field_count += 1;
                    }
                    std.debug.print("        Fields: {d} items\n", .{field_count});
                }
                std.debug.print("\n", .{});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
}
