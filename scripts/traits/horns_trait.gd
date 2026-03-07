class_name HornsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"has_horns": { "type": "bool" },
		"horn_size": { "type": "float", "min": 8.0, "max": 40.0 },
	}

func paint(img: Image, genome: Dictionary) -> void:
	if not genome.get("has_horns", false):
		return
	var hc := HeadTrait.head_center(genome)
	var hr: int      = HeadTrait.head_radius(genome)
	var hs: float    = genome["head_size"] as float
	var horn_h: int  = int(remap(genome["horn_size"] as float, 8.0, 40.0, 3.0, 10.0))
	var col: Color    = genome["accent_color"]
	var hi: Color     = col.lightened(0.45)

	for side: int in [-1, 1]:
		# Horn base sits on top of the head, inset slightly
		var bx: int    = hc.x + side * (hr / 2)
		var base_y: int = hc.y - hr
		var tip_y: int  = base_y - horn_h
		var hw: int     = maxi(1, horn_h / 3)

		if hs < 18.0:
			# NUBS: small stubby rectangles
			PC.fill_rect(img, bx - 1, tip_y, 3, horn_h, col)
			# Tip highlight
			PC.blend(img, bx, tip_y, hi)

		elif hs < 30.0:
			# SWEPT: wide polygon swept outward
			var sweep: int = horn_h * 2 / 3
			PC.fill_polygon(img, [
				Vector2(bx,            tip_y),
				Vector2(bx - hw,       base_y),
				Vector2(bx + hw,       base_y),
				Vector2(bx + side * sweep, tip_y - 1),
			], col)
			# Edge highlight line on leading face
			PC.line(img, bx, tip_y, bx + side * sweep, tip_y - 1, hi)

		else:
			# DRAMATIC: tall forward-curving spikes — two overlapping polygons
			var curl_x: int = side * horn_h / 2
			# Outer (darker) layer
			PC.fill_polygon(img, [
				Vector2(bx + curl_x,   tip_y - 2),
				Vector2(bx - hw,       base_y),
				Vector2(bx + hw,       base_y),
			], col.darkened(0.15))
			# Inner (lighter) highlight strip
			PC.fill_polygon(img, [
				Vector2(bx + curl_x,   tip_y - 2),
				Vector2(bx,            tip_y + horn_h / 3),
				Vector2(bx + hw / 2,   base_y),
			], hi)
			# Dark outline on outer edge
			PC.line(img, bx - hw, base_y, bx + curl_x, tip_y - 2, col.darkened(0.4))

