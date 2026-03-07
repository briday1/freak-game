# Human — bipedal, arms, optional horns, never wings or tail.
static func make_traits() -> Array:
	return [
		load("res://scripts/traits/legs_trait.gd").new(),
		load("res://scripts/traits/arms_trait.gd").new(),
		load("res://scripts/traits/body_trait.gd").new(),
		load("res://scripts/traits/head_trait.gd").new(),
		load("res://scripts/traits/eyes_trait.gd").new(),
		load("res://scripts/traits/mouth_trait.gd").new(),
		load("res://scripts/traits/horns_trait.gd").new(),
	]

static func make_attacks() -> Array:
	return [
		load("res://scripts/attacks/punch_attack.gd"),
		load("res://scripts/attacks/kick_attack.gd"),
		load("res://scripts/attacks/laser_attack.gd"),
	]

static func get_constraints() -> Dictionary:
	return {
		"has_horns":   { "type": "bool" },                               # optional — random
		"leg_length":  { "type": "float", "min": 40.0, "max": 80.0 },
		"body_height": { "type": "float", "min": 80.0, "max": 160.0 },
	}
