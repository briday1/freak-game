# Derives integer battle stats from a creature's genome Dictionary.
# Missing genome keys fall back to sensible defaults.
static func from_genome(genome: Dictionary) -> Dictionary:
	var bw  := genome.get("body_width",   80.0) as float
	var bh  := genome.get("body_height", 100.0) as float
	var spd := genome.get("speed",         0.5) as float
	var str := genome.get("strength",      0.5) as float
	var goo := genome.get("goofiness",     0.5) as float

	return {
		"max_hp":  maxi(10, int((bw * bh) / 50.0) + 20),  # bigger body = more HP
		"attack":  maxi(1,  int(str * 80.0) + 10),         # strength → physical power
		"defense": maxi(1,  int(bh  / 4.0)  + 5),          # tall = more defense
		"speed":   maxi(1,  int(spd * 100.0) + 1),         # speed stat → turn priority
		"special": maxi(1,  int(goo * 60.0)  + 5),         # goofiness → special power
	}
