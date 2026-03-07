class_name ArmsTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"arm_length": { "type": "float", "min": 20.0, "max": 70.0 },
		"has_claws":  { "type": "bool" },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	var bw    := genome["body_width"]  as float
	var bh    := genome["body_height"] as float
	var left  := 150.0 - bw * 0.5
	var right := 150.0 + bw * 0.5
	var top   := 250.0 - bh * 0.5
	var al    := genome["arm_length"] as float
	var col   := genome["accent_color"] as Color
	var mid_y := top + bh * 0.35
	canvas.draw_line(Vector2(left,  mid_y), Vector2(left  - al * 0.7, mid_y + al * 0.7), col, 5.0)
	canvas.draw_line(Vector2(right, mid_y), Vector2(right + al * 0.7, mid_y + al * 0.7), col, 5.0)
