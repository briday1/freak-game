class_name TailTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"has_tail":    { "type": "bool" },
		"tail_length": { "type": "float", "min": 20.0, "max": 80.0 },
		"tail_curl":   { "type": "float", "min":  0.0, "max":  1.0 },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	if not genome.get("has_tail", false):
		return
	var bw     := genome["body_width"]  as float
	var bh     := genome["body_height"] as float
	var body_right  := 150.0 + bw * 0.5
	var body_bottom := 250.0 + bh * 0.5
	var length := genome["tail_length"] as float
	var curl   := genome["tail_curl"]   as float
	var col    := genome["accent_color"] as Color
	var base   := Vector2(body_right, body_bottom - bh * 0.3)
	var prev   := base
	for i in range(1, 13):
		var t     := float(i) / 12.0
		var angle := t * PI * (0.5 + curl * 1.5)
		var pt    := base + Vector2(cos(angle) * length * t, -sin(angle) * length * t * 0.6)
		canvas.draw_line(prev, pt, col, lerpf(5.0, 2.0, t))
		prev = pt
