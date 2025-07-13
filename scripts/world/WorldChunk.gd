extends Node2D

class_name WorldChunk

@export var chunk_position: Vector2i
@export var size: int = 64
@export var biome: WorldGenerator.BiomeType

var blocks: Array = []
var resources: Dictionary = {}
var trees: Dictionary = {}
var animals: Dictionary = {}
var structures: Dictionary = {}

var is_generated: bool = false
var is_loaded: bool = false

func _init():
	_initialize_blocks()

func _initialize_blocks():
	blocks = []
	for x in range(size):
		blocks.append([])
		for y in range(size):
			blocks[x].append("air")

func set_block(x: int, y: int, block_type: String):
	if _is_valid_position(x, y):
		blocks[x][y] = block_type

func get_block(x: int, y: int) -> String:
	if _is_valid_position(x, y):
		return blocks[x][y]
	return ""

func _is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < size and y >= 0 and y < size

func add_resource(pos: Vector2i, resource_type: String):
	if _is_valid_position(pos.x, pos.y):
		resources[pos] = resource_type

func get_resource(pos: Vector2i) -> String:
	return resources.get(pos, "")

func remove_resource(pos: Vector2i):
	resources.erase(pos)

func add_tree(pos: Vector2i, tree_type: String):
	if _is_valid_position(pos.x, pos.y):
		trees[pos] = tree_type

func get_tree(pos: Vector2i) -> String:
	return trees.get(pos, "")

func remove_tree(pos: Vector2i):
	trees.erase(pos)

func add_animal(pos: Vector2i, animal_type: String):
	if _is_valid_position(pos.x, pos.y):
		animals[pos] = animal_type

func get_animal(pos: Vector2i) -> String:
	return animals.get(pos, "")

func remove_animal(pos: Vector2i):
	animals.erase(pos)

func add_structure(pos: Vector2i, structure_type: String):
	if _is_valid_position(pos.x, pos.y):
		structures[pos] = structure_type

func get_structure(pos: Vector2i) -> String:
	return structures.get(pos, "")

func remove_structure(pos: Vector2i):
	structures.erase(pos)

func get_all_resources() -> Dictionary:
	return resources

func get_all_trees() -> Dictionary:
	return trees

func get_all_animals() -> Dictionary:
	return animals

func get_all_structures() -> Dictionary:
	return structures

func is_position_occupied(pos: Vector2i) -> bool:
	return (resources.has(pos) or trees.has(pos) or 
			animals.has(pos) or structures.has(pos))

func get_biome_name() -> String:
	match biome:
		WorldGenerator.BiomeType.GRASSLAND:
			return "Grassland"
		WorldGenerator.BiomeType.FOREST:
			return "Forest"
		WorldGenerator.BiomeType.DESERT:
			return "Desert"
		WorldGenerator.BiomeType.MOUNTAINS:
			return "Mountains"
		WorldGenerator.BiomeType.OCEAN:
			return "Ocean"
		WorldGenerator.BiomeType.SWAMP:
			return "Swamp"
		WorldGenerator.BiomeType.TUNDRA:
			return "Tundra"
		WorldGenerator.BiomeType.VOLCANIC:
			return "Volcanic"
		_:
			return "Unknown"

func save_chunk_data() -> Dictionary:
	var data = {
		"position": position,
		"size": size,
		"biome": biome,
		"blocks": blocks,
		"resources": resources,
		"trees": trees,
		"animals": animals,
		"structures": structures
	}
	return data

func load_chunk_data(data: Dictionary):
	position = data.get("position", Vector2i.ZERO)
	size = data.get("size", 64)
	biome = data.get("biome", WorldGenerator.BiomeType.GRASSLAND)
	blocks = data.get("blocks", [])
	resources = data.get("resources", {})
	trees = data.get("trees", {})
	animals = data.get("animals", {})
	structures = data.get("structures", {})
	is_loaded = true 