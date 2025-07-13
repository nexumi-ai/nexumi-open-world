extends Node

class_name DatabaseManager

signal connection_established()
signal connection_failed()
signal data_saved(collection: String, document_id: String)
signal data_loaded(collection: String, data: Dictionary)

# MongoDB connection settings
@export var database_url: String = "mongodb://admin:nexumi123@localhost:27017"
@export var database_name: String = "nexumi_game"
@export var use_local_fallback: bool = true

# Collections
enum Collection {
	PLAYERS,
	WORLDS,
	ITEMS,
	GUILDS,
	MARKETPLACE,
	ANALYTICS
}

var collection_names = {
	Collection.PLAYERS: "players",
	Collection.WORLDS: "worlds", 
	Collection.ITEMS: "items",
	Collection.GUILDS: "guilds",
	Collection.MARKETPLACE: "marketplace",
	Collection.ANALYTICS: "analytics"
}

var is_connected: bool = false
var local_db: Dictionary = {}  # Fallback local storage
var http_request: HTTPRequest

func _ready():
	# Create HTTP request node for REST API calls
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Try to connect to MongoDB
	_connect_to_database()

func _connect_to_database():
	print("Attempting to connect to MongoDB at: ", database_url)
	
	# For production, you would use MongoDB driver
	# For now, we'll simulate connection and use local fallback
	
	if use_local_fallback:
		_setup_local_database()
		is_connected = true
		connection_established.emit()
		print("Database connected (local fallback)")
	else:
		# In a real implementation, this would connect to actual MongoDB
		_test_mongodb_connection()

func _test_mongodb_connection():
	# This would test actual MongoDB connection
	# For now, we'll simulate it
	await get_tree().create_timer(1.0).timeout
	
	if randf() > 0.5:  # Simulate random connection success/failure
		is_connected = true
		connection_established.emit()
		print("MongoDB connection established")
	else:
		connection_failed.emit()
		print("MongoDB connection failed, using local fallback")
		_setup_local_database()

func _setup_local_database():
	# Initialize local database structure
	for collection in Collection.values():
		var collection_name = collection_names[collection]
		local_db[collection_name] = {}
	
	# Create default data
	_create_default_data()

func _create_default_data():
	# Create default player data structure
	local_db["players"]["default"] = {
		"player_id": "default",
		"username": "Player1",
		"level": 1,
		"experience": 0,
		"health": 100,
		"position": {"x": 0, "y": 0},
		"inventory": [],
		"equipped_items": {},
		"skills": {},
		"achievements": [],
		"created_at": Time.get_datetime_string_from_system(),
		"last_login": Time.get_datetime_string_from_system()
	}
	
	# Create default world data
	local_db["worlds"]["default"] = {
		"world_id": "default",
		"name": "Main World",
		"seed": 12345,
		"chunks": {},
		"structures": {},
		"created_at": Time.get_datetime_string_from_system()
	}

# Player Data Operations
func save_player_data(player_id: String, player_data: Dictionary):
	var collection = collection_names[Collection.PLAYERS]
	
	if is_connected and not use_local_fallback:
		_save_to_mongodb(collection, player_id, player_data)
	else:
		_save_to_local(collection, player_id, player_data)

func load_player_data(player_id: String) -> Dictionary:
	var collection = collection_names[Collection.PLAYERS]
	
	if is_connected and not use_local_fallback:
		_load_from_mongodb(collection, player_id)
		return {}  # Will be returned via signal
	else:
		return _load_from_local(collection, player_id)

func create_new_player(username: String) -> String:
	var player_id = _generate_player_id()
	var player_data = {
		"player_id": player_id,
		"username": username,
		"level": 1,
		"experience": 0,
		"health": 100,
		"max_health": 100,
		"position": {"x": 0, "y": 0},
		"inventory": [],
		"equipped_items": {},
		"skills": {
			"mining": 1,
			"crafting": 1,
			"combat": 1,
			"farming": 1
		},
		"achievements": [],
		"currency": 100,
		"created_at": Time.get_datetime_string_from_system(),
		"last_login": Time.get_datetime_string_from_system()
	}
	
	save_player_data(player_id, player_data)
	return player_id

# World Data Operations
func save_world_chunk(world_id: String, chunk_position: Vector2i, chunk_data: Dictionary):
	var collection = collection_names[Collection.WORLDS]
	var chunk_key = "%s_chunk_%d_%d" % [world_id, chunk_position.x, chunk_position.y]
	
	if is_connected and not use_local_fallback:
		_save_to_mongodb(collection, chunk_key, chunk_data)
	else:
		_save_to_local(collection, chunk_key, chunk_data)

func load_world_chunk(world_id: String, chunk_position: Vector2i) -> Dictionary:
	var collection = collection_names[Collection.WORLDS]
	var chunk_key = "%s_chunk_%d_%d" % [world_id, chunk_position.x, chunk_position.y]
	
	if is_connected and not use_local_fallback:
		_load_from_mongodb(collection, chunk_key)
		return {}  # Will be returned via signal
	else:
		return _load_from_local(collection, chunk_key)

# Marketplace Operations
func save_marketplace_listing(listing_data: Dictionary):
	var listing_id = _generate_id()
	var collection = collection_names[Collection.MARKETPLACE]
	
	listing_data["listing_id"] = listing_id
	listing_data["created_at"] = Time.get_datetime_string_from_system()
	listing_data["status"] = "active"
	
	if is_connected and not use_local_fallback:
		_save_to_mongodb(collection, listing_id, listing_data)
	else:
		_save_to_local(collection, listing_id, listing_data)

func get_marketplace_listings(category: String = "") -> Array:
	var collection = collection_names[Collection.MARKETPLACE]
	
	if is_connected and not use_local_fallback:
		# Would query MongoDB with filters
		return []
	else:
		var listings = []
		for listing_id in local_db[collection]:
			var listing = local_db[collection][listing_id]
			if category == "" or listing.get("category", "") == category:
				listings.append(listing)
		return listings

# Analytics Operations
func track_event(event_name: String, event_data: Dictionary):
	var collection = collection_names[Collection.ANALYTICS]
	var event_id = _generate_id()
	
	var analytics_data = {
		"event_id": event_id,
		"event_name": event_name,
		"event_data": event_data,
		"timestamp": Time.get_datetime_string_from_system(),
		"session_id": _get_session_id()
	}
	
	if is_connected and not use_local_fallback:
		_save_to_mongodb(collection, event_id, analytics_data)
	else:
		_save_to_local(collection, event_id, analytics_data)

# Local Database Operations
func _save_to_local(collection: String, document_id: String, data: Dictionary):
	if not local_db.has(collection):
		local_db[collection] = {}
	
	local_db[collection][document_id] = data
	data_saved.emit(collection, document_id)
	
	# Save to file for persistence
	_save_local_db_to_file()

func _load_from_local(collection: String, document_id: String) -> Dictionary:
	if local_db.has(collection) and local_db[collection].has(document_id):
		var data = local_db[collection][document_id]
		data_loaded.emit(collection, data)
		return data
	return {}

func _save_local_db_to_file():
	var file = FileAccess.open("user://nexumi_local_db.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(local_db))
		file.close()

func _load_local_db_from_file():
	var file = FileAccess.open("user://nexumi_local_db.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			local_db = json.data
		else:
			print("Error parsing local database file")

# MongoDB Operations (REST API)
func _save_to_mongodb(collection: String, document_id: String, data: Dictionary):
	# In a real implementation, this would use MongoDB REST API or driver
	var url = "%s/%s/%s" % [database_url.replace("mongodb://", "http://"), database_name, collection]
	var headers = ["Content-Type: application/json"]
	var json_data = JSON.stringify(data)
	
	# This is a simplified example - real implementation would be more complex
	print("Would save to MongoDB: ", collection, "/", document_id)
	data_saved.emit(collection, document_id)

func _load_from_mongodb(collection: String, document_id: String):
	# In a real implementation, this would query MongoDB
	var url = "%s/%s/%s/%s" % [database_url.replace("mongodb://", "http://"), database_name, collection, document_id]
	
	print("Would load from MongoDB: ", collection, "/", document_id)
	# Simulate async loading
	await get_tree().create_timer(0.1).timeout
	data_loaded.emit(collection, {})

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	# Handle HTTP responses from MongoDB REST API
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			# Process the response data
			pass

# Utility Functions
func _generate_player_id() -> String:
	return "player_" + _generate_id()

func _generate_id() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi())

func _get_session_id() -> String:
	# Generate or get current session ID
	return "session_" + str(Time.get_unix_time_from_system())

# Database Health Check
func get_database_status() -> Dictionary:
	return {
		"connected": is_connected,
		"database_url": database_url,
		"database_name": database_name,
		"using_local_fallback": use_local_fallback,
		"local_collections": local_db.keys()
	}

# Backup and Export
func export_local_data() -> Dictionary:
	return local_db.duplicate(true)

func import_local_data(data: Dictionary):
	local_db = data
	_save_local_db_to_file() 