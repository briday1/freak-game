class_name MouthTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"mouth_width":     { "type": "float", "min": 5.0,  "max": 40.0 },
		"goofiness":       { "type": "float", "min": 0.0,  "max":  1.0 },
		"bill_size":       { "type": "float", "min": 0.0,  "max":  0.0 },  # duck overrides
		"bill_tip_offset": { "type": "float", "min": 0.0,  "max":  0.0 },  # duck overrides; tip skew
	}

func draw(canvas: Node2D, genome: Dictionary) -> void:
	var hs    := genome["head_size"]   as float
	var bh    := genome["body_height"] as float
	var hc    := Vector2(150.0, 250.0 - bh * 0.5 - hs * 0.6)
	var mw    := genome["mouth_width"] as float
	var goofy := genome["goofiness"]   as float
	var y     := hc.y + hs * 0.45

	# Bill/beak mode
	var bill := 0.0
	if genome.has("bill_size"):
		bill = genome["bill_size"] as float
	if bill > 2.0:
		var bill_col   := genome["accent_color"] as Color
		var tip_skew   := 0.0
		if genome.has("bill_tip_offset"):
			tip_skew = genome["bill_tip_offset"] as float
		var beak_left  := Vector2(hc.x - bill * 0.55, y)
		var beak_right := Vector2(hc.x + bill * 0.55, y)
		var beak_tip   := Vector2(hc.x + tip_skew * bill, y + bill)
		canvas.draw_polygon(
			PackedVector2Array([beak_left, beak_right, beak_tip]),
			PackedColorArray([bill_col, bill_col, bill_col]))
		canvas.draw_polyline(
			PackedVector2Array([beak_left, beak_tip, beak_right]),
			bill_col.darkened(0.3), 2.0)
		return

	# Normal mouth
	var left  := Vector2(hc.x - mw, y)
	var right := Vector2(hc.x + mw, y)
	if goofy > 0.5:
		var prev := left
		for i in range(1, 11):
			var t   := float(i) / 10.0
			var cur := Vector2(left.x + (right.x - left.x) * t,
										y + sin(t * PI) * mw * 0.5)
			canvas.draw_line(prev, cur, Color.BLACK, 3.0)
			prev = cur
	else:
		canvas.draw_line(left, right, Color.BLACK, 3.0)
