extends Node

class_name WorldGenerator

signal chunk_generated(chunk: WorldChunk)
signal chunk_loaded(chunk: WorldChunk)
signal chunk_unloaded(chunk: WorldChunk)

@export var chunk_size: int = 64
@export var world_seed: int = 12345
@export var render_distance: int = 3
@export var unload_distance: int = 5

var loaded_chunks: Dictionary = {}
var generation_queue: Array[Vector2i] = []
var noise_generator: FastNoiseLite
var player_chunk_position: Vector2i

# Biome settings
enum BiomeType {
	GRASSLAND,
	FOREST,
	DESERT,
	MOUNTAINS,
	OCEAN,
	SWAMP,
	TUNDRA,
	VOLCANIC
}

var biome_data: Dictionary = {
	BiomeType.GRASSLAND: {
		"name": "Grassland",
		"blocks": ["grass", "dirt", "stone"],
		"resources": ["iron_ore", "coal", "copper_ore"],
		"trees": ["oak_tree", "birch_tree"],
		"animals": ["rabbit", "deer", "chicken"],
		"temperature": 0.6,
		"humidity": 0.5
	},
	BiomeType.FOREST: {
		"name": "Forest",
		"blocks": ["grass", "dirt", "stone"],
		"resources": ["iron_ore", "coal", "copper_ore", "wood"],
		"trees": ["oak_tree", "pine_tree", "maple_tree"],
		"animals": ["rabbit", "deer", "wolf", "bear"],
		"temperature": 0.5,
		"humidity": 0.7
	},
	BiomeType.DESERT: {
		"name": "Desert",
		"blocks": ["sand", "sandstone", "stone"],
		"resources": ["gold_ore", "copper_ore", "gems"],
		"trees": ["cactus", "dead_tree"],
		"animals": ["lizard", "scorpion", "camel"],
		"temperature": 0.9,
		"humidity": 0.1
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"blocks": ["stone", "granite", "marble"],
		"resources": ["iron_ore", "gold_ore", "gems", "coal"],
		"trees": ["pine_tree", "spruce_tree"],
		"animals": ["mountain_goat", "eagle", "wolf"],
		"temperature": 0.3,
		"humidity": 0.4
	},
	BiomeType.OCEAN: {
		"name": "Ocean",
		"blocks": ["water", "sand", "clay"],
		"resources": ["kelp", "coral", "pearls"],
		"trees": [],
		"animals": ["fish", "shark", "whale", "crab"],
		"temperature": 0.6,
		"humidity": 1.0
	}
}

func _ready():
	_initialize_noise()
	player_chunk_position = Vector2i(0, 0)

func _initialize_noise():
	noise_generator = FastNoiseLite.new()
	noise_generator.seed = world_seed
	noise_generator.frequency = 0.01
	noise_generator.noise_type = FastNoiseLite.TYPE_PERLIN

func update_player_position(player_position: Vector2):
	var new_chunk_pos = world_to_chunk(player_position)
	if new_chunk_pos != player_chunk_position:
		player_chunk_position = new_chunk_pos
		_update_loaded_chunks()

func world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / chunk_size), int(world_pos.y / chunk_size))

func chunk_to_world(chunk_pos: Vector2i) -> Vector2:
	return Vector2(chunk_pos.x * chunk_size, chunk_pos.y * chunk_size)

func _update_loaded_chunks():
	# Generate chunks around player
	for x in range(-render_distance, render_distance + 1):
		for y in range(-render_distance, render_distance + 1):
			var chunk_pos = player_chunk_position + Vector2i(x, y)
			if not loaded_chunks.has(chunk_pos):
				_queue_chunk_generation(chunk_pos)
	
	# Unload distant chunks
	var chunks_to_unload = []
	for chunk_pos in loaded_chunks.keys():
		var distance = (chunk_pos - player_chunk_position).length()
		if distance > unload_distance:
			chunks_to_unload.append(chunk_pos)
	
	for chunk_pos in chunks_to_unload:
		_unload_chunk(chunk_pos)

func _queue_chunk_generation(chunk_pos: Vector2i):
	if not generation_queue.has(chunk_pos):
		generation_queue.append(chunk_pos)
		_generate_chunk(chunk_pos)

func _generate_chunk(chunk_pos: Vector2i):
	var chunk = WorldChunk.new()
	chunk.position = chunk_pos
	chunk.size = chunk_size
	
	# Generate terrain
	_generate_terrain(chunk)
	
	# Generate biome
	_generate_biome(chunk)
	
	# Generate resources
	_generate_resources(chunk)
	
	# Generate vegetation
	_generate_vegetation(chunk)
	
	# Generate structures
	_generate_structures(chunk)
	
	# Generate animals
	_generate_animals(chunk)
	
	# Store chunk
	loaded_chunks[chunk_pos] = chunk
	
	# Remove from queue
	generation_queue.erase(chunk_pos)
	
	chunk_generated.emit(chunk)
	chunk_loaded.emit(chunk)

func _generate_terrain(chunk: WorldChunk):
	var world_pos = chunk_to_world(chunk.position)
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			var world_x = world_pos.x + x
			var world_y = world_pos.y + y
			
			# Generate height map
			var height = noise_generator.get_noise_2d(world_x, world_y)
			height = (height + 1.0) / 2.0  # Normalize to 0-1
			
			# Determine block type based on height
			var block_type = _get_block_for_height(height)
			chunk.set_block(x, y, block_type)

func _get_block_for_height(height: float) -> String:
	if height < 0.3:
		return "water"
	elif height < 0.4:
		return "sand"
	elif height < 0.7:
		return "grass"
	elif height < 0.9:
		return "stone"
	else:
		return "snow"

func _generate_biome(chunk: WorldChunk):
	var world_pos = chunk_to_world(chunk.position)
	
	# Use temperature and humidity to determine biome
	var temperature = noise_generator.get_noise_2d(world_pos.x * 0.001, world_pos.y * 0.001)
	var humidity = noise_generator.get_noise_2d(world_pos.x * 0.001 + 1000, world_pos.y * 0.001 + 1000)
	
	temperature = (temperature + 1.0) / 2.0  # Normalize to 0-1
	humidity = (humidity + 1.0) / 2.0  # Normalize to 0-1
	
	chunk.biome = _determine_biome(temperature, humidity)

func _determine_biome(temperature: float, humidity: float) -> BiomeType:
	if temperature < 0.3:
		return BiomeType.TUNDRA
	elif temperature > 0.8:
		if humidity < 0.3:
			return BiomeType.DESERT
		else:
			return BiomeType.VOLCANIC
	else:
		if humidity < 0.3:
			return BiomeType.DESERT
		elif humidity < 0.6:
			return BiomeType.GRASSLAND
		elif humidity < 0.8:
			return BiomeType.FOREST
		else:
			return BiomeType.SWAMP

func _generate_resources(chunk: WorldChunk):
	var biome_info = biome_data[chunk.biome]
	var resources = biome_info["resources"]
	
	# Generate resource nodes
	for resource in resources:
		var count = _get_resource_count(resource, chunk.biome)
		for i in range(count):
			var pos = Vector2i(randi() % chunk_size, randi() % chunk_size)
			chunk.add_resource(pos, resource)

func _get_resource_count(resource: String, biome: BiomeType) -> int:
	# Return appropriate count based on resource and biome
	match resource:
		"iron_ore":
			return randi() % 3 + 1
		"coal":
			return randi() % 2 + 1
		"gold_ore":
			return randi() % 2
		"gems":
			return randi() % 2
		_:
			return randi() % 3

func _generate_vegetation(chunk: WorldChunk):
	var biome_info = biome_data[chunk.biome]
	var trees = biome_info["trees"]
	
	# Generate trees
	for tree in trees:
		var count = _get_tree_count(tree, chunk.biome)
		for i in range(count):
			var pos = Vector2i(randi() % chunk_size, randi() % chunk_size)
			# Only place trees on valid blocks
			if chunk.get_block(pos.x, pos.y) in ["grass", "dirt"]:
				chunk.add_tree(pos, tree)

func _get_tree_count(tree: String, biome: BiomeType) -> int:
	match biome:
		BiomeType.FOREST:
			return randi() % 15 + 10
		BiomeType.GRASSLAND:
			return randi() % 5 + 2
		BiomeType.DESERT:
			return randi() % 2
		_:
			return randi() % 3

func _generate_structures(chunk: WorldChunk):
	# Generate villages, dungeons, ruins, etc.
	var structure_chance = 0.05  # 5% chance per chunk
	
	if randf() < structure_chance:
		var structure_type = _get_random_structure()
		var pos = Vector2i(randi() % chunk_size, randi() % chunk_size)
		chunk.add_structure(pos, structure_type)

func _get_random_structure() -> String:
	var structures = ["village", "dungeon", "ruins", "cave", "tower"]
	return structures[randi() % structures.size()]

func _generate_animals(chunk: WorldChunk):
	var biome_info = biome_data[chunk.biome]
	var animals = biome_info["animals"]
	
	# Generate animals
	for animal in animals:
		var count = _get_animal_count(animal, chunk.biome)
		for i in range(count):
			var pos = Vector2i(randi() % chunk_size, randi() % chunk_size)
			chunk.add_animal(pos, animal)

func _get_animal_count(animal: String, biome: BiomeType) -> int:
	match animal:
		"rabbit", "chicken":
			return randi() % 8 + 2
		"deer":
			return randi() % 4 + 1
		"wolf", "bear":
			return randi() % 2
		_:
			return randi() % 3

func _unload_chunk(chunk_pos: Vector2i):
	if loaded_chunks.has(chunk_pos):
		var chunk = loaded_chunks[chunk_pos]
		loaded_chunks.erase(chunk_pos)
		chunk_unloaded.emit(chunk)
		chunk.queue_free()

func get_chunk_at(world_pos: Vector2) -> WorldChunk:
	var chunk_pos = world_to_chunk(world_pos)
	return loaded_chunks.get(chunk_pos, null)

func get_block_at(world_pos: Vector2) -> String:
	var chunk = get_chunk_at(world_pos)
	if chunk:
		var local_pos = Vector2i(
			int(world_pos.x) % chunk_size,
			int(world_pos.y) % chunk_size
		)
		return chunk.get_block(local_pos.x, local_pos.y)
	return ""

func set_block_at(world_pos: Vector2, block_type: String):
	var chunk = get_chunk_at(world_pos)
	if chunk:
		var local_pos = Vector2i(
			int(world_pos.x) % chunk_size,
			int(world_pos.y) % chunk_size
		)
		chunk.set_block(local_pos.x, local_pos.y, block_type)

func get_loaded_chunk_count() -> int:
	return loaded_chunks.size()

func get_generation_queue_size() -> int:
	return generation_queue.size() 