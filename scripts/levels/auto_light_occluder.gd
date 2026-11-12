extends Node

func _ready() -> void:
	var tile_map := get_parent().get_node_or_null("TileMap") as TileMap
	if tile_map == null:
		return
	_setup(tile_map)


func _setup(tile_map: TileMap) -> void:
	var ts := tile_map.tile_set

	if ts.get_occlusion_layers_count() == 0:
		ts.add_occlusion_layer()

	var processed := {}

	for cell in tile_map.get_used_cells(0):
		var src_id := tile_map.get_cell_source_id(0, cell)
		var atlas_coords := tile_map.get_cell_atlas_coords(0, cell)
		var alt_id := tile_map.get_cell_alternative_tile(0, cell)

		var key := Vector3i(src_id, atlas_coords.x * 1000 + atlas_coords.y, alt_id)
		if processed.has(key):
			continue
		processed[key] = true

		var src := ts.get_source(src_id) as TileSetAtlasSource
		if src == null:
			continue

		var td := src.get_tile_data(atlas_coords, alt_id)
		if td == null or td.get_collision_polygons_count(0) == 0:
			continue
		if td.get_occluder(0) != null:
			continue

		var occ := OccluderPolygon2D.new()
		occ.polygon = PackedVector2Array([
			Vector2(-16, -16), Vector2(16, -16),
			Vector2(16, 16), Vector2(-16, 16)
		])
		td.set_occluder(0, occ)
