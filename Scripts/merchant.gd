extends Node2D
@onready var player: CharacterBody2D = $"../Player"

var coin = Autoload.coin

var playerin = false

func _on_body_entered(_body: Node2D) -> void:
	playerin = true

	

func _on_body_exited(_body: Node2D) -> void:
	playerin = false

 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(_event: InputEvent) -> void:
	if playerin == true and Input.is_action_just_pressed("interact"): 

			$"../ShopPopup".open_shop(coin)
			print(playerin)
			playerin = false
