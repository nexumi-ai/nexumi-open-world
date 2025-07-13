extends Resource

class_name Item

enum Type {
	WEAPON,
	TOOL,
	BLOCK,
	CONSUMABLE,
	MATERIAL,
	FURNITURE,
	SEED,
	FOOD,
	POTION,
	CURRENCY,
	QUEST_ITEM,
	MOUNT,
	PET
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var id: String
@export var name: String
@export var description: String
@export var type: Type
@export var rarity: Rarity
@export var icon: Texture2D
@export var max_stack_size: int = 1
@export var value: int = 0
@export var weight: float = 0.0

# Combat stats (for weapons)
@export var damage: int = 0
@export var attack_speed: float = 1.0
@export var range: float = 0.0

# Tool stats (for tools)
@export var durability: int = 0
@export var max_durability: int = 0
@export var efficiency: float = 1.0

# Block stats (for blocks)
@export var hardness: float = 1.0
@export var light_level: int = 0
@export var transparent: bool = false

# Consumable stats (for food/potions)
@export var health_restore: int = 0
@export var hunger_restore: int = 0
@export var thirst_restore: int = 0
@export var effects: Array = []

# Crafting
@export var craftable: bool = false
@export var recipe_ingredients: Array = []
@export var crafting_time: float = 1.0
@export var crafting_station: String = ""

# Trading
@export var tradeable: bool = true
@export var sellable: bool = true
@export var buyable: bool = true

func _init(
	p_id: String = "",
	p_name: String = "",
	p_description: String = "",
	p_type: Type = Type.MATERIAL,
	p_rarity: Rarity = Rarity.COMMON
):
	id = p_id
	name = p_name
	description = p_description
	type = p_type
	rarity = p_rarity

func get_display_name() -> String:
	var color = get_rarity_color()
	return "[color=%s]%s[/color]" % [color, name]

func get_rarity_color() -> String:
	match rarity:
		Rarity.COMMON:
			return "#FFFFFF"
		Rarity.UNCOMMON:
			return "#1EFF00"
		Rarity.RARE:
			return "#0070DD"
		Rarity.EPIC:
			return "#A335EE"
		Rarity.LEGENDARY:
			return "#FF8000"
		_:
			return "#FFFFFF"

func get_tooltip() -> String:
	var tooltip = "[b]%s[/b]\n" % get_display_name()
	tooltip += "%s\n\n" % description
	
	match type:
		Type.WEAPON:
			tooltip += "Damage: %d\n" % damage
			tooltip += "Attack Speed: %.1f\n" % attack_speed
			tooltip += "Range: %.1f\n" % range
		Type.TOOL:
			tooltip += "Durability: %d/%d\n" % [durability, max_durability]
			tooltip += "Efficiency: %.1f\n" % efficiency
		Type.CONSUMABLE:
			if health_restore > 0:
				tooltip += "Health: +%d\n" % health_restore
			if hunger_restore > 0:
				tooltip += "Hunger: +%d\n" % hunger_restore
			if thirst_restore > 0:
				tooltip += "Thirst: +%d\n" % thirst_restore
		Type.BLOCK:
			tooltip += "Hardness: %.1f\n" % hardness
			if light_level > 0:
				tooltip += "Light Level: %d\n" % light_level
	
	if value > 0:
		tooltip += "\nValue: %d coins" % value
	
	return tooltip

func can_stack_with(other_item: Item) -> bool:
	return id == other_item.id and max_stack_size > 1

func is_stackable() -> bool:
	return max_stack_size > 1

func is_weapon() -> bool:
	return type == Type.WEAPON

func is_tool() -> bool:
	return type == Type.TOOL

func is_consumable() -> bool:
	return type == Type.CONSUMABLE

func is_block() -> bool:
	return type == Type.BLOCK

func use(player: Player):
	match type:
		Type.CONSUMABLE:
			_use_consumable(player)
		Type.WEAPON:
			player.equip_weapon(self)
		Type.TOOL:
			player.equip_tool(self)
		Type.FOOD:
			_use_food(player)
		Type.POTION:
			_use_potion(player)

func _use_consumable(player: Player):
	if health_restore > 0:
		player.heal(health_restore)
	# Add other consumable effects

func _use_food(player: Player):
	if hunger_restore > 0:
		# Restore hunger
		pass
	if thirst_restore > 0:
		# Restore thirst
		pass

func _use_potion(player: Player):
	# Apply potion effects
	for effect in effects:
		# Apply effect to player
		pass

func repair(amount: int):
	if type == Type.TOOL:
		durability = min(max_durability, durability + amount)

func damage_tool(amount: int):
	if type == Type.TOOL:
		durability = max(0, durability - amount)
		return durability <= 0
	return false

func create_copy() -> Item:
	var new_item = Item.new()
	new_item.id = id
	new_item.name = name
	new_item.description = description
	new_item.type = type
	new_item.rarity = rarity
	new_item.icon = icon
	new_item.max_stack_size = max_stack_size
	new_item.value = value
	new_item.weight = weight
	new_item.damage = damage
	new_item.attack_speed = attack_speed
	new_item.range = range
	new_item.durability = durability
	new_item.max_durability = max_durability
	new_item.efficiency = efficiency
	new_item.hardness = hardness
	new_item.light_level = light_level
	new_item.transparent = transparent
	new_item.health_restore = health_restore
	new_item.hunger_restore = hunger_restore
	new_item.thirst_restore = thirst_restore
	new_item.effects = effects.duplicate()
	new_item.craftable = craftable
	new_item.recipe_ingredients = recipe_ingredients.duplicate()
	new_item.crafting_time = crafting_time
	new_item.crafting_station = crafting_station
	new_item.tradeable = tradeable
	new_item.sellable = sellable
	new_item.buyable = buyable
	return new_item 