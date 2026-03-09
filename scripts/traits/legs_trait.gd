class_name LegsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"leg_length":  { "type": "float", "min": 20.0, "max": 80.0 },
		"speed":       { "type": "float", "min":  0.0, "max":  1.0 },
		"extra_legs":  { "type": "bool" },  # 4 legs when true
	}

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = PC.CX
	var cy: int  = PC.BY
	var ll_px: int  = int(remap(genome["leg_length"] as float, 20.0, 80.0, 5.0, 18.0))
	var base_y: int = cy + bh
	var pal := PC.palette(genome)
	var quad: bool = genome.get("extra_legs", false)

	if quad:
		# QUADRUPED: 4 legs at body corners, knee joints, paws
		var o: int = maxi(2, bw * 3 / 4)
		var pairs: Array = [[-o, -1], [o, -1], [-o, 1], [o, 1]]
		for pair: Array in pairs:
			var ox: int   = pair[0]
			var lean: int = pair[1]
			var lx: int   = cx + ox
			var ey: int   = mini(base_y + ll_px, PC.CANVAS_SIZE - 2)
			var ex: int   = lx - lean * (ll_px / 3)
			var ky: int   = base_y + ll_px / 2
			var kx: int   = lx - lean * (ll_px / 6)
			PC.line(img, lx, base_y, kx, ky, pal["body"], 1)
			PC.fill_circle(img, kx, ky, 2, pal["accent"])
			PC.fill_circle(img, kx, ky, 1, pal["highlight"])
			PC.line(img, kx, ky, ex, ey, pal["body"], 1)
			# Paw
			PC.fill_circle(img, ex, ey, 2, pal["shadow"])
			PC.line(img, ex - 2, ey + 1, ex + 3, ey + 1, pal["accent"])
	else:
		# BIPEDAL: 2 thick legs, knee joint, T-shaped feet
		var o: int = maxi(2, bw / 2)
		for side: int in [-1, 1]:
			var lx: int = cx + side * o
			var ey: int = mini(base_y + ll_px, PC.CANVAS_SIZE - 2)
			var ky: int = base_y + ll_px / 2
			var kx: int = lx + side * 1
			PC.line(img, lx, base_y, kx, ky, pal["body"], 1)
			PC.fill_circle(img, kx, ky, 2, pal["accent"])
			PC.fill_circle(img, kx, ky, 1, pal["highlight"])
			PC.line(img, kx, ky, lx, ey, pal["body"], 1)
			# T-foot
			PC.line(img, lx - 3, ey, lx + 3, ey, pal["accent"])
			PC.line(img, lx - 2, ey + 1, lx + 3, ey + 1, pal["shadow"])
	return img
