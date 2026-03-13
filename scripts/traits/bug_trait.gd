# BugTrait — provides the full genome schema for bug-type creatures.
# All rendering is handled by SpritePainter; this only defines keys + ranges.
class_name BugTrait
extends Resource

func get_schema() -> Dictionary:
	return {
		"body_size":       { "type": "float", "min":  50.0, "max": 100.0 },
		"head_size":       { "type": "float", "min":  30.0, "max":  70.0 },
		"leg_length":      { "type": "float", "min":  20.0, "max":  80.0 },
		"antenna_length":  { "type": "float", "min":  20.0, "max":  80.0 },
		"antenna_spread":  { "type": "float", "min":   0.2, "max":   1.0 },
		"eye_size":        { "type": "float", "min":  20.0, "max":  80.0 },
		"goofiness":       { "type": "float", "min":   0.0, "max":   1.0 },
		"has_wings":       { "type": "bool" },
		"wing_span":       { "type": "float", "min":   0.7, "max":   2.0 },
		"wing_type":       { "type": "float", "min":   0.0, "max":   1.0 },
		"extra_legs":      { "type": "bool" },
		"body_color":      { "type": "color",
			"min": Color(0.0, 0.0, 0.0), "max": Color(1.0, 1.0, 1.0) },
		"accent_color":    { "type": "color",
			"min": Color(0.0, 0.0, 0.0), "max": Color(1.0, 1.0, 1.0) },
	}
