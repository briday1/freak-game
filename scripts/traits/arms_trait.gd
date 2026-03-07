class_name ArmsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"arm_length": { "type": "float", "min": 20.0, "max": 70.0 },
		"has_claws":  { "type": "bool" },
	}

func paint(img: Image, genome: Dictionary) -> void:
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = 32
	var cy: int  = 40
	var al_px: int = int(remap(genome["arm_length"] as float, 20.0, 70.0, 4.0, 12.0))
	var arm_y: int = cy - bh + bh / 3
	var col: Color    = genome["body_color"]
	var accent: Color = genome["accent_color"]
	var claws: bool   = genome.get("has_claws", false)

	for side: int in [-1, 1]:
		var ax: int = cx + side * bw
		var ex: int = ax + side * al_px
		var ey: int = arm_y + al_px

		if claws:
			# CLAW ARM: thin line + 3-prong claw tips
			PC.line(img, ax, arm_y, ex, ey, accent)
			# Forward prong
			PC.line(img, ex, ey, ex + side * 3, ey - 2, accent)
			# Middle prong (straight down)
			PC.line(img, ex, ey, ex + side,     ey + 3, accent)
			# Back prong
			PC.line(img, ex, ey, ex - side,     ey + 2, accent)
			# Lightened claw tips
			PC.blend(img, ex + side * 3, ey - 2, accent.lightened(0.5))
			PC.blend(img, ex + side,     ey + 3, accent.lightened(0.5))
		else:
			# ROUNDED ARM: thick line + blob hand
			PC.line(img, ax, arm_y, ex, ey, col, 1)
			# Blob hand: outer circle in accent, inner in body color
			PC.fill_circle(img, ex, ey, 3, accent)
			PC.fill_circle(img, ex, ey, 2, col)

