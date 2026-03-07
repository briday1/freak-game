class_name WingsTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"has_wings":     { "type": "bool" },
		"wing_span":     { "type": "float", "min": 0.7, "max": 1.5 },
		"wing_feathers": { "type": "bool" },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	if not genome.get("has_wings", false):
		return
	var bw    := genome["body_width"]  as float
	var bh    := genome["body_height"] as float
	var left  := 150.0 - bw * 0.5
	var right := 150.0 + bw * 0.5
	var top   := 250.0 - bh * 0.5
	var col   := genome["accent_color"] as Color
	var fill  := genome["body_color"]   as Color
	var mid_y := top + bh * 0.2
	for side in [-1.0, 1.0]:
		var attach := Vector2(left if side < 0.0 else right, mid_y)
		var tip    := Vector2(attach.x + (side as float) * bw * 1.4, mid_y - bw * 0.6)
		var lower  := Vector2(attach.x + (side as float) * bw * 0.85, mid_y + bw * 0.3)
		canvas.draw_polygon(
			PackedVector2Array([attach, tip, lower]),
			PackedColorArray([col, col, col]))
		canvas.draw_polyline(
			PackedVector2Array([attach, tip, lower, attach]),
			fill.darkened(0.2), 2.0)
