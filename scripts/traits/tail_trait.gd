class_name TailTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"has_tail":    { "type": "bool" },
		"tail_length": { "type": "float", "min": 20.0, "max": 80.0 },
		"tail_curl":   { "type": "float", "min":  0.0, "max":  1.0 },
	}

func paint(img: Image, genome: Dictionary) -> void:
	if not genome.get("has_tail", false):
		return
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = 32
	var cy: int  = 40
	var tl_px: int = int(remap(genome["tail_length"] as float, 20.0, 80.0, 8.0, 18.0))
	var curl: float = genome["tail_curl"] as float
	var col: Color    = genome["body_color"]
	var accent: Color = genome["accent_color"]

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
		], accent)
		PC.line(img, ax, ay - 1, tip_x, tip_y, accent.lightened(0.4))

	elif curl < 0.7:
		# WAVY: S-curve oscillating angle
		var px: float = float(ax)
		var py: float = float(ay)
		var angle: float = 0.0
		var sign: float  = 1.0
		for i: int in range(tl_px):
			var nx := px + cos(angle)
			var ny := py - sin(angle) * 0.7
			var c: Color = col if i < 4 else accent
			PC.blend(img, int(nx), int(ny), c)
			# Thicker at base
			if i < 5:
				PC.blend(img, int(nx), int(ny) + 1, c)
			px = nx
			py = ny
			# Oscillate direction every few steps
			if i % (maxi(2, tl_px / 4)) == 0:
				sign = -sign
			angle += sign * 0.28

	else:
		# LOOPED: outward spiral
		var px: float  = float(ax)
		var py: float  = float(ay)
		var angle: float = 0.0
		var radius: float = 1.5
		for i: int in range(tl_px):
			var nx := px + cos(angle) * radius / float(tl_px) * 3.0
			var ny := py - sin(angle) * radius / float(tl_px) * 3.0
			var c: Color = col if i < 4 else accent
			PC.blend(img, int(nx), int(ny), c)
			if i < 4:
				PC.blend(img, int(nx), int(ny) + 1, c)
			px = nx
			py = ny
			angle += PI / float(maxi(3, tl_px))
			radius += 1.1

