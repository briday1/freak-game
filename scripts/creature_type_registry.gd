# CreatureTypeRegistry — knows all available creature types.
#
# To add a new type:
#   1. Create scripts/types/your_type.gd with a static make_traits() -> Array
#   2. Add an entry to TYPES below.
#
# Usage:
#   var type_name := CreatureTypeRegistry.random_type_name()
#   var traits    := CreatureTypeRegistry.make_traits(type_name)

class_name CreatureTypeRegistry

const TYPES: Dictionary = {
	"human":  "res://scripts/types/human_type.gd",
	"dragon": "res://scripts/types/dragon_type.gd",
	"duck":   "res://scripts/types/duck_type.gd",
}

static func all_type_names() -> Array:
	return TYPES.keys()

static func random_type_name() -> String:
	var keys := TYPES.keys()
	return keys[randi() % keys.size()]

static func make_traits(type_name: String) -> Array:
	assert(TYPES.has(type_name), "Unknown creature type: " + type_name)
	return load(TYPES[type_name]).make_traits()
