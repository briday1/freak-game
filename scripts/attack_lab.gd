extends Node2D

const Registry   := preload("res://scripts/creature_type_registry.gd")
const AttackData := preload("res://scripts/attack_data.gd")

# ── State ──────────────────────────────────────────────────────────────────────
var _pool: Array        = []  # all available attack dicts
var _selected: Dictionary = {}  # currently highlighted attack
var _input_a: Dictionary  = {}  # left combine slot
var _input_b: Dictionary  = {}  # right combine slot
var _combined: Dictionary = {}  # result of last combine

# ── UI refs ────────────────────────────────────────────────────────────────────
var _pool_container:    VBoxContainer = null
var _lbl_input_a:       Label = null
var _lbl_input_b:       Label = null
var _lbl_preview:       Label = null
var _combine_btn:       Button = null
var _add_pool_btn:      Button = null
var _moveset_labels:    Array  = []  # [a0..a3, b0..b3]
var _lbl_selected:      Label  = null

# ── Ready ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_pool()
	_build_ui()
	_refresh_pool_ui()
	_refresh_moveset_ui()

func _build_pool() -> void:
	# Seed pool from both fighters' type defaults
	var types: Array = []
	if not GameState.fighter_a.is_empty():
		types.append(GameState.fighter_a["type"])
	if not GameState.fighter_b.is_empty():
		types.append(GameState.fighter_b["type"])
	if types.is_empty():
		types = Registry.all_type_names()

	var seen: Dictionary = {}
	for type_name in types:
		var ts = load(Registry.TYPES[type_name])
		if ts.has_method("make_attacks"):
			for atk_script in ts.make_attacks():
				var d: Dictionary = atk_script.get_data()
				if not seen.has(d["name"]):
					seen[d["name"]] = true
					_pool.append(d)

	# Restore any previously crafted attacks
	for d in GameState.attack_pool:
		if not seen.has(d["name"]):
			seen[d["name"]] = true
			_pool.append(d)

	# Ensure movesets exist
	if GameState.moveset_a.is_empty() and not GameState.fighter_a.is_empty():
		var ts = load(Registry.TYPES[GameState.fighter_a["type"]])
		if ts.has_method("make_attacks"):
			for s in ts.make_attacks():
				GameState.moveset_a.append(s.get_data())
	if GameState.moveset_b.is_empty() and not GameState.fighter_b.is_empty():
		var ts = load(Registry.TYPES[GameState.fighter_b["type"]])
		if ts.has_method("make_attacks"):
			for s in ts.make_attacks():
				GameState.moveset_b.append(s.get_data())

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var bg := ColorRect.new()
	bg.size  = Vector2(1100.0, 650.0)
	bg.color = Color(0.07, 0.08, 0.12)
	canvas.add_child(bg)

	var title := _label("⚗️  Attack Lab", 0.0, 8.0, 1100.0, 38.0, 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(title)

	# ── POOL panel (left) ──────────────────────────────────────────────────────
	var pool_panel := _panel(10.0, 54.0, 340.0, 560.0)
	canvas.add_child(pool_panel)
	pool_panel.add_child(_label("Available Attacks", 6.0, 4.0, 328.0, 28.0, 15))

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(4.0, 36.0)
	scroll.size     = Vector2(332.0, 516.0)
	pool_panel.add_child(scroll)

	_pool_container = VBoxContainer.new()
	_pool_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_pool_container)

	# ── COMBINE panel (centre) ─────────────────────────────────────────────────
	var combine_panel := _panel(360.0, 54.0, 380.0, 360.0)
	canvas.add_child(combine_panel)
	combine_panel.add_child(_label("Combine", 6.0, 4.0, 368.0, 28.0, 15))

	_lbl_input_a = _label("Slot A: ---", 8.0, 38.0, 364.0, 72.0, 13)
	_lbl_input_a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combine_panel.add_child(_lbl_input_a)

	var set_a_btn := _btn("← Set Slot A", 8.0, 116.0, 172.0, 32.0)
	set_a_btn.pressed.connect(_on_set_a)
	combine_panel.add_child(set_a_btn)

	_lbl_input_b = _label("Slot B: ---", 8.0, 156.0, 364.0, 72.0, 13)
	_lbl_input_b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combine_panel.add_child(_lbl_input_b)

	var set_b_btn := _btn("← Set Slot B", 8.0, 234.0, 172.0, 32.0)
	set_b_btn.pressed.connect(_on_set_b)
	combine_panel.add_child(set_b_btn)

	_combine_btn = _btn("⚗️  Combine!", 8.0, 276.0, 364.0, 44.0)
	_combine_btn.disabled = true
	_combine_btn.pressed.connect(_on_combine)
	combine_panel.add_child(_combine_btn)

	# ── Preview panel ──────────────────────────────────────────────────────────
	var preview_panel := _panel(360.0, 424.0, 380.0, 190.0)
	canvas.add_child(preview_panel)
	preview_panel.add_child(_label("Result", 6.0, 4.0, 368.0, 28.0, 15))

	_lbl_preview = _label("---", 8.0, 34.0, 364.0, 110.0, 13)
	_lbl_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_panel.add_child(_lbl_preview)

	_add_pool_btn = _btn("+ Add to Pool", 8.0, 150.0, 364.0, 34.0)
	_add_pool_btn.disabled = true
	_add_pool_btn.pressed.connect(_on_add_to_pool)
	preview_panel.add_child(_add_pool_btn)

	# ── Selection info ─────────────────────────────────────────────────────────
	var sel_panel := _panel(360.0, 54.0, 380.0, 360.0)
	# actually placed right — let me put it there
	# The selected attack info shows above moveset
	var sel_bg := _panel(750.0, 54.0, 340.0, 120.0)
	canvas.add_child(sel_bg)
	sel_bg.add_child(_label("Selected:", 6.0, 4.0, 328.0, 22.0, 13))
	_lbl_selected = _label("---", 8.0, 28.0, 324.0, 86.0, 13)
	_lbl_selected.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sel_bg.add_child(_lbl_selected)

	# ── Moveset panels (right) ─────────────────────────────────────────────────
	var name_a: String = (GameState.fighter_a.get("type", "Fighter A") as String).capitalize()
	var name_b: String = (GameState.fighter_b.get("type", "Fighter B") as String).capitalize()

	_build_moveset_panel(canvas, name_a, 750.0, 182.0, true)
	_build_moveset_panel(canvas, name_b, 750.0, 418.0, false)

	# ── Bottom buttons ─────────────────────────────────────────────────────────
	var back_btn := _btn("← Back", 10.0, 620.0, 150.0, 40.0)
	back_btn.pressed.connect(_on_back)
	canvas.add_child(back_btn)

	var fight_btn := _btn("⚔️  FIGHT!", 920.0, 610.0, 170.0, 48.0)
	fight_btn.add_theme_font_size_override("font_size", 20)
	fight_btn.pressed.connect(_on_fight)
	canvas.add_child(fight_btn)

func _build_moveset_panel(canvas: CanvasLayer, fighter_name: String,
		x: float, y: float, is_a: bool) -> void:
	var panel := _panel(x, y, 340.0, 228.0)
	canvas.add_child(panel)
	panel.add_child(_label(fighter_name + "'s Moveset", 6.0, 4.0, 328.0, 26.0, 14))

	var moveset := GameState.moveset_a if is_a else GameState.moveset_b
	for i in range(4):
		var slot_lbl := _label("", 8.0, 32.0 + float(i) * 44.0, 224.0, 38.0, 13)
		slot_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(slot_lbl)
		_moveset_labels.append(slot_lbl)  # a0-a3 first, then b0-b3

		var assign_btn := _btn("← Assign", 236.0, 32.0 + float(i) * 44.0, 96.0, 38.0)
		assign_btn.pressed.connect(_on_assign.bind(is_a, i))
		panel.add_child(assign_btn)

		var clear_btn_txt := "✕"
		var clear_btn := _btn(clear_btn_txt, 232.0 + 96.0 + 2.0, 32.0 + float(i) * 44.0, 28.0, 38.0)
		clear_btn.pressed.connect(_on_clear_slot.bind(is_a, i))
		panel.add_child(clear_btn)

# ── Pool UI ───────────────────────────────────────────────────────────────────
func _refresh_pool_ui() -> void:
	for child in _pool_container.get_children():
		child.queue_free()
	for d in _pool:
		var d_copy: Dictionary = d
		var btn := Button.new()
		btn.text                  = AttackData.describe(d_copy)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size   = Vector2(0.0, 56.0)
		btn.add_theme_font_size_override("font_size", 12)
		btn.alignment             = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_pool_select.bind(d_copy))
		_pool_container.add_child(btn)

func _refresh_moveset_ui() -> void:
	# Labels: indices 0-3 = A, 4-7 = B
	var labels_a := _moveset_labels.slice(0, 4)
	var labels_b := _moveset_labels.slice(4, 8)
	for i in range(4):
		var slot_a: String = AttackData.describe(GameState.moveset_a[i]) \
			if i < GameState.moveset_a.size() else "--- empty ---"
		var slot_b: String = AttackData.describe(GameState.moveset_b[i]) \
			if i < GameState.moveset_b.size() else "--- empty ---"
		(labels_a[i] as Label).text = slot_a
		(labels_b[i] as Label).text = slot_b

# ── Handlers ──────────────────────────────────────────────────────────────────
func _on_pool_select(d: Dictionary) -> void:
	_selected = d
	_lbl_selected.text = AttackData.describe(d)

func _on_set_a() -> void:
	if _selected.is_empty():
		return
	_input_a = _selected
	_lbl_input_a.text = "Slot A: " + AttackData.describe(_input_a)
	_combine_btn.disabled = _input_a.is_empty() or _input_b.is_empty()

func _on_set_b() -> void:
	if _selected.is_empty():
		return
	_input_b = _selected
	_lbl_input_b.text = "Slot B: " + AttackData.describe(_input_b)
	_combine_btn.disabled = _input_a.is_empty() or _input_b.is_empty()

func _on_combine() -> void:
	_combined = AttackData.combine(_input_a, _input_b)
	_lbl_preview.text    = AttackData.describe(_combined)
	_add_pool_btn.disabled = false

func _on_add_to_pool() -> void:
	if _combined.is_empty():
		return
	# Avoid exact name dupes
	for d in _pool:
		if d["name"] == _combined["name"]:
			return
	_pool.append(_combined)
	GameState.attack_pool.append(_combined)
	_refresh_pool_ui()
	_combined = {}
	_lbl_preview.text = "Added to pool!"
	_add_pool_btn.disabled = true

func _on_assign(is_a: bool, slot: int) -> void:
	if _selected.is_empty():
		return
	var moveset := GameState.moveset_a if is_a else GameState.moveset_b
	# Extend array to slot if needed
	while moveset.size() <= slot:
		moveset.append({})
	moveset[slot] = _selected
	_refresh_moveset_ui()

func _on_clear_slot(is_a: bool, slot: int) -> void:
	var moveset := GameState.moveset_a if is_a else GameState.moveset_b
	if slot < moveset.size():
		moveset.remove_at(slot)
	_refresh_moveset_ui()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_fight() -> void:
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

# ── UI helpers ─────────────────────────────────────────────────────────────────
func _label(txt: String, x: float, y: float, w: float, h: float, fs: int) -> Label:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(x, y)
	l.size     = Vector2(w, h)
	l.add_theme_font_size_override("font_size", fs)
	return l

func _btn(txt: String, x: float, y: float, w: float, h: float) -> Button:
	var b := Button.new()
	b.text     = txt
	b.position = Vector2(x, y)
	b.size     = Vector2(w, h)
	return b

func _panel(x: float, y: float, w: float, h: float) -> Panel:
	var p := Panel.new()
	p.position = Vector2(x, y)
	p.size     = Vector2(w, h)
	return p
