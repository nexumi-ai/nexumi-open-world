extends Node

# ItemDatabase autoload singleton - manages all game items
# Access globally as ItemDatabase.function_name()

static var instance
var items: Dictionary = {}

func _ready():
	instance = self
	_load_items()

func _load_items():
	# Load basic items
	_add_item("wood", "Wood", "Basic wood material", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("stone", "Stone", "Basic stone material", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("iron_ore", "Iron Ore", "Raw iron ore", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("coal", "Coal", "Fuel material", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("fiber", "Fiber", "Plant fiber", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	
	# Processed materials
	_add_item("wooden_plank", "Wooden Plank", "Processed wood", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("iron_ingot", "Iron Ingot", "Smelted iron", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("stick", "Stick", "Basic crafting component", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	_add_item("rope", "Rope", "Binding material", Item.Type.MATERIAL, Item.Rarity.COMMON, 64)
	
	# Tools
	_add_item("wooden_axe", "Wooden Axe", "Basic chopping tool", Item.Type.TOOL, Item.Rarity.COMMON, 1)
	_add_item("iron_pickaxe", "Iron Pickaxe", "Mining tool", Item.Type.TOOL, Item.Rarity.UNCOMMON, 1)
	_add_item("fishing_rod", "Fishing Rod", "For catching fish", Item.Type.TOOL, Item.Rarity.COMMON, 1)
	
	# Weapons
	_add_item("wooden_sword", "Wooden Sword", "Basic weapon", Item.Type.WEAPON, Item.Rarity.COMMON, 1)
	_add_item("iron_sword", "Iron Sword", "Sturdy weapon", Item.Type.WEAPON, Item.Rarity.UNCOMMON, 1)
	_add_item("bow", "Bow", "Ranged weapon", Item.Type.WEAPON, Item.Rarity.COMMON, 1)
	
	# Blocks
	_add_item("grass", "Grass Block", "Natural ground", Item.Type.BLOCK, Item.Rarity.COMMON, 64)
	_add_item("dirt", "Dirt Block", "Basic soil", Item.Type.BLOCK, Item.Rarity.COMMON, 64)
	_add_item("sand", "Sand Block", "Desert material", Item.Type.BLOCK, Item.Rarity.COMMON, 64)
	_add_item("water", "Water Block", "Liquid block", Item.Type.BLOCK, Item.Rarity.COMMON, 64)
	
	# Building materials
	_add_item("wooden_wall", "Wooden Wall", "Basic wall", Item.Type.BLOCK, Item.Rarity.COMMON, 64)
	_add_item("stone_wall", "Stone Wall", "Strong wall", Item.Type.BLOCK, Item.Rarity.COMMON, 64)
	_add_item("door", "Door", "Entrance way", Item.Type.FURNITURE, Item.Rarity.COMMON, 1)
	
	# Furniture
	_add_item("chest", "Chest", "Storage container", Item.Type.FURNITURE, Item.Rarity.COMMON, 1)
	_add_item("bed", "Bed", "Rest and respawn point", Item.Type.FURNITURE, Item.Rarity.COMMON, 1)
	_add_item("table", "Table", "Crafting surface", Item.Type.FURNITURE, Item.Rarity.COMMON, 1)
	
	# Consumables
	_add_item("apple", "Apple", "Restores health", Item.Type.FOOD, Item.Rarity.COMMON, 16)
	_add_item("bread", "Bread", "Filling food", Item.Type.FOOD, Item.Rarity.COMMON, 16)
	_add_item("health_potion", "Health Potion", "Restores health", Item.Type.POTION, Item.Rarity.COMMON, 8)

func _add_item(id: String, name: String, description: String, type: Item.Type, rarity: Item.Rarity, stack_size: int):
	var item = Item.new(id, name, description, type, rarity)
	item.max_stack_size = stack_size
	
	# Set type-specific properties
	match type:
		Item.Type.WEAPON:
			_set_weapon_properties(item, id)
		Item.Type.TOOL:
			_set_tool_properties(item, id)
		Item.Type.FOOD:
			_set_food_properties(item, id)
		Item.Type.POTION:
			_set_potion_properties(item, id)
		Item.Type.BLOCK:
			_set_block_properties(item, id)
	
	items[id] = item

func _set_weapon_properties(item: Item, id: String):
	match id:
		"wooden_sword":
			item.damage = 5
			item.attack_speed = 1.2
			item.range = 32
		"iron_sword":
			item.damage = 12
			item.attack_speed = 1.0
			item.range = 35
		"bow":
			item.damage = 8
			item.attack_speed = 0.8
			item.range = 200

func _set_tool_properties(item: Item, id: String):
	match id:
		"wooden_axe":
			item.durability = 100
			item.max_durability = 100
			item.efficiency = 1.0
		"iron_pickaxe":
			item.durability = 250
			item.max_durability = 250
			item.efficiency = 1.5
		"fishing_rod":
			item.durability = 150
			item.max_durability = 150
			item.efficiency = 1.0

func _set_food_properties(item: Item, id: String):
	match id:
		"apple":
			item.health_restore = 5
			item.hunger_restore = 10
		"bread":
			item.health_restore = 3
			item.hunger_restore = 20

func _set_potion_properties(item: Item, id: String):
	match id:
		"health_potion":
			item.health_restore = 25

func _set_block_properties(item: Item, id: String):
	match id:
		"grass":
			item.hardness = 0.5
		"dirt":
			item.hardness = 0.5
		"stone":
			item.hardness = 2.0
		"sand":
			item.hardness = 0.3
		"water":
			item.hardness = 0.0
			item.transparent = true

static func get_item(id: String) -> Item:
	if instance and instance.items.has(id):
		return instance.items[id].create_copy()
	return null

static func get_all_items() -> Dictionary:
	if instance:
		return instance.items
	return {}

static func get_items_by_type(type: Item.Type) -> Array[Item]:
	var filtered_items = []
	if instance:
		for item in instance.items.values():
			if item.type == type:
				filtered_items.append(item)
	return filtered_items 