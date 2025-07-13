extends Node

class_name MultiplayerManager

signal player_connected(id: int)
signal player_disconnected(id: int)
signal connection_established()
signal connection_failed()

var is_server: bool = false
var is_client: bool = false
var connected_players: Dictionary = {}

func _ready():
	print("Multiplayer Manager initialized")

func start_server(port: int = 8080):
	is_server = true
	print("Server started on port ", port)

func connect_to_server(ip: String, port: int = 8080):
	is_client = true
	print("Connecting to server at ", ip, ":", port)

func disconnect_from_server():
	is_client = false
	is_server = false
	print("Disconnected from server")

func get_connected_player_count() -> int:
	return connected_players.size() 