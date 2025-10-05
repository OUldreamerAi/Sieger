extends CharacterBody2D
@export var speed: float = 2000.0
@export var attack_cooldown: float = 1.2
@export var block_cooldown: float = 1.0
@export var attack_duration: float = 0.5
@export var attack_range: float = 500.0
@export var knockback_force: float = 150.0
@export var block_knockback_force: float = 200.0  # Knockback when successfully blocking
@export var health: int = 3
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var sprite: Sprite2D = null  # Will try to find sprite in _ready()
@onready var plives: Label = $"../Plives"
var is_attacking = false
var is_blocking = false
var is_stunned = false
var can_attack = true
var can_block = true
var opponent: Node2D
var knockback_velocity: float = 0.0
signal player_attacked
signal player_blocked
var player_close = false
func _ready():
	# Try to find opponent with different possible names
	var parent = get_parent()
	print("Player parent: ", parent.name)
	print("Parent children: ", parent.get_children())

	if parent.has_node("Swordmaster"):
		opponent = parent.get_node("Swordmaster")

	# Try to find sprite node (adjust path as needed)
	if has_node("../Sprite2D"):
		sprite = $"../Sprite2D"
	elif has_node("Sprite2D"):
		sprite = $Sprite2D

func _physics_process(_delta):
	# Apply knockback
	if abs(knockback_velocity) > 10:
		velocity.x = knockback_velocity
		knockback_velocity *= 0.85  # Smooth deceleration
	elif not is_attacking and not is_blocking and not is_stunned:
		# Normal movement
		var direction = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed
	else:
		velocity.x = 0

	velocity.y = 0
	move_and_slide()

	# Handle input
	if not is_stunned:
		if Input.is_action_just_pressed("attack") and can_attack and not is_attacking and not is_blocking:
			attack()

		if Input.is_action_just_pressed("block") and can_block and not is_attacking and not is_blocking:
			block()
func attack():
	animation_player.play("atack")
	is_attacking = true
	can_attack = false
	$AttackTimer.start(attack_cooldown)

	emit_signal("player_attacked")

	# Attack hits at mid-animation
	await get_tree().create_timer(attack_duration * 0.5).timeout
	check_attack_hit()

	await get_tree().create_timer(attack_duration * 0.5).timeout
	is_attacking = false
func check_attack_hit():
	if not opponent:
		return

	var distance = abs(global_position.x - opponent.global_position.x)
	if distance < attack_range:
		if opponent.has_method("take_hit_from_player"):
			var knockback = sign(opponent.global_position.x - global_position.x) * knockback_force
			opponent.call("take_hit_from_player", knockback)
		else:
			if opponent.has_method("take_hit"):
				opponent.call("take_hit")
func block():
	is_blocking = true
	can_block = false
	$BlockTimer.start(block_cooldown)
	if player_close == true:
		emit_signal("player_blocked")

	# Visual feedback
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 1.0)

	await get_tree().create_timer(0.6).timeout
	is_blocking = false

	if sprite:
		sprite.modulate = Color.WHITE
func _on_AttackTimer_timeout():
	can_attack = true
func _on_BlockTimer_timeout():
	can_block = true
func take_hit_from_opponent(knockback: float):
	if is_blocking:
		# Block successful - no damage, but apply knockback to opponent
		if opponent and opponent.has_method("apply_knockback"):
			# Push opponent away with stronger force
			var counter_knockback = -sign(knockback) * block_knockback_force
			opponent.call("apply_knockback", counter_knockback)
		return

	health -= 1
	plives.text = "Lives: " + str(health)
	apply_knockback(knockback)
	flash_damage()

	# Brief stun
	is_stunned = true
	await get_tree().create_timer(0.2).timeout
	is_stunned = false

	if health <= 0:
		die()
func take_hit() -> bool:
	# Legacy function for backward compatibility
	if is_blocking:
		# Successfully blocked - apply counter knockback to opponent
		if opponent and opponent.has_method("apply_knockback"):
			var counter_knockback = sign(global_position.x - opponent.global_position.x) * block_knockback_force
			opponent.call("apply_knockback", counter_knockback)
		return false

	health -= 1
	plives.text = "Lives: " + str(health)
	flash_damage()

	is_stunned = true
	await get_tree().create_timer(0.2).timeout
	is_stunned = false

	if health <= 0:
		die()

	return true
func apply_knockback(force: float):
	knockback_velocity = force
func flash_damage():
	if sprite:
		sprite.modulate = Color(1.5, 0.5, 0.5)
		await get_tree().create_timer(0.15).timeout
		sprite.modulate = Color.WHITE
func die():
	get_tree().change_scene_to_file("res://Scenes/sword_areena.tscn")


func _on_area_2d_body_entered(_body: Node2D) -> void:
	player_close = true


func _on_area_2d_body_exited(_body: Node2D) -> void:
	player_close = false
