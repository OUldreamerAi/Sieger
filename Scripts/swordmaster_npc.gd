extends Area2D
@onready var player: CharacterBody2D = $"../Player"

const DIALOGUE = preload("uid://dny32ykcygql1")


var playerin = false

func _on_body_entered(_body: Node2D) -> void:
	playerin = true
	

 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(_event: InputEvent) -> void:
	if playerin == true and Input.is_action_just_pressed("interact"): 
			DialogueManager.show_dialogue_balloon(DIALOGUE, "swordmaster_start")
			playerin = false


func _on_body_exited(_body: Node2D) -> void:
	playerin = false
