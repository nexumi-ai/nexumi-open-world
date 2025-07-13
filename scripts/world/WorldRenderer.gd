extends Node2D

class_name WorldRenderer

@export var tile_size: int = 32
@export var render_distance: int = 3

var world_generator: WorldGenerator
var rendered_chunks: Dictionary = {}
var tile_nodes: Dictionary = {}

func _ready():
	# Get world generator
	world_generator = get_node("/root/GameManager").world_generator
	
	# Connect to chunk signals
	if world_generator:
		world_generator.chunk_loaded.connect(_on_chunk_loaded)
		world_generator.chunk_unloaded.connect(_on_chunk_unloaded)

func _on_chunk_loaded(chunk: WorldChunk):
	_render_chunk(chunk)

func _on_chunk_unloaded(chunk: WorldChunk):
	_unrender_chunk(chunk)

func _render_chunk(chunk: WorldChunk):
	if rendered_chunks.has(chunk.position):
		return  # Already rendered
	
	var chunk_node = Node2D.new()
	chunk_node.name = "Chunk_%d_%d" % [chunk.position.x, chunk.position.y]
	
	# Calculate world position
	var world_pos = Vector2(
		chunk.position.x * chunk.size * tile_size,
		chunk.position.y * chunk.size * tile_size
	)
	chunk_node.position = world_pos
	
	# Render blocks
	_render_chunk_blocks(chunk, chunk_node)
	
	# Render resources
	_render_chunk_resources(chunk, chunk_node)
	
	# Render trees
	_render_chunk_trees(chunk, chunk_node)
	
	# Render animals (as moving sprites)
	_render_chunk_animals(chunk, chunk_node)
	
	# Render structures
	_render_chunk_structures(chunk, chunk_node)
	
	add_child(chunk_node)
	rendered_chunks[chunk.position] = chunk_node

func _render_chunk_blocks(chunk: WorldChunk, chunk_node: Node2D):
	for x in range(chunk.size):
		for y in range(chunk.size):
			var block_type = chunk.get_block(x, y)
			if block_type != "air":
				_create_tile_sprite(block_type, Vector2(x, y), chunk_node)

func _render_chunk_resources(chunk: WorldChunk, chunk_node: Node2D):
	var resources = chunk.get_all_resources()
	for pos in resources:
		var resource_type = resources[pos]
		_create_tile_sprite(resource_type, Vector2(pos.x, pos.y), chunk_node, 1)

func _render_chunk_trees(chunk: WorldChunk, chunk_node: Node2D):
	var trees = chunk.get_all_trees()
	for pos in trees:
		var tree_type = trees[pos]
		_create_tile_sprite(tree_type, Vector2(pos.x, pos.y), chunk_node, 2)

func _render_chunk_animals(chunk: WorldChunk, chunk_node: Node2D):
	var animals = chunk.get_all_animals()
	for pos in animals:
		var animal_type = animals[pos]
		_create_animated_sprite(animal_type, Vector2(pos.x, pos.y), chunk_node)

func _render_chunk_structures(chunk: WorldChunk, chunk_node: Node2D):
	var structures = chunk.get_all_structures()
	for pos in structures:
		var structure_type = structures[pos]
		_create_structure_sprite(structure_type, Vector2(pos.x, pos.y), chunk_node)

func _create_tile_sprite(texture_name: String, local_pos: Vector2, parent: Node2D, z_index: int = 0):
	var sprite = Sprite2D.new()
	sprite.texture = TextureManager.get_texture(texture_name)
	sprite.position = Vector2(local_pos.x * tile_size + tile_size/2, local_pos.y * tile_size + tile_size/2)
	sprite.z_index = z_index
	
	# Set texture filtering for pixel art
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	parent.add_child(sprite)

func _create_animated_sprite(animal_type: String, local_pos: Vector2, parent: Node2D):
	var animated_sprite = AnimatedSprite2D.new()
	
	# Create basic animation frames for animals
	var frames = SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 2.0)
	
	# Add basic colored frame
	var texture = TextureManager.get_texture(animal_type)
	if not texture:
		# Create animal-specific colored texture
		var color = _get_animal_color(animal_type)
		texture = _create_colored_texture(color, Vector2i(24, 24))
	
	frames.add_frame("idle", texture)
	animated_sprite.sprite_frames = frames
	animated_sprite.animation = "idle"
	animated_sprite.play()
	
	animated_sprite.position = Vector2(local_pos.x * tile_size + tile_size/2, local_pos.y * tile_size + tile_size/2)
	animated_sprite.z_index = 3
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	parent.add_child(animated_sprite)

func _create_structure_sprite(structure_type: String, local_pos: Vector2, parent: Node2D):
	var sprite = Sprite2D.new()
	
	# Create structure-specific texture
	var color = _get_structure_color(structure_type)
	sprite.texture = _create_colored_texture(color, Vector2i(48, 48))
	
	sprite.position = Vector2(local_pos.x * tile_size + tile_size/2, local_pos.y * tile_size + tile_size/2)
	sprite.z_index = 4
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	parent.add_child(sprite)

func _get_animal_color(animal_type: String) -> Color:
	match animal_type:
		"rabbit":
			return Color.WHITE
		"deer":
			return Color(0.6, 0.4, 0.2)
		"wolf":
			return Color(0.3, 0.3, 0.3)
		"bear":
			return Color(0.2, 0.1, 0.0)
		"chicken":
			return Color.WHITE
		"fish":
			return Color(0.5, 0.5, 1.0)
		"lizard":
			return Color.GREEN
		"scorpion":
			return Color.YELLOW
		_:
			return Color.MAGENTA

func _get_structure_color(structure_type: String) -> Color:
	match structure_type:
		"village":
			return Color(0.8, 0.6, 0.4)
		"dungeon":
			return Color(0.2, 0.2, 0.2)
		"ruins":
			return Color(0.5, 0.5, 0.5)
		"cave":
			return Color(0.3, 0.3, 0.3)
		"tower":
			return Color(0.7, 0.7, 0.8)
		_:
			return Color.MAGENTA

func _create_colored_texture(color: Color, size: Vector2i) -> ImageTexture:
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _unrender_chunk(chunk: WorldChunk):
	if rendered_chunks.has(chunk.position):
		var chunk_node = rendered_chunks[chunk.position]
		chunk_node.queue_free()
		rendered_chunks.erase(chunk.position)

func get_rendered_chunk_count() -> int:
	return rendered_chunks.size()

func clear_all_chunks():
	for chunk_node in rendered_chunks.values():
		chunk_node.queue_free()
	rendered_chunks.clear() 