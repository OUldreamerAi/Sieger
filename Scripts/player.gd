extends CharacterBody2D

const SPEED = 2000.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# Store movement input state
var movement_input := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if Autoload.stachel_bought == true:
		$"Sprite2D/Satchel(1)".visible = true
	if Autoload.sailorhat_bought == true:
		$"Sprite2D/SailorHat(1)".visible = true
	if Autoload.cowboyhat_bought == true:
		$Sprite2D/CowboyHat.visible = true
	# Apply movement based on stored input
	if movement_input.x != 0:
		velocity.x = movement_input.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if movement_input.y != 0:
		velocity.y = movement_input.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Handle sprite flipping
	if movement_input.x > 0:
		sprite.flip_h = true
		$"Sprite2D/Satchel(1)".flip_h = true
		$"Sprite2D/SailorHat(1)".flip_h = true
		$Sprite2D/CowboyHat.flip_h = true
	elif movement_input.x < 0:
		sprite.flip_h = false
		$"Sprite2D/Satchel(1)".flip_h = false
		$"Sprite2D/SailorHat(1)".flip_h = false
		$Sprite2D/CowboyHat.flip_h = false
	
	# Handle animations - play idle when NOT moving
	if movement_input.x == 0 and movement_input.y == 0:
		animation_player.play("walking")
	else:
		animation_player.play("idle")
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# Handle movement input
	if event.is_action("ui_left") or event.is_action("ui_right"):
		movement_input.x = Input.get_axis("ui_left", "ui_right")
		get_viewport().set_input_as_handled()
	
	if event.is_action("ui_up") or event.is_action("ui_down"):
		movement_input.y = Input.get_axis("ui_up", "ui_down")
		get_viewport().set_input_as_handled()
	
