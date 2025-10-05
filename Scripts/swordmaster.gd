extends CharacterBody2D

@export var speed: float = 1600.0
@export var attack_cooldown: float = 1.5
@export var attack_duration: float = 0.75
@export var block_chance: float = 0.3
@export var attack_range: float = 500.0
@export var optimal_distance: float = 350.0
@export var retreat_distance: float = 200.0
@export var health: int = 3
@export var knockback_force: float = 150.0
@export var block_knockback_force: float = 200.0  # Knockback when successfully blocking

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var sprite: Sprite2D = $Sprite2D
@onready var olives: Label = $"../Olives"

var target: Node2D
var can_attack = true
var is_attacking = false
var is_blocking = false
var is_stunned = false
var should_retreat = false
var retreat_timer = 0.0
var knockback_velocity: float = 0.0

enum AIState { AGGRESSIVE, CAUTIOUS, RETREATING, NEUTRAL }
var current_state = AIState.NEUTRAL

func _ready():
	target = get_parent().get_node("Player")
	# Connect to player signals
	if target.has_signal("player_attacked"):
		target.connect("player_attacked", Callable(self, "_on_player_attacked"))
	if target.has_signal("player_blocked"):
		target.connect("player_blocked", Callable(self, "_on_player_blocked"))

func _physics_process(delta):
	if not target:
		return
	
	# Update retreat timer
	if retreat_timer > 0:
		retreat_timer -= delta
		should_retreat = true
	else:
		should_retreat = false
	
	# Calculate distance to player
	var distance = abs(global_position.x - target.global_position.x)
	
	# Update AI state based on situation
	update_ai_state(distance)
	
	# Apply knockback
	if abs(knockback_velocity) > 10:
		velocity.x = knockback_velocity
		knockback_velocity *= 0.85
	elif not is_attacking and not is_blocking and not is_stunned:
		# Movement behavior based on state
		handle_movement(distance)
	else:
		velocity.x = 0
	
	velocity.y = 0
	move_and_slide()
	
	# Attack decision
	if can_attack and not is_attacking and not is_blocking and not should_retreat:
		if distance < attack_range and current_state != AIState.RETREATING:
			# Random delay to make AI less predictable
			if randf() < 0.6:  # 60% chance to attack when in range
				attack()

func update_ai_state(distance: float):
	# Become cautious when low health
	if health <= 1:
		current_state = AIState.CAUTIOUS
	elif should_retreat:
		current_state = AIState.RETREATING
	elif distance < attack_range * 0.7:
		# Too close - might want to back off sometimes
		if randf() < 0.3:  # 30% chance to retreat when very close
			current_state = AIState.RETREATING
			retreat_timer = randf_range(0.5, 1.0)
		else:
			current_state = AIState.AGGRESSIVE
	elif distance < optimal_distance:
		current_state = AIState.AGGRESSIVE
	else:
		current_state = AIState.NEUTRAL

func handle_movement(distance: float):
	var move_direction = 0
	
	match current_state:
		AIState.AGGRESSIVE:
			# Move toward player
			move_direction = sign(target.global_position.x - global_position.x)
		
		AIState.CAUTIOUS:
			# Maintain optimal distance - back off if too close
			if distance < optimal_distance:
				move_direction = -sign(target.global_position.x - global_position.x)
			elif distance > retreat_distance:
				move_direction = sign(target.global_position.x - global_position.x)
		
		AIState.RETREATING:
			# Back away
			move_direction = -sign(target.global_position.x - global_position.x)
		
		AIState.NEUTRAL:
			# Slowly approach
			if distance > optimal_distance:
				move_direction = sign(target.global_position.x - global_position.x)
	
	velocity.x = move_direction * speed

func attack():
	animation_player.play("attack")
	is_attacking = true
	can_attack = false
	$AttackTimer.start(attack_cooldown)
	
	# Attack hits at mid-animation
	await get_tree().create_timer(attack_duration * 0.5).timeout
	check_attack_hit()
	
	await get_tree().create_timer(attack_duration * 0.5).timeout
	is_attacking = false

func check_attack_hit():
	if target and abs(global_position.x - target.global_position.x) < attack_range + 10:
		# Back off after attacking
		retreat_timer = randf_range(0.8, 1.5)
		
		# Push player back and deal damage
		var push_dir = sign(target.global_position.x - global_position.x)
		target.take_hit_from_opponent(push_dir * knockback_force)

func _on_AttackTimer_timeout():
	can_attack = true

func take_hit_from_player(knockback: float):
	# Try to block if not already blocking or attacking
	if not is_blocking and not is_attacking and randf() < block_chance:
		block()
		# Successfully blocked - apply counter knockback to player
		if target and target.has_method("apply_knockback"):
			var counter_knockback = -sign(knockback) * block_knockback_force
			target.call("apply_knockback", counter_knockback)
		return
	
	if is_blocking:
		# Successfully blocked - apply counter knockback to player
		if target and target.has_method("apply_knockback"):
			var counter_knockback = -sign(knockback) * block_knockback_force
			target.call("apply_knockback", counter_knockback)
		return
	
	health -= 1
	olives.text = "Lives: " + str(health)
	apply_knockback(knockback)
	flash_damage()
	
	# Brief stun
	is_stunned = true
	
	# Retreat after taking damage
	retreat_timer = randf_range(1.0, 2.0)
	
	await get_tree().create_timer(0.25).timeout
	is_stunned = false
	
	if health <= 0:
		die()

func take_hit() -> bool:
	# Legacy function for backward compatibility
	if not is_blocking and not is_attacking and randf() < block_chance:
		block()
		# Successfully blocked - apply counter knockback to player
		if target and target.has_method("apply_knockback"):
			var counter_knockback = sign(global_position.x - target.global_position.x) * block_knockback_force
			target.call("apply_knockback", counter_knockback)
		return false
	
	if is_blocking:
		# Successfully blocked - apply counter knockback to player
		if target and target.has_method("apply_knockback"):
			var counter_knockback = sign(global_position.x - target.global_position.x) * block_knockback_force
			target.call("apply_knockback", counter_knockback)
		return false
	
	health -= 1
	olives.text = "Lives: " + str(health)
	flash_damage()
	
	is_stunned = true
	retreat_timer = randf_range(1.0, 2.0)
	
	await get_tree().create_timer(0.25).timeout
	is_stunned = false
	
	if health <= 0:
		die()
	
	return true

func apply_knockback(force: float):
	knockback_velocity = force

func block():
	is_blocking = true
	
	# Visual feedback
	if sprite:
		sprite.modulate = Color(0.5, 0.5, 1.0)
	
	await get_tree().create_timer(0.6).timeout
	is_blocking = false
	
	if sprite:
		sprite.modulate = Color.WHITE

func flash_damage():
	if sprite:
		sprite.modulate = Color(1.5, 0.5, 0.5)
		await get_tree().create_timer(0.15).timeout
		if sprite:  # Check again in case node was freed
			sprite.modulate = Color.WHITE

func _on_player_attacked():
	# Player is attacking - decide whether to block or dodge
	if not is_attacking and not is_blocking:
		var distance = abs(global_position.x - target.global_position.x)
		if distance < attack_range * 1.3:
			# Close enough to be hit - try to block or back off
			if randf() < 0.5:
				retreat_timer = 0.4
			elif randf() < block_chance:
				block()

func _on_player_blocked():
	# Player is blocking - good time to retreat and reset
	retreat_timer = randf_range(0.5, 1.0)

func die():
	Autoload.coins += 1
	Autoload.coin += 24
	print(Autoload.coins)
	Autoload.fight_won.emit()
