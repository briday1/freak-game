class_name LegsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"leg_length":  { "type": "float", "min": 20.0, "max": 80.0 },
		"speed":       { "type": "float", "min":  0.0, "max":  1.0 },
		"extra_legs":  { "type": "bool" },  # 4 legs when true
	}

func paint(img: Image, genome: Dictionary) -> void:
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = 32
	var cy: int  = 40
	var ll_px: int  = int(remap(genome["leg_length"] as float, 20.0, 80.0, 6.0, 15.0))
	var base_y: int = cy + bh
	var col: Color    = genome["body_color"]
	var accent: Color = genome["accent_color"]
	var quad: bool    = genome.get("extra_legs", false)

	if quad:
		# QUADRUPED: 4 legs at body corners, front lean forward, back lean back
		var o: int = maxi(2, bw * 3 / 4)
		var pairs: Array = [
			[-o, -1],   # front-left
			[o,  -1],   # front-right (lean side * -1 = outward)
			[-o,  1],   # back-left
			[o,   1],   # back-right
		]
		for pair: Array in pairs:
			var ox: int   = pair[0]
			var lean: int = pair[1]
			var lx: int   = cx + ox
			# Lean: front legs lean forward (negative x), back legs lean backward
			var ey: int   = mini(base_y + ll_px, PC.CANVAS_SIZE - 2)
			var ex: int   = lx - lean * (ll_px / 3)
			PC.line(img, lx, base_y, ex, ey, col, 1)
			# Paw: 3px horizontal line
			PC.line(img, ex - 1, ey, ex + 2, ey, accent)
	else:
		# BIPEDAL: 2 thick legs with T-shaped feet
		var o: int = maxi(2, bw / 2)
		for side: int in [-1, 1]:
			var lx: int = cx + side * o
			var ey: int = mini(base_y + ll_px, PC.CANVAS_SIZE - 2)
			PC.line(img, lx, base_y, lx, ey, col, 1)
			# T-shaped foot: horizontal bar + shadow
			PC.line(img, lx - 2, ey, lx + 2, ey, accent)
			PC.line(img, lx - 1, ey + 1, lx + 2, ey + 1, accent.darkened(0.25))

