class_name TailTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"has_tail":    { "type": "bool" },
		"tail_length": { "type": "float", "min": 20.0, "max": 80.0 },
		"tail_curl":   { "type": "float", "min":  0.0, "max":  1.0 },
	}

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	if not genome.get("has_tail", false):
		return img
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = PC.CX
	var cy: int  = PC.BY
	var tl_px: int = int(remap(genome["tail_length"] as float, 20.0, 80.0, 6.0, 22.0))
	var curl: float = genome["tail_curl"] as float
	var pal := PC.palette(genome)

	# Attach at right side of body, mid-height
	var ax: int = cx + bw
	var ay: int = cy - bh / 4

	if curl < 0.3:
		# SPIKE: thick tapering polygon + spine highlight
		var tip_x: int = ax + tl_px
		var tip_y: int = ay - tl_px / 4
		PC.fill_polygon(img, [
			Vector2(ax,     ay - 3),
			Vector2(ax,     ay + 3),
			Vector2(tip_x,  tip_y),
		], pal["accent"])
		PC.line(img, ax, ay - 1, tip_x, tip_y, pal["highlight"])

	elif curl < 0.7:
		# WAVY: S-curve oscillating, 2px thick at base
		var px: float = float(ax)
		var py: float = float(ay)
		var angle: float = 0.0
		var sign: float  = 1.0
		for i: int in range(tl_px):
			var nx := px + cos(angle)
			var ny := py - sin(angle) * 0.7
			var t: float = float(i) / float(tl_px)
			var c: Color = pal["body"].lerp(pal["accent"], t)
			PC.blend(img, int(nx), int(ny), c)
			if i < 6:
				PC.blend(img, int(nx), int(ny) + 1, c)
				PC.blend(img, int(nx) + 1, int(ny), c)
			px = nx
			py = ny
			if i % (maxi(2, tl_px / 4)) == 0:
				sign = -sign
			angle += sign * 0.28

	else:
		# LOOPED: outward spiral with gradient
		var px: float  = float(ax)
		var py: float  = float(ay)
		var angle: float = 0.0
		var radius: float = 1.5
		for i: int in range(tl_px):
			var nx := px + cos(angle) * radius / float(tl_px) * 3.0
			var ny := py - sin(angle) * radius / float(tl_px) * 3.0
			var t: float = float(i) / float(tl_px)
			var c: Color = pal["body"].lerp(pal["spot"], t)
			PC.blend(img, int(nx), int(ny), c)
			if i < 5:
				PC.blend(img, int(nx), int(ny) + 1, c)
				PC.blend(img, int(nx) + 1, int(ny), c)
			px = nx
			py = ny
			angle += PI / float(maxi(3, tl_px))
			radius += 1.1
	return img
