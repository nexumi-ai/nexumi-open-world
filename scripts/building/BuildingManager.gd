extends Node

class_name BuildingManager

signal building_placed(building_type: String, position: Vector2)
signal building_removed(building_type: String, position: Vector2)

var placed_buildings: Dictionary = {}
var building_mode: bool = false
var selected_building: String = ""

func _ready():
	print("Building Manager initialized")

func enter_building_mode():
	building_mode = true

func exit_building_mode():
	building_mode = false

func set_selected_building(building_type: String):
	selected_building = building_type

func place_building(building_type: String, position: Vector2) -> bool:
	# TODO: Implement building placement logic
	placed_buildings[position] = building_type
	building_placed.emit(building_type, position)
	return true

func remove_building(position: Vector2) -> bool:
	if placed_buildings.has(position):
		var building_type = placed_buildings[position]
		placed_buildings.erase(position)
		building_removed.emit(building_type, position)
		return true
	return false

func get_building_at(position: Vector2) -> String:
	return placed_buildings.get(position, "") 