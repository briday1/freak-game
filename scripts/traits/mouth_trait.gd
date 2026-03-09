class_name MouthTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"mouth_width":     { "type": "float", "min": 5.0,  "max": 40.0 },
		"goofiness":       { "type": "float", "min": 0.0,  "max":  1.0 },
		"bill_size":       { "type": "float", "min": 0.0,  "max":  0.0 },  # duck overrides
		"bill_tip_offset": { "type": "float", "min": 0.0,  "max":  0.0 },  # duck overrides; tip skew
	}

# Mouth stamps — 9 wide, 4 tall. Stamp centred at hc.x - 4.
# 'K'=black outline  'W'=teeth  'A'=tongue/accent  'H'=highlight
const MOUTH_GRIN := [
	"KKKKKKKKK",
	"KWKWKWKKK",
	"KAAAAAAKK",
	".KKKKKKK.",
]
const MOUTH_FLAT := [
	".........",
	".KKKKKKK.",
	".........",
	".........",
]
const MOUTH_FROWN := [
	".........",
	"K.......K",
	".KKKKKKK.",
	".........",
]
const MOUTH_BILL := [
	".HHHHH...",
	"HAAAAAHO.",
	".AAAAHO..",
	"..KKOO...",
]

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var hc: Vector2i  = HeadTrait.head_center(genome)
	var r: int        = HeadTrait.head_radius(genome)
	var goofy: float  = genome.get("goofiness", 0.0) as float
	var bill: float   = genome.get("bill_size", 0.0) as float
	var pal := PC.palette(genome)
	var my: int = hc.y + r - 3
	var tmpl: Array
	if bill > 2.0:
		tmpl = MOUTH_BILL
		my = hc.y + 1
	elif goofy < 0.25:
		tmpl = MOUTH_FROWN
	elif goofy < 0.65:
		tmpl = MOUTH_FLAT
	else:
		tmpl = MOUTH_GRIN
	PC.stamp(img, hc.x - 4, my, tmpl, pal)
	return img
