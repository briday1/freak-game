# Static helpers for painting pixel art onto a Godot Image.
# Canvas is CANVAS_SIZE × CANVAS_SIZE; callers work in 0-(CANVAS_SIZE-1) space.
#
# Layout convention (portrait sprite — head dominates upper canvas):
#   CX      = 24   horizontal centre
#   HEAD_CY = 18   head centre y — upper ~40% of canvas
#   BY      = 38   body lower-torso centre

const CANVAS_SIZE := 48
const CX          := 24
const HEAD_CY     := 18   # portrait head anchor
const BY          := 38   # portrait body anchor

# ── Factory ────────────────────────────────────────────────────────────────────

## Create a blank transparent canvas image.
static func make_image() -> Image:
	return Image.create(CANVAS_SIZE, CANVAS_SIZE, false, Image.FORMAT_RGBA8)

# ── Colour palette ─────────────────────────────────────────────────────────────

## Derive a rich, vivid, harmonious palette from just the genome colour keys.
## Returns a Dictionary with keys: body, belly, shadow, highlight,
##                                  accent, spot, outline, shine.
static func palette(genome: Dictionary) -> Dictionary:
	var base: Color  = genome["body_color"]
	var acc: Color   = genome["accent_color"]

	# Force vivid saturation so we never get muddy greys
	var h: float  = base.h
	var s: float  = maxf(0.55, base.s)
	var v: float  = clampf(base.v, 0.45, 0.92)

	var ah: float = acc.h
	var as2: float = maxf(0.50, acc.s)
	var av: float  = clampf(acc.v, 0.30, 0.85)

	return {
		"body":      Color.from_hsv(h,                          s,                    v),
		"belly":     Color.from_hsv(h,                          s * 0.25,             minf(1.0, v + 0.38)),
		"shadow":    Color.from_hsv(h,                          minf(1.0, s + 0.12),  maxf(0.06, v - 0.36)),
		"highlight": Color.from_hsv(h,                          maxf(0.0, s - 0.30),  minf(1.0,  v + 0.40)),
		"accent":    Color.from_hsv(ah,                         as2,                  av),
		"spot":      Color.from_hsv(fmod(h + 0.52, 1.0),       s * 0.90,             v * 0.78),
		"outline":   Color.from_hsv(h,                          minf(1.0, s + 0.10),  maxf(0.04, v - 0.54)),
		"shine":     Color(1.0, 1.0, 1.0, 0.85),
	}

# ── Ellipse helpers ────────────────────────────────────────────────────────────

## Filled ellipse with separate x/y radii.
static func fill_ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, col: Color) -> void:
	if rx <= 0 or ry <= 0:
		return
	for py: int in range(cy - ry, cy + ry + 1):
		for px: int in range(cx - rx, cx + rx + 1):
			var dx: float = float(px - cx) / float(rx)
			var dy: float = float(py - cy) / float(ry)
			if dx * dx + dy * dy <= 1.0:
				blend(img, px, py, col)

## Outline-only ellipse (1 px border).
static func outline_ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, col: Color) -> void:
	if rx <= 0 or ry <= 0:
		return
	var rx2: int = (rx + 1) * (rx + 1)
	var ry2: int = (ry + 1) * (ry + 1)
	var irx2: int = (rx - 1) * (rx - 1)
	var iry2: int = (ry - 1) * (ry - 1)
	for py: int in range(cy - ry - 1, cy + ry + 2):
		for px: int in range(cx - rx - 1, cx + rx + 2):
			var dx: float = float(px - cx)
			var dy: float = float(py - cy)
			var outer: float = (dx * dx) / float(rx2) + (dy * dy) / float(ry2)
			var inner: float = (dx * dx) / float(irx2) + (dy * dy) / float(iry2)
			if outer <= 1.0 and inner >= 1.0:
				blend(img, px, py, col)

# ── Primitives ─────────────────────────────────────────────────────────────────

static func blend(img: Image, x: int, y: int, col: Color) -> void:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return
	if col.a <= 0.0:
		return
	if col.a >= 1.0:
		img.set_pixel(x, y, col)
		return
	# Alpha composite (src-over)
	var bg: Color    = img.get_pixel(x, y)
	var out_a: float = col.a + bg.a * (1.0 - col.a)
	if out_a <= 0.0:
		return
	img.set_pixel(x, y, Color(
		(col.r * col.a + bg.r * bg.a * (1.0 - col.a)) / out_a,
		(col.g * col.a + bg.g * bg.a * (1.0 - col.a)) / out_a,
		(col.b * col.a + bg.b * bg.a * (1.0 - col.a)) / out_a,
		out_a))

static func fill_rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	for py: int in range(y, y + h):
		for px: int in range(x, x + w):
			blend(img, px, py, col)

## Outline only (1-px border).
static func outline_rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	for px: int in range(x, x + w):
		blend(img, px, y,         col)
		blend(img, px, y + h - 1, col)
	for py: int in range(y + 1, y + h - 1):
		blend(img, x,         py, col)
		blend(img, x + w - 1, py, col)

static func fill_circle(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	for py: int in range(cy - r, cy + r + 1):
		for px: int in range(cx - r, cx + r + 1):
			if (px - cx) * (px - cx) + (py - cy) * (py - cy) <= r * r:
				blend(img, px, py, col)

static func outline_circle(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	var r_inner: int = (r - 1) * (r - 1)
	var r_outer: int = (r + 1) * (r + 1)
	for py: int in range(cy - r - 1, cy + r + 2):
		for px: int in range(cx - r - 1, cx + r + 2):
			var d: int = (px - cx) * (px - cx) + (py - cy) * (py - cy)
			if d >= r_inner and d <= r_outer:
				blend(img, px, py, col)

## Bresenham line with optional fill radius around each point (thick=0 = 1 px).
static func line(img: Image, x0: int, y0: int, x1: int, y1: int, col: Color, thick: int = 0) -> void:
	var dx: int = absi(x1 - x0)
	var dy: int = absi(y1 - y0)
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx - dy
	var x: int = x0
	var y: int = y0
	while true:
		if thick <= 0:
			blend(img, x, y, col)
		else:
			fill_circle(img, x, y, thick, col)
		if x == x1 and y == y1:
			break
		var e2: int = err * 2
		if e2 > -dy:
			err -= dy
			x   += sx
		if e2 < dx:
			err += dx
			y   += sy

## Filled convex polygon via scanline fill.
static func fill_polygon(img: Image, points: Array, col: Color) -> void:
	if points.size() < 3:
		return
	var min_y: int = 9999
	var max_y: int = -9999
	for p: Vector2 in points:
		if int(p.y) < min_y: min_y = int(p.y)
		if int(p.y) > max_y: max_y = int(p.y)
	for scan_y: int in range(min_y, max_y + 1):
		var xs: Array[int] = []
		var n: int = points.size()
		for i: int in range(n):
			var p1: Vector2 = points[i]
			var p2: Vector2 = points[(i + 1) % n]
			if (p1.y <= scan_y and p2.y > scan_y) or (p2.y <= scan_y and p1.y > scan_y):
				var t: float = float(scan_y - p1.y) / float(p2.y - p1.y)
				xs.append(int(p1.x + t * (p2.x - p1.x)))
		xs.sort()
		for i: int in range(0, xs.size() - 1, 2):
			for px: int in range(xs[i], xs[i + 1] + 1):
				blend(img, px, scan_y, col)
