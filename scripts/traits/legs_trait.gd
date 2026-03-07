class_name LegsTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"leg_length":  { "type": "float", "min": 20.0, "max": 80.0 },
		"speed":       { "type": "float", "min":  0.0, "max":  1.0 },
		"extra_legs":  { "type": "bool" },  # 4 legs when true
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	var cx     := 150.0
	var bh     := genome["body_height"] as float
	var body_bottom := 250.0 + bh * 0.5
	var offset := (genome["body_width"] as float) * 0.25
	var y1     := body_bottom + (genome["leg_length"] as float)
	var col    := genome["accent_color"] as Color
	canvas.draw_line(Vector2(cx - offset, body_bottom), Vector2(cx - offset, y1), col, 6.0)
	canvas.draw_line(Vector2(cx + offset, body_bottom), Vector2(cx + offset, y1), col, 6.0)
