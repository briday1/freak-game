extends Node2D

@onready var creature_a: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/PanelA/VBoxContainer/SubViewportContainer/SubViewport/CreatureViewA
@onready var creature_b: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/PanelB/VBoxContainer/SubViewportContainer/SubViewport/CreatureViewB
@onready var creature_c: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/PanelC/VBoxContainer/SubViewportContainer/SubViewport/CreatureViewC
@onready var picker_a: OptionButton = $CanvasLayer/VBoxContainer/HBoxContainer/PanelA/VBoxContainer/TypePickerA
@onready var picker_b: OptionButton = $CanvasLayer/VBoxContainer/HBoxContainer/PanelB/VBoxContainer/TypePickerB

const Registry := preload("res://scripts/creature_type_registry.gd")

func _ready() -> void:
	_populate_picker(picker_a)
	_populate_picker(picker_b)
	_new_parents()
	# Fight button — added in code to avoid tscn surgery
	var fight_btn := Button.new()
	fight_btn.text = "⚔️  FIGHT!"
	fight_btn.custom_minimum_size = Vector2(0, 52)
	fight_btn.add_theme_font_size_override("font_size", 22)
	fight_btn.pressed.connect(_on_fight_pressed)
	$CanvasLayer/VBoxContainer.add_child(fight_btn)

	var lab_btn := Button.new()
	lab_btn.text = "⚗️  Attack Lab"
	lab_btn.custom_minimum_size = Vector2(0, 40)
	lab_btn.add_theme_font_size_override("font_size", 16)
	lab_btn.pressed.connect(_on_lab_pressed)
	$CanvasLayer/VBoxContainer.add_child(lab_btn)

func _populate_picker(picker: OptionButton) -> void:
	picker.clear()
	picker.add_item("🎲 Random", 0)
	var i := 1
	for type_name in Registry.all_type_names():
		picker.add_item(type_name.capitalize(), i)
		picker.set_item_metadata(i, type_name)
		i += 1

func _get_picker_type(picker: OptionButton) -> String:
	var idx := picker.selected
	if idx == 0:
		return Registry.random_type_name()
	return picker.get_item_metadata(idx)

func _new_parents() -> void:
	creature_a.set_type(_get_picker_type(picker_a))
	creature_b.set_type(_get_picker_type(picker_b))
	creature_c.set_type(Registry.random_type_name())

func _on_type_picker_a_selected(_index: int) -> void:
	creature_a.set_type(_get_picker_type(picker_a))

func _on_type_picker_b_selected(_index: int) -> void:
	creature_b.set_type(_get_picker_type(picker_b))

func _on_fight_pressed() -> void:
	GameState.set_fighters(
		creature_a.creature_type, creature_a.genome,
		creature_b.creature_type, creature_b.genome)
	# Clear movesets so battle uses type defaults (or whatever Lab last set)
	GameState.moveset_a = []
	GameState.moveset_b = []
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _on_lab_pressed() -> void:
	GameState.set_fighters(
		creature_a.creature_type, creature_a.genome,
		creature_b.creature_type, creature_b.genome)
	get_tree().change_scene_to_file("res://scenes/attack_lab.tscn")

func _breed() -> void:
	var ga: Dictionary = creature_a.genome
	var gb: Dictionary = creature_b.genome

	# Pick a primary type weighted by a random blend — 0.35..0.65 means neither
	# parent fully dominates, so the child is a genuine visual hybrid.
	var blend_weight: float = randf_range(0.30, 0.70)
	var child_type: String
	var blend_type: String
	if randf() < 0.5:
		child_type  = creature_a.creature_type
		blend_type  = creature_b.creature_type
	else:
		child_type  = creature_b.creature_type
		blend_type  = creature_a.creature_type
	creature_c.set_type(child_type)

	# Build a genome for the child's type, blending from parents where possible.
	var schema: Dictionary = creature_c.get_schema()
	var child: Dictionary = {}
	for key in schema:
		var s: Dictionary = schema[key]
		var in_a := ga.has(key)
		var in_b := gb.has(key)
		match s["type"]:
			"float":
				if in_a and in_b:
					var val := lerpf(ga[key], gb[key], randf())
					val += randf_range(-0.05, 0.05) * (s["max"] - s["min"])
					child[key] = val
				elif in_a:
					child[key] = ga[key]
				elif in_b:
					child[key] = gb[key]
				else:
					child[key] = randf_range(s["min"], s["max"])
			"bool":
				if in_a and in_b:
					var inherited: bool = ga[key] if randf() < 0.5 else gb[key]
					child[key] = not inherited if randf() < 0.1 else inherited
				elif in_a:
					child[key] = ga[key]
				elif in_b:
					child[key] = gb[key]
				else:
					child[key] = randf() > 0.5
			"color":
				if in_a and in_b:
					var blended: Color = (ga[key] as Color).lerp(gb[key], randf())
					blended.r = clamp(blended.r + randf_range(-0.08, 0.08), 0.0, 1.0)
					blended.g = clamp(blended.g + randf_range(-0.08, 0.08), 0.0, 1.0)
					blended.b = clamp(blended.b + randf_range(-0.08, 0.08), 0.0, 1.0)
					child[key] = blended
				elif in_a:
					child[key] = ga[key]
				elif in_b:
					child[key] = gb[key]
				else:
					var lo: Color = s["min"]
					var hi: Color = s["max"]
					child[key] = Color(randf_range(lo.r, hi.r), randf_range(lo.g, hi.g), randf_range(lo.b, hi.b))
	# Inject blend metadata so SpritePainter can lerp both type stamps together
	child["_blend_type"]   = blend_type
	child["_blend_weight"] = blend_weight
	creature_c.set_genome(child)
