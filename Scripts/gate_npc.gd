extends Area2D

const DIALOGUE = preload("uid://dny32ykcygql1")


var playerin = false
func _ready() -> void:
	if not Autoload.has_met_knight:
		DialogueManager.show_dialogue_balloon(DIALOGUE, "start")

func _unhandled_input(_event: InputEvent) -> void:
	if playerin == true and Input.is_action_just_pressed("interact"): 
			DialogueManager.show_dialogue_balloon(DIALOGUE, "start")
			playerin = false

func _on_body_entered(_body: Node2D) -> void:
	playerin = true
	print(playerin)


func _on_body_exited(_body: Node2D) -> void:
	playerin = false
