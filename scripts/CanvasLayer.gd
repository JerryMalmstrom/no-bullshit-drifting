extends CanvasLayer

func _ready():
	var particle_materials = []
	var particles_dir = "res://particles/"
	
	var dir = Directory.new()
	dir.open(particles_dir)
	
	dir.list_dir_begin(true, true)
	var file = dir.get_next()
	while file != "":
		particle_materials.append(load(particles_dir + file))
		file = dir.get_next()
	dir.list_dir_end()
	
	for material in particle_materials:
		var emitter = Particles2D.new()
		emitter.process_material = material
		emitter.emitting = true
		emitter.one_shot = true
		add_child(emitter)
