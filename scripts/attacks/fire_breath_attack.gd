# Special fire attack — high power, ignores physical defense.
static func get_name()     -> String: return "Fire Breath"
static func get_power()    -> int:    return 80
static func get_accuracy() -> float:  return 0.85
static func get_type()     -> String: return "special"
static func get_element()  -> String: return "fire"

static func get_data() -> Dictionary:
	return { "name": get_name(), "power": get_power(), "accuracy": get_accuracy(),
		"type": get_type(), "element": get_element(),
		"effects": [{ "id": "burn", "chance": 0.30 }] }

static func execute(attacker: Dictionary, _defender: Dictionary) -> Dictionary:
	if randf() > get_accuracy():
		return { "hit": false, "damage": 0, "message": "But it missed!" }
	var dmg := int(float(get_power()) * float(attacker["special"]) / 9.0)
	dmg = maxi(1, int(randf_range(0.85, 1.15) * float(dmg)))
	return { "hit": true, "damage": dmg, "message": "🔥" }
