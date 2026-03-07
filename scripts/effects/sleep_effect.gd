static func get_id()    -> String: return "sleep"
static func get_name()  -> String: return "Sleep"
static func get_icon()  -> String: return "💤"
static func get_color() -> Color: return Color(0.3, 0.5, 0.9)

# Sleep: no damage, but the afflicted cannot act for 2-3 turns, then self-cures.
static func tick(_current_hp: int, _max_hp: int, stats: Dictionary) -> Dictionary:
	var turns_left := int(stats.get("_sleep_turns", 2))
	var cured      := turns_left <= 1
	return {
		"damage":        0,
		"message":       "💤 is fast asleep!" if not cured else "💤 woke up!",
		"cured":         cured,
		"_sleep_turns":  turns_left - 1,
		"skip_turn":     not cured,
	}
