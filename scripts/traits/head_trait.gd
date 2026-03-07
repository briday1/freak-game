class_name HeadTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"head_size": { "type": "float", "min": 20.0, "max": 70.0 },
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	var hs  := genome["head_size"]  as float
	var bh  := genome["body_height"] as float
	var hc  := Vector2(150.0, 250.0 - bh * 0.5 - hs * 0.6)
	canvas.draw_circle(hc, hs, genome["body_color"])
	canvas.draw_arc(hc, hs, 0.0, TAU, 32, genome["accent_color"], 3.0)
