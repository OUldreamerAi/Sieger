extends Node

var has_met_knight: bool = false
var has_met_swordmaster: bool = false
var has_met_chaplain: bool = false
var coins = 0
# Define the signal
signal readyfight_signal(value)
signal loalty_won
signal fight_won
signal ready_loyalty(value)
signal the_end

func _ready():
	# Connect to your own signal
	readyfight_signal.connect(some_argumentt)
	fight_won.connect(sword_fight_won)
	loalty_won.connect(sword_fight_won)
	ready_loyalty.connect(ready_loayltyt)
	the_end.connect(last_scene)
	
func some_argumentt(value):
	print("got: ", value)
	get_tree().change_scene_to_file("res://Scenes/sword_areena.tscn")

func sword_fight_won():
		get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")

func ready_loayltyt():
	get_tree().change_scene_to_file("res://Scenes/loyalty_trial.tscn")

func last_scene():
	get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
