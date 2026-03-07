# Duck — stubby legs, no arms, high goofiness, always a tail, never horns or wings.
static func make_traits() -> Array:
	return [
		load("res://scripts/traits/legs_trait.gd").new(),
		load("res://scripts/traits/tail_trait.gd").new(),
		load("res://scripts/traits/body_trait.gd").new(),
		load("res://scripts/traits/head_trait.gd").new(),
		load("res://scripts/traits/eyes_trait.gd").new(),
		load("res://scripts/traits/mouth_trait.gd").new(),
	]

static func make_attacks() -> Array:
	return [
		load("res://scripts/attacks/quack_attack.gd"),
		load("res://scripts/attacks/punch_attack.gd"),
		load("res://scripts/attacks/bite_attack.gd"),
	]

static func get_resistances() -> Dictionary:
	return {
		"water":    0.5,   # resistant
		"electric": 2.0,   # weak
		"fire":     1.0,
		"normal":   1.0,
		"dark":     1.5,   # slightly weak
		"nature":   1.0,
		"ice":      1.0,
	}

static func get_constraints() -> Dictionary:
	return {
		"goofiness":    { "type": "float", "min": 0.75, "max": 1.0 },
		"leg_length":   { "type": "float", "min": 20.0, "max": 35.0 },  # stubby
		"body_width":   { "type": "float", "min": 70.0, "max": 120.0 }, # round
		"body_height":  { "type": "float", "min": 60.0, "max":  90.0 }, # short
		"head_size":    { "type": "float", "min": 30.0, "max":  50.0 },
		"has_tail":     { "type": "bool",  "forced": true },
		"bill_size":    { "type": "float", "min": 14.0, "max":  26.0 }, # always a bill
		"bill_tip_offset": { "type": "float", "min": -0.45, "max": 0.45 }, # random angle
		"mouth_width":  { "type": "float", "min":  5.0, "max":  10.0 },
	}
