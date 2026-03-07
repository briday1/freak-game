class_name EyesTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"eye_spacing": { "type": "float", "min":  5.0, "max": 30.0 },
		"eye_size":    { "type": "float", "min":  3.0, "max": 15.0 },
		"eye_color":   { "type": "color",
			"min": Color(0.0, 0.0, 0.0), "max": Color(1.0, 1.0, 1.0) },
	}

func paint(img: Image, genome: Dictionary) -> void:
	var hc: Vector2i = HeadTrait.head_center(genome)
	var r: int       = HeadTrait.head_radius(genome)
	var esp: int     = int(remap(genome["eye_spacing"] as float, 5.0, 30.0, 1.0, 5.0))
	var esz: int     = int(remap(genome["eye_size"]    as float, 3.0, 15.0, 1.0, 5.0))
	var pal := PC.palette(genome)
	var col: Color   = pal["spot"]
	var goofy: float = genome.get("goofiness", 0.0) as float
	var eye_y: int   = hc.y - 1

	if goofy < 0.3:
		# ANGRY: diagonal slash eyes angled inward — fierce look
		for side: int in [-1, 1]:
			var ex: int      = hc.x + side * esp
			var inner_y: int = eye_y - 1
			var outer_y: int = eye_y + 1
			var y0: int      = inner_y if side == 1  else outer_y
			var y1: int      = outer_y if side == 1  else inner_y
			PC.line(img, ex - esz, y0, ex + esz, y1, col)
		# Heavy brow ridge
		PC.line(img, hc.x - esp - esz + 1, eye_y - 2, hc.x - 2, eye_y - 1, col.darkened(0.25))
		PC.line(img, hc.x + 2, eye_y - 1, hc.x + esp + esz - 1, eye_y - 2, col.darkened(0.25))

	elif goofy < 0.68:
		# NEUTRAL: simple round beady eyes
		for side: int in [-1, 1]:
			var ex: int = hc.x + side * esp
			if esz >= 2:
				PC.fill_circle(img, ex, eye_y, esz, Color.WHITE)
				PC.fill_circle(img, ex, eye_y, esz - 1, col)
				PC.blend(img, ex, eye_y, Color.BLACK)
			else:
				PC.blend(img, ex - 1, eye_y, Color.WHITE)
				PC.blend(img, ex,     eye_y, col)

	else:
		# CUTE: big sparkling cartoon eyes
		var big: int = esz + 1
		for side: int in [-1, 1]:
			var ex: int = hc.x + side * esp
			PC.fill_circle(img, ex, eye_y, big, Color.WHITE)
			PC.fill_circle(img, ex, eye_y, big - 1, col)
			PC.blend(img, ex, eye_y, Color.BLACK)
			# Sparkle highlights
			PC.blend(img, ex - 1, eye_y - big + 1, Color(1, 1, 1, 0.95))
			PC.blend(img, ex + 1, eye_y + big - 2, col.lightened(0.55))
		# Eyelash flicks outward
		if r >= 6:
			for side: int in [-1, 1]:
				var lx: int = hc.x + side * (esp + big + 1)
				PC.line(img, lx, eye_y - big, lx + side, eye_y - big - 2, col.darkened(0.15))


