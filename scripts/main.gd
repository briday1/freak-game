extends Node2D

@onready var creature_a: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/PanelA/VBoxContainer/SubViewportContainer/SubViewport/CreatureViewA
@onready var creature_b: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/PanelB/VBoxContainer/SubViewportContainer/SubViewport/CreatureViewB
@onready var creature_c: Node2D = $CanvasLayer/VBoxContainer/HBoxContainer/PanelC/VBoxContainer/SubViewportContainer/SubViewport/CreatureViewC

func _ready() -> void:
	_new_parents()

func _new_parents() -> void:
	creature_a.set_genome(creature_a.random_genome())
	creature_b.set_genome(creature_b.random_genome())
	creature_c.set_genome(creature_c.random_genome())

func _breed() -> void:
	var genome_a = creature_a.genome
	var genome_b = creature_b.genome
	var child_genome = {}
	for key in genome_a:
		if key in ["body_color", "accent_color", "eye_color"]:
			var ca: Color = genome_a[key]
			var cb: Color = genome_b[key]
			var t = randf()
			var blended = ca.lerp(cb, t)
			blended.r = clamp(blended.r + randf_range(-0.08, 0.08), 0.0, 1.0)
			blended.g = clamp(blended.g + randf_range(-0.08, 0.08), 0.0, 1.0)
			blended.b = clamp(blended.b + randf_range(-0.08, 0.08), 0.0, 1.0)
			child_genome[key] = blended
		else:
			var val = genome_a[key] if randf() < 0.5 else genome_b[key]
			val += randf_range(-0.05, 0.05) * (genome_a[key] + genome_b[key])
			child_genome[key] = val
	creature_c.set_genome(child_genome)
