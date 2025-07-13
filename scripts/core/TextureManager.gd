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
	# Create placeholders only for items that don't have real textures
	
	# World blocks - use real textures where available
	textures["grass"] = _load_texture_or_fallback("res://assets/sprites/world/grass.png", Color.GREEN)
	textures["dirt"] = _create_colored_texture(Color(0.6, 0.4, 0.2))
	textures["stone"] = _load_texture_or_fallback("res://assets/sprites/world/pebble.png", Color.GRAY)
	textures["sand"] = _create_colored_texture(Color.YELLOW)
	textures["water"] = _create_colored_texture(Color.BLUE)
	textures["wood"] = _create_colored_texture(Color(0.8, 0.6, 0.4))
	textures["snow"] = _create_colored_texture(Color.WHITE)
	
	# Trees and vegetation - use real textures
	textures["oak_tree"] = _load_texture_or_fallback("res://assets/sprites/world/bush.png", Color(0.2, 0.8, 0.2))
	textures["pine_tree"] = _load_texture_or_fallback("res://assets/sprites/world/flower.png", Color(0.1, 0.6, 0.1))
	textures["cactus"] = _load_texture_or_fallback("res://assets/sprites/world/flower_variant.png", Color(0.3, 0.8, 0.3))
	
	# Resources - use real textures
	textures["iron_ore"] = _load_texture_or_fallback("res://assets/sprites/items/bone_pile_1.png", Color(0.7, 0.7, 0.8))
	textures["coal"] = _load_texture_or_fallback("res://assets/sprites/items/bone_pile_2.png", Color(0.2, 0.2, 0.2))
	textures["gold_ore"] = _load_texture_or_fallback("res://assets/sprites/items/coin_pile.png", Color.GOLD)
	
	# Items - use real textures
	textures["wooden_sword"] = _load_texture_or_fallback("res://assets/sprites/items/candle.png", Color(0.8, 0.6, 0.4))
	textures["iron_sword"] = _load_texture_or_fallback("res://assets/sprites/items/wall_skull.png", Color(0.8, 0.8, 0.9))
	textures["wooden_axe"] = _load_texture_or_fallback("res://assets/sprites/items/vase_1.png", Color(0.7, 0.5, 0.3))
	textures["bow"] = _load_texture_or_fallback("res://assets/sprites/items/banner.png", Color(0.6, 0.4, 0.2))
	
	# Currency
	textures["coin"] = _load_texture_or_fallback("res://assets/sprites/items/coin.webp", Color.GOLD)
	
	# Character placeholder
	textures["player"] = _load_texture_or_fallback("res://assets/sprites/player/robot.webp", Color(1.0, 0.8, 0.6))
	
	# Enemies
	textures["rabbit"] = _load_texture_or_fallback("res://assets/sprites/player/playerGrey_walk1.png", Color.WHITE)
	textures["wolf"] = _load_texture_or_fallback("res://assets/sprites/player/enemyWalking_1.png", Color.GRAY)
	textures["bear"] = _load_texture_or_fallback("res://assets/sprites/player/enemyWalking_2.png", Color.BROWN)
	textures["fish"] = _load_texture_or_fallback("res://assets/sprites/player/enemySwimming_1.png", Color.BLUE)

func _load_texture_or_fallback(path: String, fallback_color: Color) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		return _create_colored_texture(fallback_color)

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
	
	# Load real player textures
	var robot_texture = _load_texture_or_fallback("res://assets/sprites/player/robot.webp", Color(1.0, 0.8, 0.6))
	var walk1_texture = _load_texture_or_fallback("res://assets/sprites/player/playerGrey_walk1.png", Color(1.0, 0.8, 0.6))
	var walk2_texture = _load_texture_or_fallback("res://assets/sprites/player/playerGrey_walk2.png", Color(1.0, 0.8, 0.6))
	var up1_texture = _load_texture_or_fallback("res://assets/sprites/player/playerGrey_up1.png", Color(1.0, 0.8, 0.6))
	var up2_texture = _load_texture_or_fallback("res://assets/sprites/player/playerGrey_up2.png", Color(1.0, 0.8, 0.6))
	
	# Create animations with real sprites
	var animations = {
		"idle_down": [robot_texture],
		"idle_up": [up1_texture],
		"idle_left": [robot_texture],
		"idle_right": [robot_texture],
		"walk_down": [walk1_texture, walk2_texture],
		"walk_up": [up1_texture, up2_texture],
		"walk_left": [walk1_texture, walk2_texture],
		"walk_right": [walk1_texture, walk2_texture]
	}
	
	for anim_name in animations:
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, true)
		frames.set_animation_speed(anim_name, 5.0 if "idle" in anim_name else 8.0)
		
		# Add frames for this animation
		for texture in animations[anim_name]:
			frames.add_frame(anim_name, texture)
	
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