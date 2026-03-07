# Autoload singleton — holds data for the two creatures entering a battle,
# so it survives a scene change.
extends Node

var fighter_a: Dictionary = {}  # { "type": String, "genome": Dictionary }
var fighter_b: Dictionary = {}  # { "type": String, "genome": Dictionary }

func set_fighters(
		type_a: String, genome_a: Dictionary,
		type_b: String, genome_b: Dictionary) -> void:
	fighter_a = { "type": type_a, "genome": genome_a }
	fighter_b = { "type": type_b, "genome": genome_b }

func ready() -> bool:
	return not fighter_a.is_empty() and not fighter_b.is_empty()
