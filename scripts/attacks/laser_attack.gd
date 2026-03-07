# Special attack — bypasses physical defense, uses attacker's special stat.
static func get_name()     -> String: return "Laser"
static func get_power()    -> int:    return 65
static func get_accuracy() -> float:  return 0.90
static func get_type()     -> String: return "special"
static func get_element()  -> String: return "electric"

static func execute(attacker: Dictionary, _defender: Dictionary) -> Dictionary:
	if randf() > get_accuracy():
		return { "hit": false, "damage": 0, "message": "But it missed!" }
	var dmg := int(float(get_power()) * float(attacker["special"]) / 10.0)
	dmg = maxi(1, int(randf_range(0.85, 1.15) * float(dmg)))
	return { "hit": true, "damage": dmg, "message": "" }
