class_name BodyTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")
const CX := PC.CX
const BY := PC.BY

func get_schema() -> Dictionary:
	return {
		"body_width":   { "type": "float", "min":  40.0, "max": 120.0 },
		"body_height":  { "type": "float", "min":  60.0, "max": 160.0 },
		"roundness":    { "type": "float", "min":   0.0, "max":   1.0 },
		"strength":     { "type": "float", "min":   0.0, "max":   1.0 },
		"pattern":      { "type": "float", "min":   0.0, "max":   1.0 },
		"body_color":   { "type": "color",
			"min": Color(0.1, 0.0, 0.0), "max": Color(1.0, 1.0, 1.0) },
		"accent_color": { "type": "color",
			"min": Color(0.0, 0.0, 0.1), "max": Color(1.0, 1.0, 1.0) },
	}

## Returns body half-size as Vector2i(bw, bh) in canvas pixels.
static func body_half_size(genome: Dictionary) -> Vector2i:
	return Vector2i(
		int(remap(genome["body_width"]  as float, 40.0, 120.0, 8.0, 14.0)),
		int(remap(genome["body_height"] as float, 60.0, 160.0, 3.0,  6.0)))

# Body stamp templates — different shapes/patterns.
# Stamped with centre pixel at (CX, BY). Each is 21 wide x 13 tall, anchor (10,6).
const BODY_ROUND := [
	"......................",
	"....OOOOOOOOOOo.......",
	"...OBBBBBbbbBBBO......",
	"..OBBBBBbbbbbBBBO.....",
	"..OBBBBBbbbbbBBBO.....",
	"..OBBBBBBBBBBsBBO.....",
	"..OBBBBBBBBBBsBBO.....",
	"..OBBBBBBBBBBsBBO.....",
	"...OBBBBBBBBsBBO......",
	"....OOOOOOOOOOO.......",
	"......................",
	"......................",
	"......................",
]
const BODY_WIDE := [
	"......................",
	"..OOOOOOOOOOOOOOo....",
	".OBBBBBBbbbBBBBBBO...",
	"OBBBBBBBbbbbbBBBBBBO.",
	"OBBBBBBBbbbbbBBBBBBO.",
	"OBBBBBBBBBBBBsBBBBBO.",
	"OBBBBBBBBBBBBsBBBBBO.",
	".OBBBBBBBBBBBsBBBBO..",
	"..OBBBBBBBBBBBBBBOO..",
	"...OOOOOOOOOOOOOOO...",
	"......................",
	"......................",
	"......................",
]
const BODY_ARMOR := [
	"......................",
	"AAOOOOOOOOOOOOOOOAAO..",
	"AAOBBBBbbbbbBBBBAAO..",
	"AAOBBBBbbbbbBBBBAAO..",
	"AAOBBBBBBBBBBBBBsBO..",
	"AAOBBBBBBBBBBBBBsBsO.",
	"AAOBBBBBBBBBBBBBsBO..",
	"AAOBBBBbbbbbBBBBAAO..",
	"AAOOOOOOOOOOOOOOOAAO..",
	"......................",
	"......................",
	"......................",
	"......................",
]
const BODY_SPOTS := [
	"......................",
	"....OOOOOOOOOOo.......",
	"...OBBSBBBbbbBBO......",
	"..OBBBBSBbbbbbBBO.....",
	"..OBBSBBBbbbbbBBO.....",
	"..OBBBBBBBBBBsBBO.....",
	"..OBSBBBBBBBBsBBO.....",
	"..OBBBBSBBBBBsBBO.....",
	"...OBBBBBBBBsBBO......",
	"....OOOOOOOOOOO.......",
	"......................",
	"......................",
	"......................",
]

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal: Dictionary = PC.palette(genome)
	var round: float = genome["roundness"] as float
	var pat: float   = genome.get("pattern", 0.0) as float

	# Neck connector (3px wide, from head bottom to body top)
	var hr: int       = HeadTrait.head_radius(genome)
	var neck_top: int = PC.HEAD_CY + hr - 1
	var neck_bot: int = BY - 5
	if neck_bot > neck_top:
		PC.fill_rect(img, CX - 2, neck_top, 5, neck_bot - neck_top, pal["body"])
		PC.blend(img, CX - 2, neck_top, pal["outline"])
		PC.blend(img, CX + 2, neck_top, pal["outline"])

	# Pick body stamp
	var tmpl: Array
	if round >= 0.65:
		tmpl = BODY_ROUND
	elif round >= 0.30:
		tmpl = BODY_WIDE if pat < 0.5 else BODY_SPOTS
	else:
		tmpl = BODY_ARMOR
	PC.stamp(img, CX - 10, BY - 6, tmpl, pal)
	return img

static func _inside_body(px: int, py: int, bw: int, bh: int, round: float) -> bool:
	if round >= 0.30:
		var dx: float = float(px - CX) / float(bw + (2 if round < 0.65 else 0))
		var dy: float = float(py - BY) / float(bh)
		return dx * dx + dy * dy <= 1.05
	return px >= CX - bw and px <= CX + bw and py >= BY - bh and py <= BY + bh

