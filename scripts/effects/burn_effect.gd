static func get_id()   -> String: return "burn"
static func get_name() -> String: return "Burn"
static func get_icon() -> String: return "🔥"
static func get_color() -> Color: return Color(1.0, 0.45, 0.1)

# Returns { "damage": int, "message": String, "cured": bool }
# max_hp used to calculate burn damage as a fraction of total HP.
static func tick(current_hp: int, max_hp: int, _stats: Dictionary) -> Dictionary:
	var dmg := maxi(1, int(float(max_hp) * 0.0625))  # 1/16 max HP per turn
	return {
		"damage":  dmg,
		"message": "🔥 is burned and took %d damage!" ,
		"cured":   false,
	}
