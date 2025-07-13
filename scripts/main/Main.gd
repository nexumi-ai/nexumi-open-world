extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var world: Node2D = $World
@onready var debug_label: RichTextLabel = $UI/DebugUI/DebugPanel/DebugLabel
@onready var health_bar: ProgressBar = $UI/HUD/HealthBar
@onready var health_label: Label = $UI/HUD/HealthLabel

var game_manager: GameManager
var player: Player

func _ready():
	# Get the game manager
	game_manager = GameManager
	
	# Connect to game manager signals
	game_manager.player_spawned.connect(_on_player_spawned)
	game_manager.game_state_changed.connect(_on_game_state_changed)
	
	# Initialize the game
	_initialize_game()

func _initialize_game():
	# Change to playing state
	game_manager.change_state(GameManager.GameState.PLAYING)
	
	# Spawn player at origin
	game_manager.spawn_player(Vector2.ZERO)
	
	print("Nexumi game initialized!")

func _on_player_spawned(spawned_player: Player):
	player = spawned_player
	world.add_child(player)
	
	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.position_changed.connect(_on_player_position_changed)
	
	# Set camera to follow player
	camera.global_position = player.global_position

func _on_player_health_changed(new_health: int, max_health: int):
	health_bar.value = float(new_health) / float(max_health) * 100.0
	health_label.text = "Health: %d/%d" % [new_health, max_health]

func _on_player_position_changed(new_position: Vector2):
	# Update camera position
	camera.global_position = new_position
	
	# Update world generator with player position
	if game_manager.world_generator:
		game_manager.world_generator.update_player_position(new_position)

func _on_game_state_changed(new_state: GameManager.GameState):
	# Handle UI changes based on game state
	match new_state:
		GameManager.GameState.PLAYING:
			# Show game HUD
			pass
		GameManager.GameState.INVENTORY:
			# Show inventory UI
			pass
		GameManager.GameState.PAUSED:
			# Show pause menu
			pass

func _process(delta):
	_update_debug_info()

func _update_debug_info():
	if not debug_label:
		return
		
	var fps = Engine.get_frames_per_second()
	var player_pos = player.global_position if player else Vector2.ZERO
	var current_biome = "Unknown"
	var loaded_chunks = 0
	var game_state = "Unknown"
	
	if game_manager:
		if game_manager.world_generator:
			var chunk = game_manager.world_generator.get_chunk_at(player_pos)
			if chunk:
				current_biome = chunk.get_biome_name()
			loaded_chunks = game_manager.world_generator.get_loaded_chunk_count()
		
		match game_manager.current_state:
			GameManager.GameState.MAIN_MENU:
				game_state = "Main Menu"
			GameManager.GameState.LOADING:
				game_state = "Loading"
			GameManager.GameState.PLAYING:
				game_state = "Playing"
			GameManager.GameState.PAUSED:
				game_state = "Paused"
			GameManager.GameState.INVENTORY:
				game_state = "Inventory"
			GameManager.GameState.CRAFTING:
				game_state = "Crafting"
			GameManager.GameState.BUILDING:
				game_state = "Building"
			GameManager.GameState.CREATIVE:
				game_state = "Creative"
			GameManager.GameState.MULTIPLAYER_LOBBY:
				game_state = "Multiplayer Lobby"
	
	debug_label.text = """[b]Nexumi Debug Info[/b]
FPS: %d
Player Position: (%.0f, %.0f)
Current Biome: %s
Loaded Chunks: %d
Game State: %s""" % [fps, player_pos.x, player_pos.y, current_biome, loaded_chunks, game_state]

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# ESC key - pause/unpause
		if game_manager.current_state == GameManager.GameState.PLAYING:
			game_manager.change_state(GameManager.GameState.PAUSED)
		elif game_manager.current_state == GameManager.GameState.PAUSED:
			game_manager.change_state(GameManager.GameState.PLAYING) 