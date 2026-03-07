class_name CreatureView
extends Node2D

# ─────────────────────────────────────────────────────────────────────────────
#  Generic creature renderer — knows nothing about specific traits.
#
#  Assign an array of CreatureTrait resources in the Inspector.
#  Each trait owns its genome keys, its random ranges, and its draw logic.
#  Draw order is array order (back → front).
#
#  To make a new creature type: create a new set of .tres resources and assign
#  them to this array.  No code changes needed here.
# ─────────────────────────────────────────────────────────────────────────────

@export var traits: Array = []

var creature_type: String = ""
var genome: Dictionary = {}
var _type_script  # the loaded type GDScript, for constraints

var _idle_tween:   Tween = null
var _base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_base_position = position
	if traits.is_empty():
		set_type(load("res://scripts/creature_type_registry.gd").random_type_name())

## Swap to a new creature type, replacing traits and generating a fresh genome.
func set_type(type_name: String) -> void:
	creature_type = type_name
	_type_script  = load(load("res://scripts/creature_type_registry.gd").TYPES[type_name])
	traits = _type_script.make_traits()
	set_genome(random_genome())

# ─── Animations ──────────────────────────────────────────────────────────────

func play_idle() -> void:
	if _idle_tween:
		_idle_tween.kill()
	_base_position = position
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(self, "position:y", _base_position.y - 5.0, 0.55).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(self, "position:y", _base_position.y + 5.0, 0.55).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_idle() -> void:
	if _idle_tween:
		_idle_tween.kill()
		_idle_tween = null
	position = _base_position

## Lunge toward opponent and return. direction: +1 = right, -1 = left.
func play_attack_anim(direction: float) -> void:
	stop_idle()
	var t := create_tween()
	t.tween_property(self, "position:x", _base_position.x + direction * 55.0, 0.14).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "position:x", _base_position.x, 0.18).set_ease(Tween.EASE_IN)
	await t.finished
	play_idle()

## Flash red and shake on being hit.
func play_hit_anim() -> void:
	stop_idle()
	# Colour flash (parallel to shake)
	var tc := create_tween()
	tc.tween_property(self, "modulate", Color(1.6, 0.25, 0.25), 0.06)
	tc.tween_property(self, "modulate", Color.WHITE, 0.28)
	# Shake
	var ts := create_tween()
	var sx := _base_position.x
	for i in range(5):
		ts.tween_property(self, "position:x", sx + (6.0 if i % 2 == 0 else -6.0), 0.05)
	ts.tween_property(self, "position:x", sx, 0.04)
	await ts.finished
	play_idle()

# ─── Genome helpers ───────────────────────────────────────────────────────────

## Merged schema from traits, with type constraints overlaid on top.
## Constraint entry formats:
##   float  – { "type": "float", "min": x, "max": y }  narrows the random range
##   bool   – { "type": "bool", "forced": true/false }  locks the value
func get_schema() -> Dictionary:
	var schema: Dictionary = {}
	for t in traits:
		schema.merge(t.get_schema())
	if _type_script and _type_script.has_method("get_constraints"):
		for key in _type_script.get_constraints():
			schema[key] = _type_script.get_constraints()[key]
	return schema

func random_genome() -> Dictionary:
	var schema := get_schema()
	var g: Dictionary = {}
	for key in schema:
		var s: Dictionary = schema[key]
		match s["type"]:
			"float":
				g[key] = randf_range(s["min"], s["max"])
			"bool":
				g[key] = s["forced"] if s.has("forced") else randf() > 0.5
			"color":
				var lo: Color = s["min"]
				var hi: Color = s["max"]
				g[key] = Color(
					randf_range(lo.r, hi.r),
					randf_range(lo.g, hi.g),
					randf_range(lo.b, hi.b))
	return g

func set_genome(new_genome: Dictionary) -> void:
	genome = new_genome
	_clamp_genome()
	queue_redraw()

func _clamp_genome() -> void:
	var schema := get_schema()
	for key in schema:
		if not genome.has(key):
			continue
		var s: Dictionary = schema[key]
		match s["type"]:
			"float":
				genome[key] = clamp(genome[key], s["min"], s["max"])
			"bool":
				if s.has("forced"):
					genome[key] = s["forced"]
			"color":
				var c: Color  = genome[key]
				var lo: Color = s["min"]
				var hi: Color = s["max"]
				genome[key] = Color(
					clamp(c.r, lo.r, hi.r),
					clamp(c.g, lo.g, hi.g),
					clamp(c.b, lo.b, hi.b))

# ─── Draw ─────────────────────────────────────────────────────────────────────

func _draw() -> void:
	if genome.is_empty():
		return
	draw_rect(Rect2(0, 0, 300, 450), Color(0.1, 0.1, 0.15))
	for t in traits:
		t.draw(self, genome)
