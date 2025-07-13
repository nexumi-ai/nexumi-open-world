extends Node

class_name InventoryManager

signal inventory_changed()
signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)
signal inventory_full()

@export var max_inventory_size: int = 40
@export var max_stack_size: int = 64

var inventory_slots: Array[InventorySlot] = []
var equipped_items: Dictionary = {}

func _ready():
	_initialize_inventory()

func _initialize_inventory():
	inventory_slots.clear()
	for i in range(max_inventory_size):
		inventory_slots.append(InventorySlot.new())

func add_item(item: Item, quantity: int = 1) -> bool:
	if not item:
		return false
	
	var remaining_quantity = quantity
	
	# Try to stack with existing items first
	if item.is_stackable():
		for slot in inventory_slots:
			if slot.has_item() and slot.item.can_stack_with(item):
				var can_add = min(remaining_quantity, slot.get_available_space())
				if can_add > 0:
					slot.add_quantity(can_add)
					remaining_quantity -= can_add
					if remaining_quantity <= 0:
						break
	
	# Add to empty slots
	while remaining_quantity > 0:
		var empty_slot = _get_first_empty_slot()
		if not empty_slot:
			inventory_full.emit()
			return false
		
		var can_add = min(remaining_quantity, item.max_stack_size)
		empty_slot.set_item(item, can_add)
		remaining_quantity -= can_add
	
	item_added.emit(item, quantity)
	inventory_changed.emit()
	return true

func remove_item(item: Item, quantity: int = 1) -> bool:
	if not item:
		return false
	
	var remaining_quantity = quantity
	
	# Find slots with this item and remove
	for slot in inventory_slots:
		if slot.has_item() and slot.item.id == item.id:
			var can_remove = min(remaining_quantity, slot.quantity)
			slot.remove_quantity(can_remove)
			remaining_quantity -= can_remove
			
			if remaining_quantity <= 0:
				break
	
	if remaining_quantity < quantity:
		item_removed.emit(item, quantity - remaining_quantity)
		inventory_changed.emit()
		return remaining_quantity == 0
	
	return false

func has_item(item: Item, quantity: int = 1) -> bool:
	if not item:
		return false
	
	var total_quantity = 0
	for slot in inventory_slots:
		if slot.has_item() and slot.item.id == item.id:
			total_quantity += slot.quantity
			if total_quantity >= quantity:
				return true
	
	return false

func get_item_count(item: Item) -> int:
	if not item:
		return 0
	
	var total_quantity = 0
	for slot in inventory_slots:
		if slot.has_item() and slot.item.id == item.id:
			total_quantity += slot.quantity
	
	return total_quantity

func _get_first_empty_slot() -> InventorySlot:
	for slot in inventory_slots:
		if not slot.has_item():
			return slot
	return null

func get_empty_slot_count() -> int:
	var count = 0
	for slot in inventory_slots:
		if not slot.has_item():
			count += 1
	return count

func is_inventory_full() -> bool:
	return get_empty_slot_count() == 0

func get_slot(index: int) -> InventorySlot:
	if index >= 0 and index < inventory_slots.size():
		return inventory_slots[index]
	return null

func swap_slots(index1: int, index2: int):
	if index1 >= 0 and index1 < inventory_slots.size() and index2 >= 0 and index2 < inventory_slots.size():
		var temp_item = inventory_slots[index1].item
		var temp_quantity = inventory_slots[index1].quantity
		
		inventory_slots[index1].set_item(inventory_slots[index2].item, inventory_slots[index2].quantity)
		inventory_slots[index2].set_item(temp_item, temp_quantity)
		
		inventory_changed.emit()

func sort_inventory():
	# Sort by item type, then by name
	var filled_slots = []
	var empty_slots = []
	
	for slot in inventory_slots:
		if slot.has_item():
			filled_slots.append(slot)
		else:
			empty_slots.append(slot)
	
	filled_slots.sort_custom(func(a, b): return a.item.name < b.item.name)
	
	inventory_slots.clear()
	inventory_slots.append_array(filled_slots)
	inventory_slots.append_array(empty_slots)
	
	inventory_changed.emit()

func clear_inventory():
	for slot in inventory_slots:
		slot.clear()
	inventory_changed.emit()

func get_all_items() -> Array[Dictionary]:
	var items = []
	for slot in inventory_slots:
		if slot.has_item():
			items.append({
				"item": slot.item,
				"quantity": slot.quantity
			})
	return items

func equip_item(item: Item, slot_type: String):
	if item and item.is_weapon() or item.is_tool():
		equipped_items[slot_type] = item
		# Remove from inventory
		remove_item(item, 1)

func unequip_item(slot_type: String):
	if equipped_items.has(slot_type):
		var item = equipped_items[slot_type]
		equipped_items.erase(slot_type)
		# Add back to inventory
		add_item(item, 1)

func get_equipped_item(slot_type: String) -> Item:
	return equipped_items.get(slot_type, null)

func save_inventory_data() -> Dictionary:
	var data = {
		"slots": [],
		"equipped_items": equipped_items
	}
	
	for slot in inventory_slots:
		data["slots"].append(slot.save_data())
	
	return data

func load_inventory_data(data: Dictionary):
	var slots_data = data.get("slots", [])
	equipped_items = data.get("equipped_items", {})
	
	for i in range(min(slots_data.size(), inventory_slots.size())):
		inventory_slots[i].load_data(slots_data[i])
	
	inventory_changed.emit()

# Inner class for inventory slots
class InventorySlot:
	var item: Item
	var quantity: int = 0
	
	func set_item(new_item: Item, new_quantity: int = 1):
		item = new_item
		quantity = new_quantity
	
	func clear():
		item = null
		quantity = 0
	
	func has_item() -> bool:
		return item != null and quantity > 0
	
	func add_quantity(amount: int):
		quantity += amount
	
	func remove_quantity(amount: int):
		quantity = max(0, quantity - amount)
		if quantity == 0:
			item = null
	
	func get_available_space() -> int:
		if not item:
			return 0
		return item.max_stack_size - quantity
	
	func save_data() -> Dictionary:
		return {
			"item": item.id if item else "",
			"quantity": quantity
		}
	
	func load_data(data: Dictionary):
		var item_id = data.get("item", "")
		quantity = data.get("quantity", 0)
		
		if item_id != "":
			# Load item by ID from item database
			item = ItemDatabase.get_item(item_id)
		else:
			item = null 