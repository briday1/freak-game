# Full-body Pokemon-style sprite painter.
# One full-figure stamp per creature type; 4-colour Pokemon palette.
# Stamp chars: O=outline  B=body  b=belly/light  s=shadow  A=accent  .=skip

class_name SpritePainter

const PC := preload("res://scripts/pixel_canvas.gd")

# ---- Duck -------------------------------------------------------------------
# Fat round duck facing right: head, bill (accent), round body, accent feet.
# stamp at (ox=3, oy=2)
const DUCK_ROWS: Array = [
    "............OOOOOOOOOOOO....................",
    "...........OBBBBBBBBBBBO....................",
    "...........OBBBsBBBBBBBO......OOOO.........",
    "...........OBBBsBBBBBBBOOOOOOAAAAO.........",
    "...........OBBBsBBBBBBBOOOOOOAAAAO.........",
    "...........OBBBsBBBBBBBO......OOOO.........",
    "...........OBBBBBBBBBBBO....................",
    "............OOOOOOOOOOOO....................",
    "............................................",
    ".......OOOOOOOOOOOOOOOOOOOO.................",
    ".......OBBBBBBBBBBBBBBBBsBO................",
    "......OBBBBBBBBBBBBBBBBBsBO................",
    "......OBBBBBbbbbbbbbbBBBBsBO...............",
    "......OBBBBBbbbbbbbbbBBBBsBO...............",
    "......OBBBBBBBBBBBBBBBBBsBO................",
    ".......OBBBBBBBBBBBBBBBBsO..................",
    "........OOOOOOOOOOOOOOOOOO...................",
    "............................................",
    ".........OOOOO...OOOOO......................",
    ".........OBBBO...OBBBO......................",
    ".........OBBBO...OBBBO......................",
    "........OAAAAOO..OAAAAO.....................",
    "........OAAAAAO..OAAAAO.....................",
    "........OOOOOOO..OOOOOO.....................",
]

# ---- Dragon -----------------------------------------------------------------
# Upright bipedal dragon: spread wings, horns, snout, clawed feet, tail.
# stamp at (ox=0, oy=0)
const DRAGON_ROWS: Array = [
    "..........O..............O..................",
    "..........OA.............AO.................",
    "..........OAA...........AAO.................",
    "........OOAAOOOOOOOOOAAOO...................",
    ".......OBBBBBBBBBBBBBBBBsO..................",
    ".......OBBBsBBBBBBBBBsBsO....OOOO..........",
    ".......OBBBBBBBBBBBBBBBBbOOOOOAAAAO........",
    ".......OBBBBBBBBBBBBBBBBbOOOOOAAAAO........",
    ".......OBBBsBBBBBBBBBsBsO....OOOO..........",
    "........OOOOOOOOOOOOOOOOOO...................",
    "OsO.....OOOOOOOOOOOOOOOOOOO.....OsO.........",
    "OsBsO...OBBBBBBBBBBBBBBBBsO...OsBsO........",
    "OsBBsO.OBBBBBbbbbbbBBBBBBsO.OsBBsO.........",
    "OsABBsOOBBBBBbbbbbbBBBBBBsOOsBBAsO.........",
    "OsAABsOOBBBBBBBBBBBBBBBBBsOOsBBAsO.........",
    ".OsAbsOOBBBBBBBBBBBBBBBBBsOOsAbsO..........",
    "..OsssOOBBBBBBBBBBBBBBBBBsOOsssO...........",
    "...OssOOBBBBBBBBBBBBBBBBBsOOssO............",
    "....OsOOOBBBBBBBBBBBBBBBBsOOOsO............",
    ".....OOOBBBBBBBBBBBBBBBBBsOOO..............",
    ".....OOOBBBBBBBBBBBBBBBBBsOO................",
    "......OOBBBBBBBBBBBBBBBBBbOO................",
    ".......OOOOOOOOOOOOOOOOOOOO..................",
    ".......OO....OOOOOOOO....OO..................",
    "......OBO....OBBBBBBO....OBO................",
    "......OsO....OBBBBBsO....OsO.....OOOO......",
    "......OAO....OBBBBBsO....OAO....OsBBO......",
    "...OOOAAOO..OBBBBBBsO..OOAAOO...OsBBO......",
    "...OAAAAAO..OOOOOOOOO..OAAAAAO...OsbbO......",
    "...OOOOO..............OOOOO.....OOOOOO......",
]

# ---- Human ------------------------------------------------------------------
# Humanoid: head, shoulders, arms, torso with belt, legs, accent boots.
# stamp at (ox=6, oy=2)
const HUMAN_ROWS: Array = [
    "......OOOOOOOOOOOO....................",
    "......OBBBBsBBBBBO....................",
    ".....OBBBBsBBBBBBO....................",
    ".....OBBBBBBBBBBbO....................",
    ".....OBBBBBBBBBBbO....................",
    ".....OBBBBBBBBBBbO....................",
    "......OBBBBBBBBBbO....................",
    ".......OOOOOOOOOO....................",
    "...OOOOOOOOOOOOOOOOOOOO..................",
    "...OBBBBBBBBBBBBBBBBBBO..................",
    "..OBBsO.OBBBBBBBBBbO.OBBsO..............",
    "..OBBsO.OBBBbbBBBBbO.OBBsO..............",
    "..OBBsO.OBBBbbBBBBbO.OBBsO..............",
    "..OBBsO.OBBBBBBBBBbO.OBBsO..............",
    "..OBBsO.OBBBBBBBBBbO.OBBsO..............",
    "...OsO..OBBBBBBBBBBO..OsO..................",
    ".........OAAAAAAAAAO...................",
    ".........OOOOOOOOOOO...................",
    ".........OBBBBBBBBbO...................",
    ".........OBBBBBBBBbO...................",
    "........OOOOOOOOOOOOOO.................",
    ".......OBBsO....OBBsO...................",
    ".......OBBsO....OBBsO...................",
    ".......OBBsO....OBBsO...................",
    ".......OBBsO....OBBsO...................",
    ".......OBBsO....OBBsO...................",
    "......OBBBsO....OBBBsO..................",
    "......OAAAAO....OAAAAO..................",
    "......OAAAAO....OAAAAO..................",
    ".....OOOOOOO..OOOOOOO...................",
]

# ---- Paint ------------------------------------------------------------------

## Full-body portrait sprite for the creature genome.
## If genome contains _blend_type + _blend_weight, pixel-lerps two type stamps
## so a bred creature looks like a genuine visual mix of both parents.
static func paint(genome: Dictionary) -> Image:
    var pal        := _pokemon_palette(genome)
    var t: String   = genome.get("_type", "human") as String
    var t2: String  = genome.get("_blend_type", "") as String
    var w: float    = clampf(genome.get("_blend_weight", 0.0) as float, 0.0, 1.0)

    var img_a := PC.make_image()
    _stamp_type(img_a, t, pal)

    if t2 == "" or w <= 0.0:
        return img_a

    # Build a genome that uses blended colors for the secondary stamp too
    var pal2 := _pokemon_palette(genome)
    var img_b := PC.make_image()
    _stamp_type(img_b, t2, pal2)

    # Pixel-lerp: each pixel = lerp(a, b, w); transparent in one = use the other
    var out := PC.make_image()
    var sz := PC.CANVAS_SIZE
    for y in range(sz):
        for x in range(sz):
            var ca: Color = img_a.get_pixel(x, y)
            var cb: Color = img_b.get_pixel(x, y)
            if ca.a <= 0.0 and cb.a <= 0.0:
                continue
            elif ca.a <= 0.0:
                out.set_pixel(x, y, Color(cb.r, cb.g, cb.b, cb.a * w))
            elif cb.a <= 0.0:
                out.set_pixel(x, y, Color(ca.r, ca.g, ca.b, ca.a * (1.0 - w)))
            else:
                out.set_pixel(x, y, ca.lerp(cb, w))
    return out

## Stamp the sprite rows for a given type onto img.
static func _stamp_type(img: Image, t: String, pal: Dictionary) -> void:
    match t:
        "duck":
            PC.stamp(img, 3, 2, DUCK_ROWS, pal)
        "dragon":
            PC.stamp(img, 0, 0, DRAGON_ROWS, pal)
        _:
            PC.stamp(img, 6, 2, HUMAN_ROWS, pal)

## 4-colour Pokemon-style palette derived from genome body/accent colours.
## Produces: outline (darkest), shadow, body (mid), belly (lightest), accent.
static func _pokemon_palette(genome: Dictionary) -> Dictionary:
    var base: Color = genome["body_color"]
    var acc: Color  = genome["accent_color"]

    var h: float    = base.h
    var s: float    = maxf(0.65, base.s)
    var v_mid: float = clampf(base.v, 0.55, 0.75)

    var ah:  float = acc.h
    var as2: float = maxf(0.55, acc.s)
    var av:  float = clampf(acc.v, 0.45, 0.80)

    return {
        "body":      Color.from_hsv(h,  s,                    v_mid),
        "belly":     Color.from_hsv(h,  s * 0.18,             0.96),
        "shadow":    Color.from_hsv(h,  minf(1.0, s + 0.10),  maxf(0.10, v_mid - 0.30)),
        "highlight": Color.from_hsv(h,  s * 0.10,             1.00),
        "outline":   Color.from_hsv(h,  minf(1.0, s + 0.15),  maxf(0.05, v_mid - 0.58)),
        "accent":    Color.from_hsv(ah, as2,                  av),
        "spot":      Color.from_hsv(ah, as2 * 0.80,           minf(1.0, av + 0.20)),
    }
