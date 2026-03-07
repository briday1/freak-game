# Dragon — wings, tail, horns, arms with claws. Always large, always winged and horned.
static func make_traits() -> Array:
	return [
		load("res://scripts/traits/legs_trait.gd").new(),
		load("res://scripts/traits/tail_trait.gd").new(),
		load("res://scripts/traits/body_trait.gd").new(),
		load("res://scripts/traits/wings_trait.gd").new(),
		load("res://scripts/traits/arms_trait.gd").new(),
		load("res://scripts/traits/head_trait.gd").new(),
		load("res://scripts/traits/eyes_trait.gd").new(),
		load("res://scripts/traits/mouth_trait.gd").new(),
		load("res://scripts/traits/horns_trait.gd").new(),
	]

static func make_attacks() -> Array:
	return [
		load("res://scripts/attacks/bite_attack.gd"),
		load("res://scripts/attacks/fire_breath_attack.gd"),
		load("res://scripts/attacks/kick_attack.gd"),
		load("res://scripts/attacks/punch_attack.gd"),
	]

static func get_resistances() -> Dictionary:
	return {
		"fire":     0.5,   # resistant
		"ice":      2.0,   # weak
		"electric": 1.5,   # slightly weak
		"normal":   1.0,
		"dark":     1.0,
		"nature":   1.0,
		"water":    1.0,
	}

static func get_constraints() -> Dictionary:
	return {
		"has_wings":     { "type": "bool",  "forced": true },
		"has_horns":     { "type": "bool",  "forced": true },
		"has_tail":      { "type": "bool",  "forced": true },
		"has_claws":     { "type": "bool",  "forced": true },
		"wing_feathers": { "type": "bool",  "forced": false }, # bat-style wings
		"wing_span":     { "type": "float", "min": 1.3,   "max":  2.0 },
		"extra_legs":    { "type": "bool" },                    # randomly 2 or 4
		"body_width":    { "type": "float", "min":  90.0,  "max": 130.0 },
		"body_height":   { "type": "float", "min": 110.0,  "max": 170.0 },
		"horn_size":     { "type": "float", "min":  20.0,  "max":  40.0 },
		"tail_length":   { "type": "float", "min":  50.0,  "max":  90.0 },
		"arm_length":    { "type": "float", "min":  30.0,  "max":  55.0 },
		"goofiness":     { "type": "float", "min":   0.0,  "max":   0.25 },
	}
