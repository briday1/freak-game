# Maps effect IDs to their script paths.
const _PATHS: Dictionary = {
	"burn":      "res://scripts/effects/burn_effect.gd",
	"poison":    "res://scripts/effects/poison_effect.gd",
	"sleep":     "res://scripts/effects/sleep_effect.gd",
	"paralysis": "res://scripts/effects/paralysis_effect.gd",
}

static func load_effect(id: String):
	return load(_PATHS[id]) if _PATHS.has(id) else null

static func all_ids() -> Array:
	return _PATHS.keys()

static func get_icon(id: String) -> String:
	var s = load_effect(id)
	return s.get_icon() if s else "?"

static func get_color(id: String) -> Color:
	var s = load_effect(id)
	return s.get_color() if s else Color.WHITE
