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

# Duck head: round chubby ball, cheek pouches
# 20 wide x 10 tall. Anchor: col 10, row 5 → stamp at (hc.x-10, hc.y-5)
const HEAD_DUCK := [
	"....OOOOOOOOOO......",
	"...OBBBHHBBBsBo.....",
	"..OBBBBHHBBBBsBo....",
	"..OBBBBBBBBBBBBo....",
	"..OBBBBBBBBBBBBo....",
	".OBBbbbbbbbbBBBo....",
	".OBBbbbbbbbbBBBo....",
	"..OBBBBBBBBBBBo.....",
	"...OOOOOOOOOOOO.....",
	"....................",
]
# Dragon head: armored brow plates, wide jaw
# 24 wide x 10 tall. Anchor: col 12, row 5
const HEAD_DRAGON := [
	"...AAOOOOOOOOOAAO...",
	"..AAOBBBBBBBBBBAAO..",
	"..AOBBBBBBBBBBBAO...",
	"..OBBBBBBBBBBBBBo...",
	"..OBBBBBBBBBBBBBo...",
	"..OBBBBBBBBBBsBBo...",
	"..OBBBBBBBBBBsBBo...",
	"..OBBBbbbbbBBBBo....",
	"...OOBBBBBBBBOo.....",
	"....OOOOOOOOO.......",
]
# Human head: smooth tall oval with hairline
# 20 wide x 10 tall. Anchor: col 10, row 5
const HEAD_HUMAN := [
	"....OOOOOOOOOO......",
	"...OSSSSSSSSSo......",
	"..OBBBBHBBBBBBo.....",
	"..OBBBBHBBBBBBo.....",
	"..OBBBBBBBBBBBo.....",
	"..OBBBBBBBBBBBo.....",
	"..OBBBBBBBBBBBo.....",
	"..OBBBBBBBBBBBo.....",
	"...OOBBBBBBOOo......",
	"....OOOOOOOO........",
]

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	var pal: Dictionary = PC.palette(genome)
	var hc := head_center(genome)
	var t: String = genome.get("_type", "human") as String
	var tmpl: Array
	var ax: int
	var ay: int
	if t == "duck":
		tmpl = HEAD_DUCK;  ax = 10; ay = 5
	elif t == "dragon":
		tmpl = HEAD_DRAGON; ax = 12; ay = 5
	else:
		tmpl = HEAD_HUMAN;  ax = 10; ay = 5
	PC.stamp(img, hc.x - ax, hc.y - ay, tmpl, pal)
	return img
