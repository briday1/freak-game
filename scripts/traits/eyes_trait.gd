class_name EyesTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"eye_spacing": { "type": "float", "min":  5.0, "max": 30.0 },
		"eye_size":    { "type": "float", "min":  3.0, "max": 15.0 },
		"eye_color":   { "type": "color",
			"min": Color(0.0, 0.0, 0.0), "max": Color(1.0, 1.0, 1.0) },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	var hs    := genome["head_size"]   as float
	var bh    := genome["body_height"] as float
	var hc    := Vector2(150.0, 250.0 - bh * 0.5 - hs * 0.6)
	var es    := genome["eye_spacing"] as float
	var ez    := genome["eye_size"]    as float
	var goofy := genome.get("goofiness", 0.0) as float
	var col   := genome["eye_color"] as Color
	var tilt  := goofy * ez * 1.2
	var positions := [
		Vector2(hc.x - es, hc.y - ez * 0.5 - tilt),
		Vector2(hc.x + es, hc.y - ez * 0.5 + tilt),
	]
	for eye: Vector2 in positions:
		canvas.draw_circle(eye, ez,        Color.WHITE)
		canvas.draw_circle(eye, ez * 0.6,  col)
		canvas.draw_circle(eye, ez * 0.25, Color.BLACK)
