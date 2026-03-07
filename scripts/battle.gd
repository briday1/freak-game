extends Node2D

const Registry    := preload("res://scripts/creature_type_registry.gd")
const StatsHelper := preload("res://scripts/creature_stats.gd")

# ── State ──────────────────────────────────────────────────────────────────────
enum State { PLAYER_TURN, ANIMATING, BATTLE_OVER }
var _state: State = State.ANIMATING

var _stats_enemy:  Dictionary = {}
var _stats_player: Dictionary = {}
var _hp_enemy:     int = 0
var _hp_player:    int = 0
var _name_enemy:   String = ""
var _name_player:  String = ""
var _attacks_enemy:  Array = []
var _attacks_player: Array = []

# ── Node refs (built in _ready) ────────────────────────────────────────────────
var _view_enemy              # CreatureView (duck-typed for await-ability)
var _view_player             # CreatureView
var _bar_enemy:   ProgressBar = null
var _bar_player:  ProgressBar = null
var _lbl_enemy:   Label = null
var _lbl_player:  Label = null
var _lbl_message: Label = null
var _attack_btns: Array = []
var _return_btn:  Button = null

# ── Ready ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_ui()
	_init_battle()

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	# Background
	var bg := ColorRect.new()
	bg.size  = Vector2(1100.0, 650.0)
	bg.color = Color(0.05, 0.07, 0.14)
	canvas.add_child(bg)

	# Creature views — added to canvas right after background so UI panels draw on top.
	# Position is set before add_child so _ready() captures the correct _base_position.
	_view_enemy  = _make_creature_view()
	_view_player = _make_creature_view()
	_view_enemy.position  = Vector2(750.0, 28.0)
	_view_enemy.scale     = Vector2(-0.48, 0.48)  # mirrored = faces left
	_view_player.position = Vector2(80.0,  215.0)
	_view_player.scale    = Vector2(0.62,  0.62)
	canvas.add_child(_view_enemy)
	canvas.add_child(_view_player)

	# Enemy HP (top-left)
	_lbl_enemy = _make_label("", 30.0, 22.0, 420.0, 36.0, 18)
	canvas.add_child(_lbl_enemy)
	_bar_enemy = _make_bar(30.0, 62.0, 420.0, 26.0)
	canvas.add_child(_bar_enemy)

	# Player HP (centre-right)
	_lbl_player = _make_label("", 590.0, 325.0, 480.0, 36.0, 18)
	canvas.add_child(_lbl_player)
	_bar_player = _make_bar(590.0, 365.0, 480.0, 26.0)
	canvas.add_child(_bar_player)

	# Message panel (bottom-left)
	var msg_panel := Panel.new()
	msg_panel.position = Vector2(20.0, 445.0)
	msg_panel.size     = Vector2(540.0, 190.0)
	canvas.add_child(msg_panel)
	_lbl_message = _make_label("", 12.0, 12.0, 516.0, 166.0, 17)
	_lbl_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg_panel.add_child(_lbl_message)

	# Attack panel (bottom-right)
	var atk_panel := Panel.new()
	atk_panel.position = Vector2(570.0, 445.0)
	atk_panel.size     = Vector2(510.0, 190.0)
	canvas.add_child(atk_panel)

	var grid := GridContainer.new()
	grid.columns  = 2
	grid.position = Vector2(10.0, 10.0)
	grid.size     = Vector2(490.0, 170.0)
	atk_panel.add_child(grid)

	for i in range(4):
		var btn := Button.new()
		btn.text                  = "---"
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical   = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_attack_pressed.bind(i))
		grid.add_child(btn)
		_attack_btns.append(btn)
	_set_buttons_enabled(false)

	# Return button — hidden until battle ends
	_return_btn = Button.new()
	_return_btn.text = "↩ Return"
	_return_btn.position = Vector2(460.0, 600.0)
	_return_btn.size     = Vector2(180.0, 40.0)
	_return_btn.visible  = false
	_return_btn.pressed.connect(_on_return_pressed)
	canvas.add_child(_return_btn)

func _make_creature_view():
	var cv := Node2D.new()
	cv.set_script(load("res://scripts/creature_view.gd"))
	return cv

func _make_label(txt: String, x: float, y: float, w: float, h: float, fs: int) -> Label:
	var l := Label.new()
	l.text     = txt
	l.position = Vector2(x, y)
	l.size     = Vector2(w, h)
	l.add_theme_font_size_override("font_size", fs)
	return l

func _make_bar(x: float, y: float, w: float, h: float) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position        = Vector2(x, y)
	bar.size            = Vector2(w, h)
	bar.min_value       = 0.0
	bar.max_value       = 100.0
	bar.value           = 100.0
	bar.show_percentage = false
	return bar

# ── Battle init ────────────────────────────────────────────────────────────────
func _init_battle() -> void:
	var fa: Dictionary = GameState.fighter_a
	var fb: Dictionary = GameState.fighter_b

	# Fallback: if launched directly without GameState, pick random types
	if fa.is_empty():
		fa = { "type": Registry.random_type_name(), "genome": {} }
	if fb.is_empty():
		fb = { "type": Registry.random_type_name(), "genome": {} }

	_name_enemy  = fa["type"].capitalize()
	_name_player = fb["type"].capitalize()

	# Set creature types (also generates a genome)
	_view_enemy.set_type(fa["type"])
	_view_player.set_type(fb["type"])
	# Override with the specific genome if provided
	if not (fa["genome"] as Dictionary).is_empty():
		_view_enemy.set_genome(fa["genome"])
	if not (fb["genome"] as Dictionary).is_empty():
		_view_player.set_genome(fb["genome"])

	# Derive stats
	_stats_enemy  = StatsHelper.from_genome(_view_enemy.genome)
	_stats_player = StatsHelper.from_genome(_view_player.genome)
	_hp_enemy     = _stats_enemy["max_hp"]
	_hp_player    = _stats_player["max_hp"]

	# Load attacks from type scripts
	var ts_a = load(Registry.TYPES[fa["type"]])
	var ts_b = load(Registry.TYPES[fb["type"]])
	_attacks_enemy  = ts_a.make_attacks() if ts_a.has_method("make_attacks") else \
		[load("res://scripts/attacks/punch_attack.gd")]
	_attacks_player = ts_b.make_attacks() if ts_b.has_method("make_attacks") else \
		[load("res://scripts/attacks/punch_attack.gd")]

	# HP bars
	_bar_enemy.max_value  = float(_stats_enemy["max_hp"])
	_bar_player.max_value = float(_stats_player["max_hp"])
	_bar_enemy.value      = float(_hp_enemy)
	_bar_player.value     = float(_hp_player)
	_update_hp_labels()

	# Attack buttons (up to 4)
	for i in range(4):
		if i < _attacks_player.size():
			_attack_btns[i].text    = _attacks_player[i].get_name()
			_attack_btns[i].visible = true
		else:
			_attack_btns[i].visible = false

	# Wait one frame so nodes are fully in tree, then start idle + first turn
	await get_tree().process_frame
	_view_enemy.play_idle()
	_view_player.play_idle()
	_start_player_turn()

# ── Turn flow ──────────────────────────────────────────────────────────────────
func _start_player_turn() -> void:
	_state = State.PLAYER_TURN
	_show_message("What will %s do?" % _name_player)
	_set_buttons_enabled(true)

func _on_attack_pressed(idx: int) -> void:
	if _state != State.PLAYER_TURN:
		return
	_state = State.ANIMATING
	_set_buttons_enabled(false)
	_execute_turn(idx)

func _execute_turn(player_atk_idx: int) -> void:
	var player_first: bool = _stats_player["speed"] >= _stats_enemy["speed"]

	if player_first:
		await _do_attack(true,  player_atk_idx)
		if _state == State.BATTLE_OVER:
			return
		await get_tree().create_timer(0.5).timeout
		await _do_attack(false, randi() % _attacks_enemy.size())
	else:
		await _do_attack(false, randi() % _attacks_enemy.size())
		if _state == State.BATTLE_OVER:
			return
		await get_tree().create_timer(0.5).timeout
		await _do_attack(true,  player_atk_idx)

	if _state != State.BATTLE_OVER:
		await get_tree().create_timer(0.55).timeout
		_start_player_turn()

## player_is_attacker = true: player attacks enemy; false: enemy attacks player
func _do_attack(player_is_attacker: bool, atk_idx: int) -> void:
	var attack_script     = _attacks_player[atk_idx] if player_is_attacker else _attacks_enemy[atk_idx]
	var attacker_stats := _stats_player  if player_is_attacker else _stats_enemy
	var defender_stats := _stats_enemy   if player_is_attacker else _stats_player
	var attacker_view     = _view_player  if player_is_attacker else _view_enemy
	var defender_view     = _view_enemy   if player_is_attacker else _view_player
	var attacker_name  := _name_player   if player_is_attacker else _name_enemy

	_show_message("%s used %s!" % [attacker_name, attack_script.get_name()])
	await get_tree().process_frame

	# Lunge animation — player lunges right (+1), enemy lunges left (-1)
	var dir := 1.0 if player_is_attacker else -1.0
	await attacker_view.play_attack_anim(dir)

	var result: Dictionary = attack_script.execute(attacker_stats, defender_stats)

	if not result["hit"]:
		_show_message(result["message"])
		await get_tree().create_timer(0.7).timeout
		return

	var dmg: int   = result["damage"]
	var extra: String = result["message"]
	var msg := "Dealt %d damage!%s" % [dmg, ("  " + extra) if extra != "" else ""]
	_show_message("%s used %s!\n%s" % [attacker_name, attack_script.get_name(), msg])

	if player_is_attacker:
		_hp_enemy = maxi(0, _hp_enemy - dmg)
		_bar_enemy.value = float(_hp_enemy)
	else:
		_hp_player = maxi(0, _hp_player - dmg)
		_bar_player.value = float(_hp_player)
	_update_hp_labels()

	await defender_view.play_hit_anim()

	if player_is_attacker and _hp_enemy <= 0:
		_show_message("%s fainted!  %s wins! 🎉" % [_name_enemy, _name_player])
		_state = State.BATTLE_OVER
		_return_btn.visible = true
		return
	if not player_is_attacker and _hp_player <= 0:
		_show_message("%s fainted!  %s wins... 💀" % [_name_player, _name_enemy])
		_state = State.BATTLE_OVER
		_return_btn.visible = true

# ── UI helpers ─────────────────────────────────────────────────────────────────
func _update_hp_labels() -> void:
	_lbl_enemy.text  = "%s   HP: %d / %d" % [_name_enemy,  _hp_enemy,  _stats_enemy["max_hp"]]
	_lbl_player.text = "%s   HP: %d / %d" % [_name_player, _hp_player, _stats_player["max_hp"]]

func _show_message(text: String) -> void:
	_lbl_message.text = text

func _set_buttons_enabled(enabled: bool) -> void:
	for btn in _attack_btns:
		(btn as Button).disabled = not enabled

func _on_return_pressed() -> void:
	GameState.fighter_a = {}
	GameState.fighter_b = {}
	get_tree().change_scene_to_file("res://scenes/main.tscn")
