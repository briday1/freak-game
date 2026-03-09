class_name WingsTrait
extends Resource

const PC := preload("res://scripts/pixel_canvas.gd")

func get_schema() -> Dictionary:
	return {
		"has_wings":     { "type": "bool" },
		"wing_span":     { "type": "float", "min": 0.7, "max": 1.5 },
		"wing_feathers": { "type": "bool" },
	}

func paint(genome: Dictionary) -> Image:
	var img := PC.make_image()
	if not genome.get("has_wings", false):
		return img
	var bsz := BodyTrait.body_half_size(genome)
	var bw: int  = bsz.x
	var bh: int  = bsz.y
	var cx: int  = PC.CX
	var cy: int  = PC.BY
	# Much bigger span — 13–26 px from body edge
	var span: int     = int(remap(genome["wing_span"] as float, 0.7, 1.5, 10.0, 30.0))
	var attach_y: int = cy - bh + 3
	var pal := PC.palette(genome)
	var feathers: bool = genome.get("wing_feathers", false)

	for side: int in [-1, 1]:
		var ax: int    = cx + side * bw
		var tip_x: int = cx + side * (bw + span)
		var tip_y: int = attach_y - span / 2
		var lo_x: int  = cx + side * (bw + span * 3 / 5)
		var lo_y: int  = attach_y + bh / 2

		if feathers:
			# FEATHERED: gradient fan from body→spot color + shoulder hub
			var fan_count: int = 8
			for fi: int in range(fan_count):
				var t: float  = float(fi) / float(fan_count - 1)
				var fex: int  = int(lerp(float(tip_x), float(lo_x), t))
				var fey: int  = int(lerp(float(tip_y), float(lo_y), t))
				var fc: Color = pal["body"].lerp(pal["spot"], t)
				PC.line(img, ax, attach_y, fex, fey, fc)
			PC.fill_circle(img, ax, attach_y, 3, pal["shadow"])
			PC.fill_circle(img, ax, attach_y, 2, pal["accent"])
			var wsh: Color = pal["shine"]; wsh.a = 0.75
			PC.blend(img, ax, attach_y - 1, wsh)
		else:
			# MEMBRANE: bat wing with translucent fill + inner highlight + ribs
			var wing_c: Color = pal["body"]; wing_c.a = 0.85
			var pts: Array = [
				Vector2(ax,    attach_y),
				Vector2(tip_x, tip_y),
				Vector2(lo_x,  lo_y),
			]
			PC.fill_polygon(img, pts, wing_c.darkened(0.22))
			var inner_hi: Color = pal["highlight"]; inner_hi.a = 0.40
			var pts2: Array = [
				Vector2(ax,               attach_y),
				Vector2(tip_x - side * 4, tip_y + 4),
				Vector2(lo_x  - side * 2, lo_y - 3),
			]
			PC.fill_polygon(img, pts2, inner_hi)
			for ri: int in range(1, 4):
				var rt: float = float(ri) / 4.0
				var rx: int   = int(lerp(float(tip_x), float(lo_x), rt))
				var ry: int   = int(lerp(float(tip_y), float(lo_y), rt))
				PC.line(img, ax, attach_y, rx, ry, pal["outline"])
			PC.line(img, ax, attach_y, tip_x, tip_y, pal["accent"])
			PC.line(img, tip_x, tip_y, lo_x, lo_y, pal["accent"])
	return img
