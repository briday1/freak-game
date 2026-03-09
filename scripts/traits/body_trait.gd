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

# ── Duck body: wide egg, prominent belly patch ──────────────────────────────
# 24 wide x 10 tall. Anchor: col 12, row 4
const BODY_DUCK := [
	"....OOOOOOOOOOOOOO......",
	"...OBBBBBBBBBBBBsBo.....",
	"..OBBBBBbbbbbbBBBBO.....",
	"..OBBBBBbbbbbbBBBBO.....",
	"..OBBBBBBBBBBBBBsBo.....",
	"..OBBBBBBBBBBBBBsBo.....",
	"...OBBBBBBBBBBBsBo......",
	"....OOOOOOOOOOOOO.......",
	"........................",
	"........................",
]
# ── Dragon body: barrel chest, armored shoulder plates ──────────────────────
# 28 wide x 10 tall. Anchor: col 14, row 4
const BODY_DRAGON := [
	"AAAOOOOOOOOOOOOOOOOOAAA.",
	"AAOBBBBBBBBBBBBBBBBBAAo",
	"AOBBBBBBbbbbbbBBBBBBBAo.",
	"OBBBBBBBbbbbbbBBBBBBBBO.",
	"OBBBBBBBBBBBBBsBBBBBBBO.",
	"OBBBBBBBBBBBBBsBBBBBBBO.",
	"AOBBBBBBbbbbbbBBBBBBAAo.",
	"AAOOOOOOOOOOOOOOOOOAAAO.",
	"........................",
	"........................",
]
# ── Human body: shoulders, chest, narrow waist ───────────────────────────────
# 20 wide x 10 tall. Anchor: col 10, row 4
const BODY_HUMAN := [
	"....OOOOOOOOOOO......",
	"...OBBBBBsBBBBBo.....",
	"..OBBBBBBsBBBBBBo....",
	"..OBBBBBBBBBBBBBo....",
	"..OBBBbbbbbbBBBBo....",
	"..OBBBbbbbbbBBBBo....",
	"...OBBBBBBBBBBBo.....",
	"....OOOOOOOOOOO......",
	".....................",
	".....................",
]

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal: Dictionary = PC.palette(genome)
	var t: String = genome.get("_type", "human") as String
	var tmpl: Array
	var ax: int
	var ay: int
	if t == "duck":
		tmpl = BODY_DUCK
		ax = 12; ay = 4
	elif t == "dragon":
		tmpl = BODY_DRAGON
		ax = 14; ay = 4
	else:
		tmpl = BODY_HUMAN
		ax = 10; ay = 4

	# Neck connector
	var hr: int       = HeadTrait.head_radius(genome)
	var neck_top: int = PC.HEAD_CY + hr - 1
	var neck_bot: int = BY - ay
	if neck_bot > neck_top:
		PC.fill_rect(img, CX - 2, neck_top, 5, neck_bot - neck_top, pal["body"])
		PC.blend(img, CX - 2, neck_top, pal["outline"])
		PC.blend(img, CX + 2, neck_top, pal["outline"])

	PC.stamp(img, CX - ax, BY - ay, tmpl, pal)
	return img

static func _inside_body(px: int, py: int, bw: int, bh: int, round: float) -> bool:
	if round >= 0.30:
		var dx: float = float(px - CX) / float(bw + (2 if round < 0.65 else 0))
		var dy: float = float(py - BY) / float(bh)
		return dx * dx + dy * dy <= 1.05
	return px >= CX - bw and px <= CX + bw and py >= BY - bh and py <= BY + bh

