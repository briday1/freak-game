static func get_id()    -> String: return "poison"
static func get_name()  -> String: return "Poison"
static func get_icon()  -> String: return "☠️"
static func get_color() -> Color: return Color(0.6, 0.1, 0.8)

# Poison does escalating damage: 1/16, 2/16, 3/16... of max HP per turn.
static func tick(current_hp: int, max_hp: int, stats: Dictionary) -> Dictionary:
	var turn  := int(stats.get("_poison_turn", 1))
	var dmg   := maxi(1, int(float(max_hp) * float(turn) / 16.0))
	return {
		"damage":  dmg,
		"message": "☠️ is poisoned and took %d damage!",
		"cured":   false,
		"_poison_turn": turn + 1,
	}
