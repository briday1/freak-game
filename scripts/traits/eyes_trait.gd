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

# Eye stamps — 5 wide, 4 tall. Stamp left eye at (hc.x-7, ey), right at (hc.x+3, ey).
# 'S'=iris/spot  'K'=pupil  'W'=white  'O'=outline/lash
const EYE_CUTE := [
	".OOO.",
	"OWWWO",
	"OWSKO",
	".OOO.",
]
const EYE_MAD := [
	"OOO..",
	".SSO.",
	"..SO.",
	"..OO.",
]
const EYE_ROUND := [
	".OO..",
	"OWSO.",
	"OKSO.",
	".OO..",
]

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var hc: Vector2i = HeadTrait.head_center(genome)
	var goofy: float = genome.get("goofiness", 0.0) as float
	var pal := PC.palette(genome)
	var tmpl: Array
	if goofy < 0.3:
		tmpl = EYE_MAD
	elif goofy < 0.68:
		tmpl = EYE_ROUND
	else:
		tmpl = EYE_CUTE
	var ey: int = hc.y - 1
	# stamp left eye mirrored
	var left: Array = []
	for row: String in tmpl:
		left.append(row.reverse())
	PC.stamp(img, hc.x - 8, ey, left, pal)
	PC.stamp(img, hc.x + 3, ey, tmpl, pal)
	return img

