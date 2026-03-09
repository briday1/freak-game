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
## Returns a 48x48 RGBA Image; replaces the old multi-trait compositing.
static func paint(genome: Dictionary) -> Image:
    var img := PC.make_image()
    var pal := _pokemon_palette(genome)
    var t: String = genome.get("_type", "human") as String
    match t:
        "duck":
            PC.stamp(img, 3, 2, DUCK_ROWS, pal)
        "dragon":
            PC.stamp(img, 0, 0, DRAGON_ROWS, pal)
        _:
            PC.stamp(img, 6, 2, HUMAN_ROWS, pal)
    return img

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
