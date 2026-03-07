static func get_id()    -> String: return "paralysis"
static func get_name()  -> String: return "Paralysis"
static func get_icon()  -> String: return "⚡"
static func get_color() -> Color: return Color(1.0, 0.9, 0.1)

# Paralysis: 25% chance to skip turn each time attacker tries to act. No damage tick.
static func tick(_current_hp: int, _max_hp: int, _stats: Dictionary) -> Dictionary:
	var skipped := randf() < 0.25
	return {
		"damage":    0,
		"message":   "⚡ is paralyzed and can't move!" if skipped else "",
		"cured":     false,
		"skip_turn": skipped,
	}
