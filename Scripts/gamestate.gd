extends Node

var has_met_knight: bool = false
var has_met_swordmaster: bool = false
var has_met_chaplain: bool = false
var coins = 0
var coin = 10
# Define the signal
signal readyfight_signal(value)
signal loalty_won
signal fight_won
signal ready_loyalty(value)
signal the_end
signal item_purchased
var stachel_bought = false
var sailorhat_bought = false
var cowboyhat_bought = false

func _ready():
	# Connect to your own signal
	readyfight_signal.connect(some_argumentt)
	fight_won.connect(sword_fight_won)
	loalty_won.connect(sword_fight_won)
	ready_loyalty.connect(ready_loayltyt)
	the_end.connect(last_scene)
	item_purchased.connect(_on_item_bought)
	
func some_argumentt(value):
	print("got: ", value)
	get_tree().change_scene_to_file("res://Scenes/sword_areena.tscn")

func sword_fight_won():
		get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")

func ready_loayltyt():
	get_tree().change_scene_to_file("res://Scenes/loyalty_trial.tscn")

func last_scene():
	get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")

func _on_item_bought(_item_id: String, item_name: String, price: int):
	print("Player bought: ", item_name, " for ", price)
	if item_name == "statchel":
		stachel_bought = true
	if item_name == "Cowboy Hat":
		cowboyhat_bought = true
	if item_name == "Sailor Hat":
		sailorhat_bought = true
