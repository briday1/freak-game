# Central helper for attacks-as-data-dicts.
# Attack dict format:
#   { "name": String, "power": int, "accuracy": float,
#     "type": "physical"|"special",
#     "element": "normal"|"fire"|"electric"|"ice"|"nature"|"dark"|"water",
#     "effects": [ { "id": String, "chance": float }, ... ] }

const _ELEMENT_PREFIX: Dictionary = {
	"fire":     "Blazing",
	"electric": "Volt",
	"ice":      "Frozen",
	"nature":   "Thorn",
	"dark":     "Shadow",
	"water":    "Torrent",
}

const _ELEMENT_ICON: Dictionary = {
	"normal":   "",
	"fire":     "🔥",
	"electric": "⚡",
	"ice":      "❄️",
	"nature":   "🌿",
	"dark":     "🌑",
	"water":    "💧",
}

# Convert an existing static attack script to a data dict.
static func from_script(script) -> Dictionary:
	return script.get_data()

# ── Execute ───────────────────────────────────────────────────────────────────
# attacker/defender are stats dicts (from creature_stats.gd).
# defender should include "resistances": { element: float } if the type defines them.
# Returns { "hit": bool, "damage": int, "message": String, "apply_effect": Dictionary }
static func execute(attack: Dictionary, attacker: Dictionary, defender: Dictionary) -> Dictionary:
	if randf() > float(attack["accuracy"]):
		return { "hit": false, "damage": 0, "message": "But it missed!", "apply_effect": {} }

	var power := float(attack["power"])
	var dmg: float
	if attack["type"] == "physical":
		dmg = power * float(attacker["attack"]) / maxf(float(defender["defense"]), 1.0)
	else:
		dmg = power * float(attacker["special"]) / 10.0

	# Element resistance
	var resistances: Dictionary = defender.get("resistances", {})
	var resist := float(resistances.get(attack["element"], 1.0))
	dmg *= resist

	# Variance
	dmg = maxf(1.0, dmg * randf_range(0.85, 1.15))
	var int_dmg := maxi(1, int(dmg))

	# Roll for status effect (first one that procs wins)
	var apply_effect: Dictionary = {}
	for eff in attack.get("effects", []):
		if randf() < float(eff["chance"]):
			apply_effect = { "id": eff["id"] }
			break

	# Effectiveness flavour
	var eff_msg := ""
	if resist <= 0.5:
		eff_msg = "  Not very effective..."
	elif resist >= 2.0:
		eff_msg = "  Super effective! 💥"

	return { "hit": true, "damage": int_dmg, "message": eff_msg, "apply_effect": apply_effect }

# ── Combine ───────────────────────────────────────────────────────────────────
static func combine(a: Dictionary, b: Dictionary) -> Dictionary:
	var pa := float(a["power"])
	var pb := float(b["power"])

	var combined_power    := maxi(5, int((pa + pb) * 0.5 * randf_range(0.9, 1.1)))
	var combined_accuracy := clampf((float(a["accuracy"]) + float(b["accuracy"])) * 0.5 - 0.03, 0.5, 1.0)
	# Type from higher-power source
	var combined_type: String    = a["type"]    if pa >= pb else b["type"]
	var combined_element: String = a["element"] if pa >= pb else b["element"]

	# Merge effects
	var eff_map: Dictionary = {}
	for eff in a.get("effects", []):
		eff_map[eff["id"]] = float(eff["chance"])
	for eff in b.get("effects", []):
		var id: String = eff["id"]
		if eff_map.has(id):
			eff_map[id] = minf(0.8, eff_map[id] + float(eff["chance"]) * 0.5)
		else:
			eff_map[id] = float(eff["chance"]) * 0.7
	var combined_effects: Array = []
	for id in eff_map:
		combined_effects.append({ "id": id, "chance": eff_map[id] })

	return {
		"name":     _combo_name(a, b, combined_element),
		"power":    combined_power,
		"accuracy": combined_accuracy,
		"type":     combined_type,
		"element":  combined_element,
		"effects":  combined_effects,
	}

static func _combo_name(a: Dictionary, b: Dictionary, element: String) -> String:
	var prefix: String = _ELEMENT_PREFIX.get(element, "")
	# Try to build something like "Blazing Kick" or "Volt Punch"
	# Use the action word from whichever attack doesn't own the element
	var base: String
	if a["element"] == element:
		base = _action_word(b["name"])
	else:
		base = _action_word(a["name"])
	if prefix == "" or base == "":
		return "%s + %s" % [a["name"], b["name"]]
	return "%s %s" % [prefix, base]

static func _action_word(name: String) -> String:
	# Take the last word as the action ("Fire Breath" → "Breath", "Punch" → "Punch")
	var parts := name.split(" ")
	return parts[parts.size() - 1]

# ── Describe ──────────────────────────────────────────────────────────────────
static func describe(attack: Dictionary) -> String:
	var icon: String = _ELEMENT_ICON.get(attack["element"], "")
	var eff_str := ""
	for eff in attack.get("effects", []):
		var reg = load("res://scripts/effect_registry.gd")
		eff_str += "  %s %.0f%%" % [reg.get_icon(eff["id"]), float(eff["chance"]) * 100.0]
	return "%s %s%s\npow:%d  acc:%.0f%%%s" % [
		icon, attack["name"], eff_str,
		attack["power"], float(attack["accuracy"]) * 100.0,
		"  [special]" if attack["type"] == "special" else ""]
