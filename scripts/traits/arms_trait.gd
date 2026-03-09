class_name ArmsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"arm_length": { "type": "float", "min": 20.0, "max": 70.0 },
		"has_claws":  { "type": "bool" },
	}

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = PC.CX
	var cy: int  = PC.BY
	var al_px: int = int(remap(genome["arm_length"] as float, 20.0, 70.0, 3.0, 10.0))
	var arm_y: int = cy - bh + bh / 3
	var pal := PC.palette(genome)
	var claws: bool = genome.get("has_claws", false)

	for side: int in [-1, 1]:
		var ax: int    = cx + side * bw
		var ex: int    = ax + side * al_px
		var ey: int    = arm_y + al_px
		var mid_x: int = ax + side * al_px / 2
		var mid_y: int = arm_y + al_px / 2

		if claws:
			# CLAW ARM: thin line + shoulder dot + 3-prong claw tips
			PC.fill_circle(img, ax, arm_y, 2, pal["shadow"])
			PC.line(img, ax, arm_y, ex, ey, pal["accent"])
			PC.fill_circle(img, mid_x, mid_y, 1, pal["outline"])
			PC.line(img, ex, ey, ex + side * 4, ey - 2, pal["accent"])
			PC.line(img, ex, ey, ex + side,     ey + 4, pal["accent"])
			PC.line(img, ex, ey, ex - side,     ey + 3, pal["accent"])
			PC.blend(img, ex + side * 4, ey - 2, pal["shine"])
			PC.blend(img, ex + side,     ey + 4, pal["shine"])
		else:
			# ROUNDED ARM: thick line + shoulder + elbow joint + blob hand
			PC.fill_circle(img, ax, arm_y, 2, pal["shadow"])
			PC.line(img, ax, arm_y, ex, ey, pal["body"], 1)
			PC.fill_circle(img, mid_x, mid_y, 2, pal["accent"])
			PC.fill_circle(img, mid_x, mid_y, 1, pal["highlight"])
			PC.fill_circle(img, ex, ey, 3, pal["accent"])
			PC.fill_circle(img, ex, ey, 2, pal["body"])
			var sh: Color = pal["shine"]; sh.a = 0.7
			PC.blend(img, ex - 1, ey - 1, sh)
	return img
