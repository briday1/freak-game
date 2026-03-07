static func get_name()     -> String: return "Kick"
static func get_power()    -> int:    return 55
static func get_accuracy() -> float:  return 0.88
static func get_type()     -> String: return "physical"
static func get_element()  -> String: return "normal"

static func get_data() -> Dictionary:
	return { "name": get_name(), "power": get_power(), "accuracy": get_accuracy(),
		"type": get_type(), "element": get_element(), "effects": [] }

static func execute(attacker: Dictionary, defender: Dictionary) -> Dictionary:
	if randf() > get_accuracy():
		return { "hit": false, "damage": 0, "message": "But it missed!" }
	var dmg := int(float(get_power()) * float(attacker["attack"]) / max(float(defender["defense"]), 1.0))
	dmg = maxi(1, int(randf_range(0.85, 1.15) * float(dmg)))
	return { "hit": true, "damage": dmg, "message": "" }
