class_name HornsTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"has_horns": { "type": "bool" },
		"horn_size": { "type": "float", "min": 8.0, "max": 40.0 },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	if not genome.get("has_horns", false):
		return
	var hs   := genome["head_size"]    as float
	var bh   := genome["body_height"]  as float
	var hc   := Vector2(150.0, 250.0 - bh * 0.5 - hs * 0.6)
	var horn := genome["horn_size"]    as float
	var es   := genome.get("eye_spacing", 12.0) as float
	var col  := genome["accent_color"] as Color
	for side in [-1.0, 1.0]:
		var bx     := hc.x + (side as float) * es * 1.2
		var tip    := Vector2(bx, hc.y - hs - horn)
		var base_l := Vector2(bx - horn * 0.35, hc.y - hs + 4.0)
		var base_r := Vector2(bx + horn * 0.35, hc.y - hs + 4.0)
		canvas.draw_polygon(
			PackedVector2Array([tip, base_l, base_r]),
			PackedColorArray([col, col, col]))
