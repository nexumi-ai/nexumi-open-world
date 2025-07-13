extends Node

class_name CraftingManager

signal item_crafted(item: Item, quantity: int)
signal crafting_started(recipe: CraftingRecipe)
signal crafting_completed(recipe: CraftingRecipe)

var recipes: Dictionary = {}
var active_crafting: Array[CraftingTask] = []

func _ready():
	_load_recipes()

func _load_recipes():
	# Load all crafting recipes
	_add_basic_recipes()
	_add_weapon_recipes()
	_add_tool_recipes()
	_add_building_recipes()
	_add_furniture_recipes()

func _add_basic_recipes():
	# Basic crafting recipes
	add_recipe("wooden_plank", [
		{"item_id": "wood", "quantity": 1}
	], 4, 1.0)
	
	add_recipe("stick", [
		{"item_id": "wooden_plank", "quantity": 2}
	], 4, 0.5)
	
	add_recipe("rope", [
		{"item_id": "fiber", "quantity": 3}
	], 1, 2.0)

func _add_weapon_recipes():
	# Weapon recipes
	add_recipe("wooden_sword", [
		{"item_id": "wooden_plank", "quantity": 2},
		{"item_id": "stick", "quantity": 1}
	], 1, 5.0, "workbench")
	
	add_recipe("iron_sword", [
		{"item_id": "iron_ingot", "quantity": 2},
		{"item_id": "stick", "quantity": 1}
	], 1, 8.0, "anvil")
	
	add_recipe("bow", [
		{"item_id": "stick", "quantity": 3},
		{"item_id": "rope", "quantity": 2}
	], 1, 6.0, "workbench")

func _add_tool_recipes():
	# Tool recipes
	add_recipe("wooden_axe", [
		{"item_id": "wooden_plank", "quantity": 3},
		{"item_id": "stick", "quantity": 2}
	], 1, 4.0, "workbench")
	
	add_recipe("iron_pickaxe", [
		{"item_id": "iron_ingot", "quantity": 3},
		{"item_id": "stick", "quantity": 2}
	], 1, 7.0, "anvil")
	
	add_recipe("fishing_rod", [
		{"item_id": "stick", "quantity": 3},
		{"item_id": "rope", "quantity": 1}
	], 1, 3.0, "workbench")

func _add_building_recipes():
	# Building recipes
	add_recipe("wooden_wall", [
		{"item_id": "wooden_plank", "quantity": 4}
	], 1, 2.0, "workbench")
	
	add_recipe("stone_wall", [
		{"item_id": "stone", "quantity": 4}
	], 1, 3.0, "workbench")
	
	add_recipe("door", [
		{"item_id": "wooden_plank", "quantity": 6},
		{"item_id": "iron_ingot", "quantity": 1}
	], 1, 5.0, "workbench")

func _add_furniture_recipes():
	# Furniture recipes
	add_recipe("chest", [
		{"item_id": "wooden_plank", "quantity": 8}
	], 1, 4.0, "workbench")
	
	add_recipe("bed", [
		{"item_id": "wooden_plank", "quantity": 3},
		{"item_id": "wool", "quantity": 3}
	], 1, 6.0, "workbench")
	
	add_recipe("table", [
		{"item_id": "wooden_plank", "quantity": 6}
	], 1, 3.0, "workbench")

func add_recipe(result_item_id: String, ingredients: Array[Dictionary], result_quantity: int = 1, crafting_time: float = 1.0, required_station: String = ""):
	var recipe = CraftingRecipe.new()
	recipe.result_item_id = result_item_id
	recipe.ingredients = ingredients
	recipe.result_quantity = result_quantity
	recipe.crafting_time = crafting_time
	recipe.required_station = required_station
	
	recipes[result_item_id] = recipe

func get_recipe(item_id: String) -> CraftingRecipe:
	return recipes.get(item_id, null)

func get_all_recipes() -> Array[CraftingRecipe]:
	return recipes.values()

func get_available_recipes(inventory_manager: InventoryManager, station: String = "") -> Array[CraftingRecipe]:
	var available = []
	
	for recipe in recipes.values():
		if can_craft_recipe(recipe, inventory_manager, station):
			available.append(recipe)
	
	return available

func can_craft_recipe(recipe: CraftingRecipe, inventory_manager: InventoryManager, station: String = "") -> bool:
	# Check if required station is available
	if recipe.required_station != "" and recipe.required_station != station:
		return false
	
	# Check if we have all ingredients
	for ingredient in recipe.ingredients:
		var required_item = ItemDatabase.get_item(ingredient["item_id"])
		var required_quantity = ingredient["quantity"]
		
		if not inventory_manager.has_item(required_item, required_quantity):
			return false
	
	return true

func start_crafting(recipe: CraftingRecipe, inventory_manager: InventoryManager, station: String = "") -> bool:
	if not can_craft_recipe(recipe, inventory_manager, station):
		return false
	
	# Remove ingredients from inventory
	for ingredient in recipe.ingredients:
		var required_item = ItemDatabase.get_item(ingredient["item_id"])
		var required_quantity = ingredient["quantity"]
		inventory_manager.remove_item(required_item, required_quantity)
	
	# Create crafting task
	var task = CraftingTask.new()
	task.recipe = recipe
	task.start_time = Time.get_time_dict_from_system()
	task.duration = recipe.crafting_time
	
	active_crafting.append(task)
	crafting_started.emit(recipe)
	
	return true

func _process(delta):
	_update_crafting_tasks(delta)

func _update_crafting_tasks(delta):
	var completed_tasks = []
	
	for task in active_crafting:
		task.elapsed_time += delta
		
		if task.elapsed_time >= task.duration:
			completed_tasks.append(task)
	
	# Complete finished tasks
	for task in completed_tasks:
		_complete_crafting_task(task)

func _complete_crafting_task(task: CraftingTask):
	active_crafting.erase(task)
	
	# Create result item
	var result_item = ItemDatabase.get_item(task.recipe.result_item_id)
	var game_manager = get_node("/root/GameManager")
	
	if game_manager and game_manager.inventory_manager:
		game_manager.inventory_manager.add_item(result_item, task.recipe.result_quantity)
	
	crafting_completed.emit(task.recipe)
	item_crafted.emit(result_item, task.recipe.result_quantity)

func get_crafting_progress() -> Array[Dictionary]:
	var progress = []
	
	for task in active_crafting:
		progress.append({
			"recipe": task.recipe,
			"progress": task.elapsed_time / task.duration,
			"remaining_time": task.duration - task.elapsed_time
		})
	
	return progress

func cancel_crafting(recipe: CraftingRecipe):
	for task in active_crafting:
		if task.recipe == recipe:
			active_crafting.erase(task)
			# TODO: Return ingredients to inventory
			break

# Crafting Recipe class
class CraftingRecipe:
	var result_item_id: String
	var ingredients: Array[Dictionary] = []
	var result_quantity: int = 1
	var crafting_time: float = 1.0
	var required_station: String = ""
	var unlock_level: int = 0
	var experience_gained: int = 10
	
	func get_ingredient_list() -> String:
		var ingredient_strings = []
		for ingredient in ingredients:
			var item = ItemDatabase.get_item(ingredient["item_id"])
			if item:
				ingredient_strings.append("%s x%d" % [item.name, ingredient["quantity"]])
		return ", ".join(ingredient_strings)
	
	func get_display_name() -> String:
		var result_item = ItemDatabase.get_item(result_item_id)
		if result_item:
			return result_item.name
		return result_item_id

# Crafting Task class
class CraftingTask:
	var recipe: CraftingRecipe
	var start_time: Dictionary
	var duration: float
	var elapsed_time: float = 0.0
	
	func get_progress() -> float:
		return elapsed_time / duration
	
	func get_remaining_time() -> float:
		return duration - elapsed_time 