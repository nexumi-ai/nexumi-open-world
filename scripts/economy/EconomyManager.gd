extends Node

class_name EconomyManager

signal currency_changed(new_amount: int)
signal trade_completed(item: Item, cost: int)

var player_currency: int = 0
var shops: Dictionary = {}
var auction_house: Dictionary = {}

func _ready():
	print("Economy Manager initialized")

func add_currency(amount: int):
	player_currency += amount
	currency_changed.emit(player_currency)

func remove_currency(amount: int) -> bool:
	if player_currency >= amount:
		player_currency -= amount
		currency_changed.emit(player_currency)
		return true
	return false

func get_currency() -> int:
	return player_currency

func buy_item(item: Item, cost: int) -> bool:
	if remove_currency(cost):
		trade_completed.emit(item, cost)
		return true
	return false

func sell_item(item: Item, value: int):
	add_currency(value)
	trade_completed.emit(item, -value) 