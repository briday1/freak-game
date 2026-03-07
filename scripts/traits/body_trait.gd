class_name BodyTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"body_width":   { "type": "float", "min":  40.0, "max": 120.0 },
		"body_height":  { "type": "float", "min":  60.0, "max": 160.0 },
		"roundness":    { "type": "float", "min":   0.0, "max":   1.0 },
		"strength":     { "type": "float", "min":   0.0, "max":   1.0 },
		"body_color":   { "type": "color",
			"min": Color(0.4, 0.4, 0.4), "max": Color(1.0, 1.0, 1.0) },
		"accent_color": { "type": "color",
			"min": Color(0.1, 0.1, 0.1), "max": Color(0.7, 0.7, 0.7) },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	var bw := genome["body_width"]  as float
	var bh := genome["body_height"] as float
	var br := Rect2(150.0 - bw * 0.5, 250.0 - bh * 0.5, bw, bh)
	canvas.draw_rect(br, genome["body_color"])
	canvas.draw_rect(br, genome["accent_color"], false, 3.0)
