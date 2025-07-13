extends CharacterBody2D

class_name Player

signal health_changed(new_health: int, max_health: int)
signal inventory_changed()
signal position_changed(new_position: Vector2)

@export var speed: float = 200.0
@export var max_health: int = 100
@export var interaction_range: float = 50.0

var current_health: int
var inventory: Array[Item] = []
var equipped_weapon: Item
var equipped_tool: Item

var input_vector: Vector2
var last_direction: Vector2 = Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var health_bar: ProgressBar = $UI/HealthBar

func _ready():
	current_health = max_health
	_connect_signals()
	_setup_interaction_area()
	_setup_sprite()

func _connect_signals():
	health_changed.connect(_on_health_changed)
	inventory_changed.connect(_on_inventory_changed)

func _setup_interaction_area():
	if interaction_area:
		var interaction_shape = CircleShape2D.new()
		interaction_shape.radius = interaction_range
		interaction_area.get_child(0).shape = interaction_shape

func _setup_sprite():
	if sprite:
		# Get sprite frames from TextureManager
		var player_frames = TextureManager.get_sprite_frames("player")
		if player_frames:
			sprite.sprite_frames = player_frames
			sprite.animation = "idle_down"
			sprite.play()

func _input(event):
	# Handle input for different game modes
	if GameManager.current_state == GameManager.GameState.PLAYING:
		_handle_game_input(event)
	elif GameManager.current_state == GameManager.GameState.BUILDING:
		_handle_building_input(event)
	elif GameManager.current_state == GameManager.GameState.CREATIVE:
		_handle_creative_input(event)

func _handle_game_input(event):
	if event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("attack"):
		_try_attack()
	elif event.is_action_pressed("use_tool"):
		_try_use_tool()
	elif event.is_action_pressed("inventory"):
		_toggle_inventory()

func _handle_building_input(event):
	if event.is_action_pressed("place_block"):
		_try_place_block()
	elif event.is_action_pressed("remove_block"):
		_try_remove_block()

func _handle_creative_input(event):
	# Creative mode specific input
	pass

func _physics_process(delta):
	_handle_movement(delta)
	_update_animation()
	_update_camera()

func _handle_movement(delta):
	# Get input
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	# Normalize diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	# Apply movement
	velocity = input_vector * speed
	move_and_slide()
	
	# Emit position change
	position_changed.emit(global_position)

func _update_animation():
	if not sprite:
		return
		
	if input_vector.length() > 0:
		# Moving animations
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				sprite.play("walk_right")
			else:
				sprite.play("walk_left")
		else:
			if input_vector.y > 0:
				sprite.play("walk_down")
			else:
				sprite.play("walk_up")
	else:
		# Idle animations
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x > 0:
				sprite.play("idle_right")
			else:
				sprite.play("idle_left")
		else:
			if last_direction.y > 0:
				sprite.play("idle_down")
			else:
				sprite.play("idle_up")

func _update_camera():
	# Camera follows player smoothly
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.global_position = global_position

func _try_interact():
	# Find nearby interactable objects
	var interactables = _get_nearby_interactables()
	if interactables.size() > 0:
		var closest = interactables[0]
		closest.interact(self)

func _get_nearby_interactables() -> Array:
	var interactables = []
	if interaction_area:
		var bodies = interaction_area.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("interact"):
				interactables.append(body)
	return interactables

func _try_attack():
	if equipped_weapon:
		_perform_attack()

func _perform_attack():
	# Implement combat logic
	print("Player attacks with ", equipped_weapon.name)

func _try_use_tool():
	if equipped_tool:
		_use_tool()

func _use_tool():
	# Implement tool usage
	print("Player uses ", equipped_tool.name)

func _try_place_block():
	# Building mode block placement
	print("Place block at mouse position")

func _try_remove_block():
	# Building mode block removal
	print("Remove block at mouse position")

func _toggle_inventory():
	var game_manager = get_node("/root/GameManager")
	if game_manager.current_state == GameManager.GameState.PLAYING:
		game_manager.change_state(GameManager.GameState.INVENTORY)
	elif game_manager.current_state == GameManager.GameState.INVENTORY:
		game_manager.change_state(GameManager.GameState.PLAYING)

func take_damage(damage: int):
	current_health = max(0, current_health - damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		_die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func _die():
	print("Player died!")
	# Handle death logic

func add_item(item: Item) -> bool:
	if inventory.size() < 40:  # Max inventory size
		inventory.append(item)
		inventory_changed.emit()
		return true
	return false

func remove_item(item: Item) -> bool:
	var index = inventory.find(item)
	if index != -1:
		inventory.remove_at(index)
		inventory_changed.emit()
		return true
	return false

func equip_weapon(weapon: Item):
	if weapon.type == Item.Type.WEAPON:
		equipped_weapon = weapon

func equip_tool(tool: Item):
	if tool.type == Item.Type.TOOL:
		equipped_tool = tool

func _on_health_changed(new_health: int, max_health: int):
	if health_bar:
		health_bar.value = float(new_health) / float(max_health) * 100.0

func _on_inventory_changed():
	# Update inventory UI
	pass 