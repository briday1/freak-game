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

func paint(img: Image, genome: Dictionary) -> void:
	var hc: Vector2i  = HeadTrait.head_center(genome)
	var r: int        = HeadTrait.head_radius(genome)
	var mouth_y: int  = hc.y + r - 1
	var mw: int       = int(remap(genome["mouth_width"] as float, 5.0, 40.0, 1.0, 5.0))
	var goofy: float  = genome.get("goofiness", 0.0) as float
	var bill: float   = genome.get("bill_size", 0.0) as float

	# ── Duck bill ──────────────────────────────────────────────────────────────
	if bill > 2.0:
		var bh_px: int = int(remap(bill, 2.0, 20.0, 3.0, 7.0))
		var bw_px: int = int(remap(bill, 2.0, 20.0, 3.0, 6.0))
		var skew: int  = int(genome.get("bill_tip_offset", 0.0) as float)
		var acc: Color = genome["accent_color"]
		var yel: Color = acc.lightened(0.35)
		# Upper mandible
		PC.fill_polygon(img, [
			Vector2(hc.x - bw_px, mouth_y - 1),
			Vector2(hc.x + bw_px, mouth_y - 1),
			Vector2(hc.x + skew,  mouth_y + bh_px - 1),
		], yel)
		# Lower mandible (slightly smaller, offset down)
		PC.fill_polygon(img, [
			Vector2(hc.x - bw_px + 1, mouth_y + 1),
			Vector2(hc.x + bw_px - 1, mouth_y + 1),
			Vector2(hc.x + skew,       mouth_y + bh_px + 1),
		], acc)
		PC.line(img, hc.x - bw_px, mouth_y, hc.x + skew, mouth_y + bh_px, acc.darkened(0.4))
		return

	# ── Normal mouth ───────────────────────────────────────────────────────────
	if goofy < 0.25:
		# STERN: tiny tight frown
		var fw: int = maxi(1, mw / 2)
		PC.line(img, hc.x - fw, mouth_y, hc.x + fw, mouth_y, Color.BLACK)
		PC.blend(img, hc.x - fw - 1, mouth_y + 1, Color.BLACK)
		PC.blend(img, hc.x + fw + 1, mouth_y + 1, Color.BLACK)

	elif goofy < 0.65:
		# NEUTRAL: simple flat line
		PC.line(img, hc.x - mw, mouth_y, hc.x + mw, mouth_y, Color.BLACK)

	else:
		# GOOFY GRIN: wide curved smile with teeth
		for i: int in range(mw * 2 + 1):
			var t: float = float(i) / float(mw * 2)
			var px: int  = hc.x - mw + i
			var py: int  = mouth_y + int(sin(t * PI) * float(mw) * 0.55)
			PC.blend(img, px, py, Color.BLACK)
		# Teeth row
		for i: int in range(mw):
			var tx: int = hc.x - mw / 2 + i
			if i % 2 == 0:
				PC.blend(img, tx, mouth_y + 1, Color.WHITE)
