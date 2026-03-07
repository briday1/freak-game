class_name WingsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"has_wings":     { "type": "bool" },
		"wing_span":     { "type": "float", "min": 0.7, "max": 1.5 },
		"wing_feathers": { "type": "bool" },
	}

func paint(img: Image, genome: Dictionary) -> void:
	if not genome.get("has_wings", false):
		return
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = 32
	var cy: int  = 40
	# Much bigger span — 13–26 px from body edge
	var span: int     = int(remap(genome["wing_span"] as float, 0.7, 1.5, 13.0, 26.0))
	var attach_y: int = cy - bh + 3
	var col: Color    = genome["body_color"]
	var edge: Color   = genome["accent_color"]
	var feathers: bool = genome.get("wing_feathers", false)

	for side: int in [-1, 1]:
		var ax: int    = cx + side * bw
		var tip_x: int = cx + side * (bw + span)
		var tip_y: int = attach_y - span / 2
		# Lower wing curve point
		var lo_x: int  = cx + side * (bw + span * 3 / 5)
		var lo_y: int  = attach_y + bh / 2

		if feathers:
			# FEATHERED: radiating fan of pixel lines (bird-like)
			var fan_count: int = 6
			for fi: int in range(fan_count):
				var t: float  = float(fi) / float(fan_count - 1)
				var fex: int  = int(lerp(float(tip_x), float(lo_x), t))
				var fey: int  = int(lerp(float(tip_y), float(lo_y), t))
				var fc: Color = col.lerp(edge, t * 0.45)
				PC.line(img, ax, attach_y, fex, fey, fc)
			# Shoulder hub
			PC.fill_circle(img, ax, attach_y, 3, edge)
			PC.fill_circle(img, ax, attach_y, 2, col)
		else:
			# MEMBRANE: bat-like filled polygon with ribs
			var pts: Array = [
				Vector2(ax,    attach_y),
				Vector2(tip_x, tip_y),
				Vector2(lo_x,  lo_y),
			]
			PC.fill_polygon(img, pts, col.darkened(0.18))
			# Membrane ribs
			for ri: int in range(1, 3):
				var rt: float = float(ri) / 3.0
				var rx: int   = int(lerp(float(tip_x), float(lo_x), rt))
				var ry: int   = int(lerp(float(tip_y), float(lo_y), rt))
				PC.line(img, ax, attach_y, rx, ry, edge.darkened(0.1))
			# Wing outline
			PC.line(img, ax, attach_y, tip_x, tip_y, edge)
			PC.line(img, tip_x, tip_y, lo_x, lo_y, edge)
