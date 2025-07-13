extends Node

# GameManager autoload singleton - manages core game state
# Access globally as GameManager.function_name()

signal game_state_changed(new_state: GameState)
signal player_spawned(player: Player)

enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	INVENTORY,
	CRAFTING,
	BUILDING,
	CREATIVE,
	MULTIPLAYER_LOBBY
}

var current_state: GameState = GameState.MAIN_MENU
var player: Player
var world_generator: WorldGenerator
var inventory_manager: InventoryManager
var crafting_manager: CraftingManager
var building_manager: BuildingManager
var multiplayer_manager: MultiplayerManager
var economy_manager: EconomyManager
var database_manager: DatabaseManager

var game_data: Dictionary = {}
var current_player_id: String = "default"

func _ready():
	# Initialize all managers
	_initialize_managers()
	
	# Connect signals
	_connect_signals()
	
	# Load game data
	_load_game_data()
	
	print("Nexumi Game Manager initialized!")

func _initialize_managers():
	# Get database manager
	database_manager = DatabaseManager
	
	# Create manager instances
	world_generator = WorldGenerator.new()
	inventory_manager = InventoryManager.new()
	crafting_manager = CraftingManager.new()
	building_manager = BuildingManager.new()
	multiplayer_manager = MultiplayerManager.new()
	economy_manager = EconomyManager.new()
	
	# Add managers as children
	add_child(world_generator)
	add_child(inventory_manager)
	add_child(crafting_manager)
	add_child(building_manager)
	add_child(multiplayer_manager)
	add_child(economy_manager)
	
	# Connect database signals
	database_manager.connection_established.connect(_on_database_connected)
	database_manager.data_loaded.connect(_on_data_loaded)

func _connect_signals():
	# Connect manager signals here
	pass

func _load_game_data():
	# Load configurations, items, recipes, etc.
	pass

func change_state(new_state: GameState):
	if current_state != new_state:
		var old_state = current_state
		current_state = new_state
		game_state_changed.emit(new_state)
		_handle_state_change(old_state, new_state)

func _handle_state_change(old_state: GameState, new_state: GameState):
	match new_state:
		GameState.MAIN_MENU:
			_handle_main_menu()
		GameState.LOADING:
			_handle_loading()
		GameState.PLAYING:
			_handle_playing()
		GameState.PAUSED:
			_handle_paused()
		GameState.INVENTORY:
			_handle_inventory()
		GameState.CRAFTING:
			_handle_crafting()
		GameState.BUILDING:
			_handle_building()
		GameState.CREATIVE:
			_handle_creative()
		GameState.MULTIPLAYER_LOBBY:
			_handle_multiplayer_lobby()

func _handle_main_menu():
	print("Entering main menu")

func _handle_loading():
	print("Loading game...")

func _handle_playing():
	print("Game started!")

func _handle_paused():
	print("Game paused")

func _handle_inventory():
	print("Inventory opened")

func _handle_crafting():
	print("Crafting interface opened")

func _handle_building():
	print("Building mode activated")

func _handle_creative():
	print("Creative mode activated")

func _handle_multiplayer_lobby():
	print("Multiplayer lobby opened")

func spawn_player(spawn_position: Vector2):
	if player:
		player.queue_free()
	
	# Load player scene
	var player_scene = preload("res://scenes/player/Player.tscn")
	player = player_scene.instantiate()
	player.global_position = spawn_position
	
	# Add to scene
	get_tree().current_scene.add_child(player)
	player_spawned.emit(player)

func save_game():
	# Save game state to database
	if player and database_manager:
		var player_data = {
			"player_id": current_player_id,
			"username": "Player1",  # Would get from UI
			"level": 1,
			"experience": 0,
			"health": player.current_health,
			"max_health": player.max_health,
			"position": {"x": player.global_position.x, "y": player.global_position.y},
			"inventory": inventory_manager.save_inventory_data() if inventory_manager else {},
			"equipped_items": {},
			"skills": {},
			"achievements": [],
			"currency": economy_manager.get_currency() if economy_manager else 0,
			"last_login": Time.get_datetime_string_from_system()
		}
		
		database_manager.save_player_data(current_player_id, player_data)
	print("Game saved!")

func load_game():
	# Load game state from database
	if database_manager:
		var player_data = database_manager.load_player_data(current_player_id)
		if player_data.has("position"):
			# Load will be handled by _on_data_loaded signal
			pass
	print("Game loaded!")

func _on_database_connected():
	print("Database connected successfully!")
	# Load initial game data
	load_game()

func _on_data_loaded(collection: String, data: Dictionary):
	match collection:
		"players":
			_load_player_data(data)
		"worlds":
			_load_world_data(data)

func _load_player_data(data: Dictionary):
	if player and data.has("health"):
		player.current_health = data.get("health", 100)
		var pos = data.get("position", {"x": 0, "y": 0})
		player.global_position = Vector2(pos.x, pos.y)
		
		if inventory_manager and data.has("inventory"):
			inventory_manager.load_inventory_data(data["inventory"])
		
		if economy_manager and data.has("currency"):
			economy_manager.add_currency(data["currency"] - economy_manager.get_currency())

func _load_world_data(data: Dictionary):
	# Load world chunk data
	pass

func auto_save():
	# Auto-save every 5 minutes
	save_game()

func quit_game():
	# Save before quitting
	save_game()
	get_tree().quit() 