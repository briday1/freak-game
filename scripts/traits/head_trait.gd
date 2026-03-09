class_name HeadTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"head_size": { "type": "float", "min": 20.0, "max": 70.0 },
	}

## Head is always anchored at the portrait head centre — dominates upper canvas.
static func head_center(genome: Dictionary) -> Vector2i:
	return Vector2i(PC.CX, PC.HEAD_CY)

## Head radius — large so the face fills the sprite (Pokemon style).
static func head_radius(genome: Dictionary) -> int:
	return int(remap(genome["head_size"] as float, 20.0, 70.0, 10.0, 14.0))

# Three head stamp templates — 19 wide, 15 tall, centred at (9, 7) within stamp.
# Stamped so that pixel (9,7) lands on head_center().
const HEAD_ROUND := [
	"....OOOOOOOOO....",
	"..OBBBBsBBBBBO...",
	".OBBBBBsBBBBBBO..",
	"OBBBBBBsBBBHBBBO.",
	"OBBBBBBBBBBHHsBBO",
	"OBBBBBBBBBBBHsBBO",
	"OBBBBBBBBBBBBsBBO",
	"OBBBBBBBBBBBBsBBO",
	"OBBBBBbbbBBBBBBBO",
	"OBBBBbbbbbBBBBBBO",
	".OBBBbbbbbbBBBBO.",
	".OBBBBBBBBBBBBOo.",
	"..OBBBBBBBBBBBOO..",
	"...OOOOOOOOOO....",
	".................",
]
const HEAD_WIDE := [
	"...OOOOOOOOOOOOO...",
	".OBBBBsBBBBBBBBBO.",
	"OBBBBBsBBBBBBBBBBO",
	"OBBssssBBBBBBBBBBO",
	"OBBBBBBBBBBBHHsBBO",
	"OBBBBBBBBBBBBHsBBO",
	"OBBBBBBBBBBBBBsBBO",
	"OBBBBBBBBBBBBBsBBO",
	"OBBBBBbbbbbBBBBBBO",
	"OBBBBbbbbbbbBBBBBO",
	".OBBBBbbbbbBBBBBO.",
	".OOBBBBBBBBBBBBOo.",
	"..OBBBBBBBBBBBBOO..",
	"....OOOOOOOOOOO....",
	"...................",
]
const HEAD_BEAN := [
	"..OOOOOOOOOOO....",
	".OBBBBsBBBBBBO...",
	"OBBBBBsBBBBHBBO..",
	"OBBBBBBBBBHHsBBO.",
	"OBBBBBBBBBBHsBBO.",
	"OBBBBBBBBBBBsBBO.",
	"OBBBBBBBBBBBBsBO.",
	"OBBBBBBBBBBBBsBO.",
	"OABBBbbbBBBBBBBO.",
	".OABbbbbbbbBBBO..",
	"..OBBBBBBBBBBOo..",
	"..OOOOOOOOOOO....",
	".................",
	".................",
	".................",
]

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal: Dictionary = PC.palette(genome)
	var hs: float = genome["head_size"] as float
	var hc := head_center(genome)
	var tmpl: Array
	if hs >= 52.0:
		tmpl = HEAD_WIDE
	elif hs <= 30.0:
		tmpl = HEAD_BEAN
	else:
		tmpl = HEAD_ROUND
	# Stamp centred: anchor pixel is col 9, row 7 of the template
	PC.stamp(img, hc.x - 9, hc.y - 7, tmpl, pal)
	return img
