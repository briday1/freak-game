extends Node2D

var genome: Dictionary = {}

func set_genome(new_genome: Dictionary) -> void:
	genome = new_genome
	# Clamp float traits to their valid ranges
	if genome.has("body_width"):
		genome["body_width"] = clamp(genome["body_width"], 40.0, 120.0)
	if genome.has("body_height"):
		genome["body_height"] = clamp(genome["body_height"], 60.0, 160.0)
	if genome.has("head_size"):
		genome["head_size"] = clamp(genome["head_size"], 20.0, 70.0)
	if genome.has("eye_spacing"):
		genome["eye_spacing"] = clamp(genome["eye_spacing"], 5.0, 30.0)
	if genome.has("eye_size"):
		genome["eye_size"] = clamp(genome["eye_size"], 3.0, 15.0)
	if genome.has("mouth_width"):
		genome["mouth_width"] = clamp(genome["mouth_width"], 5.0, 40.0)
	if genome.has("leg_length"):
		genome["leg_length"] = clamp(genome["leg_length"], 20.0, 80.0)
	if genome.has("arm_length"):
		genome["arm_length"] = clamp(genome["arm_length"], 20.0, 70.0)
	if genome.has("horn_size"):
		genome["horn_size"] = clamp(genome["horn_size"], 0.0, 40.0)
	if genome.has("roundness"):
		genome["roundness"] = clamp(genome["roundness"], 0.0, 1.0)
	if genome.has("strength"):
		genome["strength"] = clamp(genome["strength"], 0.0, 1.0)
	if genome.has("speed"):
		genome["speed"] = clamp(genome["speed"], 0.0, 1.0)
	if genome.has("goofiness"):
		genome["goofiness"] = clamp(genome["goofiness"], 0.0, 1.0)
	queue_redraw()

func random_genome() -> Dictionary:
	return {
		"body_width": randf_range(40.0, 120.0),
		"body_height": randf_range(60.0, 160.0),
		"head_size": randf_range(20.0, 70.0),
		"eye_spacing": randf_range(5.0, 30.0),
		"eye_size": randf_range(3.0, 15.0),
		"mouth_width": randf_range(5.0, 40.0),
		"leg_length": randf_range(20.0, 80.0),
		"arm_length": randf_range(20.0, 70.0),
		"horn_size": randf_range(0.0, 40.0),
		"roundness": randf(),
		"strength": randf(),
		"speed": randf(),
		"goofiness": randf(),
		"body_color": Color(randf_range(0.4, 1.0), randf_range(0.4, 1.0), randf_range(0.4, 1.0)),
		"accent_color": Color(randf_range(0.1, 0.7), randf_range(0.1, 0.7), randf_range(0.1, 0.7)),
		"eye_color": Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0)),
	}

func _draw() -> void:
	if genome.is_empty():
		return

	# Background
	draw_rect(Rect2(0, 0, 300, 450), Color(0.1, 0.1, 0.15))

	var center := Vector2(150, 250)
	var bw: float = genome["body_width"]
	var bh: float = genome["body_height"]
	var hs: float = genome["head_size"]
	var es: float = genome["eye_spacing"]
	var ez: float = genome["eye_size"]
	var mw: float = genome["mouth_width"]
	var ll: float = genome["leg_length"]
	var al: float = genome["arm_length"]
	var horn: float = genome["horn_size"]
	var goofy: float = genome["goofiness"]
	var body_col: Color = genome["body_color"]
	var accent_col: Color = genome["accent_color"]
	var eye_col: Color = genome["eye_color"]

	var body_rect := Rect2(center.x - bw / 2.0, center.y - bh / 2.0, bw, bh)
	var body_top := center.y - bh / 2.0
	var body_bottom := center.y + bh / 2.0
	var body_mid_y := center.y
	var body_left := center.x - bw / 2.0
	var body_right := center.x + bw / 2.0

	# 1. Legs
	var leg_offset := bw * 0.25
	draw_line(Vector2(center.x - leg_offset, body_bottom),
			  Vector2(center.x - leg_offset, body_bottom + ll), accent_col, 6.0)
	draw_line(Vector2(center.x + leg_offset, body_bottom),
			  Vector2(center.x + leg_offset, body_bottom + ll), accent_col, 6.0)

	# 2. Arms
	draw_line(Vector2(body_left, body_mid_y),
			  Vector2(body_left - al * 0.7, body_mid_y + al * 0.7), accent_col, 5.0)
	draw_line(Vector2(body_right, body_mid_y),
			  Vector2(body_right + al * 0.7, body_mid_y + al * 0.7), accent_col, 5.0)

	# 3. Body
	draw_rect(body_rect, body_col)
	draw_rect(body_rect, accent_col, false, 3.0)

	# 4. Head
	var head_center := Vector2(center.x, body_top - hs * 0.6)
	draw_circle(head_center, hs, body_col)
	draw_arc(head_center, hs, 0.0, TAU, 32, accent_col, 3.0)

	# 5. Eyes
	var left_eye := Vector2(head_center.x - es, head_center.y - ez * 0.5)
	var right_eye := Vector2(head_center.x + es, head_center.y - ez * 0.5)
	# Goofy tilt: left eye goes up, right eye goes down
	var goofy_offset := goofy * ez * 1.2
	left_eye.y -= goofy_offset
	right_eye.y += goofy_offset

	# Eye whites
	draw_circle(left_eye, ez, Color.WHITE)
	draw_circle(right_eye, ez, Color.WHITE)
	# Irises
	var iris_r := ez * 0.6
	draw_circle(left_eye, iris_r, eye_col)
	draw_circle(right_eye, iris_r, eye_col)
	# Pupils
	var pupil_r := ez * 0.25
	draw_circle(left_eye, pupil_r, Color.BLACK)
	draw_circle(right_eye, pupil_r, Color.BLACK)

	# 6. Mouth
	var mouth_y := head_center.y + hs * 0.45
	var mouth_left := Vector2(head_center.x - mw, mouth_y)
	var mouth_right := Vector2(head_center.x + mw, mouth_y)
	if goofy > 0.5:
		# Wide grin arc using multiple line segments
		var segments := 10
		var prev_pt := mouth_left
		for i in range(1, segments + 1):
			var t := float(i) / float(segments)
			var x := mouth_left.x + (mouth_right.x - mouth_left.x) * t
			var arc_y := mouth_y + sin(t * PI) * mw * 0.5
			var cur_pt := Vector2(x, arc_y)
			draw_line(prev_pt, cur_pt, Color.BLACK, 3.0)
			prev_pt = cur_pt
	else:
		draw_line(mouth_left, mouth_right, Color.BLACK, 3.0)

	# 7. Horns
	if horn > 5.0:
		var horn_left_tip := Vector2(head_center.x - es * 1.2, head_center.y - hs - horn)
		var horn_left_base_l := Vector2(head_center.x - es * 1.2 - horn * 0.35, head_center.y - hs + 4.0)
		var horn_left_base_r := Vector2(head_center.x - es * 1.2 + horn * 0.35, head_center.y - hs + 4.0)
		draw_polygon(PackedVector2Array([horn_left_tip, horn_left_base_l, horn_left_base_r]), PackedColorArray([accent_col, accent_col, accent_col]))

		var horn_right_tip := Vector2(head_center.x + es * 1.2, head_center.y - hs - horn)
		var horn_right_base_l := Vector2(head_center.x + es * 1.2 - horn * 0.35, head_center.y - hs + 4.0)
		var horn_right_base_r := Vector2(head_center.x + es * 1.2 + horn * 0.35, head_center.y - hs + 4.0)
		draw_polygon(PackedVector2Array([horn_right_tip, horn_right_base_l, horn_right_base_r]), PackedColorArray([accent_col, accent_col, accent_col]))
