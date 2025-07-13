extends Node

class_name TextureManager

static var instance: TextureManager
var textures: Dictionary = {}
var sprite_frames: Dictionary = {}

# Texture atlases for performance
var world_atlas: ImageTexture
var item_atlas: ImageTexture
var character_atlas: ImageTexture
var ui_atlas: ImageTexture

func _ready():
	instance = self
	_load_textures()
	print("Texture Manager initialized")

func _load_textures():
	# Load basic placeholder textures first
	_create_placeholder_textures()
	
	# Load actual texture files if they exist
	_load_world_textures()
	_load_item_textures()
	_load_character_textures()
	_load_ui_textures()

func _create_placeholder_textures():
	# Create basic colored squares as placeholders
	
	# World blocks
	textures["grass"] = _create_colored_texture(Color.GREEN)
	textures["dirt"] = _create_colored_texture(Color(0.6, 0.4, 0.2))
	textures["stone"] = _create_colored_texture(Color.GRAY)
	textures["sand"] = _create_colored_texture(Color.YELLOW)
	textures["water"] = _create_colored_texture(Color.BLUE)
	textures["wood"] = _create_colored_texture(Color(0.8, 0.6, 0.4))
	textures["snow"] = _create_colored_texture(Color.WHITE)
	
	# Trees and vegetation
	textures["oak_tree"] = _create_colored_texture(Color(0.2, 0.8, 0.2))
	textures["pine_tree"] = _create_colored_texture(Color(0.1, 0.6, 0.1))
	textures["cactus"] = _create_colored_texture(Color(0.3, 0.8, 0.3))
	
	# Resources
	textures["iron_ore"] = _create_colored_texture(Color(0.7, 0.7, 0.8))
	textures["coal"] = _create_colored_texture(Color(0.2, 0.2, 0.2))
	textures["gold_ore"] = _create_colored_texture(Color.GOLD)
	
	# Items
	textures["wooden_sword"] = _create_colored_texture(Color(0.8, 0.6, 0.4))
	textures["iron_sword"] = _create_colored_texture(Color(0.8, 0.8, 0.9))
	textures["wooden_axe"] = _create_colored_texture(Color(0.7, 0.5, 0.3))
	
	# Character placeholder
	textures["player"] = _create_colored_texture(Color(1.0, 0.8, 0.6))

func _create_colored_texture(color: Color, size: Vector2i = Vector2i(32, 32)) -> ImageTexture:
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture

func _load_world_textures():
	# Load world block textures
	var world_blocks = ["grass", "dirt", "stone", "sand", "water", "wood", "snow"]
	for block in world_blocks:
		var path = "res://assets/sprites/world/" + block + ".png"
		if ResourceLoader.exists(path):
			textures[block] = load(path)

func _load_item_textures():
	# Load item textures
	var items = ["wooden_sword", "iron_sword", "wooden_axe", "iron_pickaxe", "bow"]
	for item in items:
		var path = "res://assets/sprites/items/" + item + ".png"
		if ResourceLoader.exists(path):
			textures[item] = load(path)

func _load_character_textures():
	# Load character animations
	var player_path = "res://assets/sprites/player/player_spriteframes.tres"
	if ResourceLoader.exists(player_path):
		sprite_frames["player"] = load(player_path)
	else:
		# Create basic player sprite frames
		sprite_frames["player"] = _create_player_sprite_frames()

func _load_ui_textures():
	# Load UI textures
	var ui_elements = ["button", "panel", "slot", "health_bar"]
	for element in ui_elements:
		var path = "res://assets/sprites/ui/" + element + ".png"
		if ResourceLoader.exists(path):
			textures[element] = load(path)

func _create_player_sprite_frames() -> SpriteFrames:
	var frames = SpriteFrames.new()
	
	# Create basic animations with colored rectangles
	var animations = ["idle_down", "idle_up", "idle_left", "idle_right", 
					 "walk_down", "walk_up", "walk_left", "walk_right"]
	
	for anim in animations:
		frames.add_animation(anim)
		frames.set_animation_loop(anim, true)
		frames.set_animation_speed(anim, 5.0 if "idle" in anim else 8.0)
		
		# Add basic frame
		var texture = _create_colored_texture(Color(1.0, 0.8, 0.6), Vector2i(24, 32))
		frames.add_frame(anim, texture)
	
	return frames

static func get_texture(texture_name: String) -> Texture2D:
	if instance and instance.textures.has(texture_name):
		return instance.textures[texture_name]
	
	# Return a default texture if not found
	if instance:
		return instance._create_colored_texture(Color.MAGENTA)
	return null

static func get_sprite_frames(character_name: String) -> SpriteFrames:
	if instance and instance.sprite_frames.has(character_name):
		return instance.sprite_frames[character_name]
	return null

# Create tile map compatible textures
func get_tileset_texture(tile_name: String) -> Texture2D:
	return get_texture(tile_name)

# Download and setup functions for external textures
func download_godot_demo_assets():
	# This would download Godot demo assets
	print("To get Godot demo textures:")
	print("1. Visit: https://github.com/godotengine/godot-demo-projects")
	print("2. Download: 2d/pixel_platformer or 2d/isometric_game")
	print("3. Copy sprites to assets/sprites/ folders")

func setup_texture_import_settings():
	# Set up import settings for pixel art
	print("Setting up texture import settings for pixel art...")
	# This would configure import settings for crisp pixel art 