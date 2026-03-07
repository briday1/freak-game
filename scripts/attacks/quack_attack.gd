# Surprise quack. Low power, very high accuracy. Ducks love it.
static func get_name()     -> String: return "Quack"
static func get_power()    -> int:    return 25
static func get_accuracy() -> float:  return 1.0
static func get_type()     -> String: return "special"
static func get_element()  -> String: return "normal"

static func get_data() -> Dictionary:
	return { "name": get_name(), "power": get_power(), "accuracy": get_accuracy(),
		"type": get_type(), "element": get_element(),
		"effects": [{ "id": "sleep", "chance": 0.20 }] }

static func execute(attacker: Dictionary, _defender: Dictionary) -> Dictionary:
	var dmg := int(float(get_power()) * float(attacker["special"]) / 8.0)
	dmg = maxi(1, int(randf_range(0.9, 1.1) * float(dmg)))
	return { "hit": true, "damage": dmg, "message": "QUACK!" }
