# Bug — the only creature type. Rounded ball body, 6 legs, antennae, optional wings.
static func make_traits() -> Array:
	return [
		load("res://scripts/traits/bug_trait.gd").new(),
	]

static func make_attacks() -> Array:
	return [
		load("res://scripts/attacks/bite_attack.gd"),
		load("res://scripts/attacks/kick_attack.gd"),
		load("res://scripts/attacks/laser_attack.gd"),
	]

static func get_resistances() -> Dictionary:
	return {
		"nature":   0.5,
		"normal":   1.0,
		"fire":     2.0,
		"water":    1.0,
		"electric": 1.0,
		"dark":     1.0,
		"ice":      1.5,
	}

static func get_constraints() -> Dictionary:
	return {}
