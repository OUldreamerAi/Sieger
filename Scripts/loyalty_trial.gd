extends Node2D

# Signals for communication with parent
signal trial_completed(passed: bool, score: int)

# Config
@export var scenarios := [
	{
		"text": "A merchant offers you a purse of gold if you keep quiet about smuggling. Do you accept?",
		"choice_a": {"text":"Accept the gold", "loyalty_delta": -1, "feedback":"You took coin instead of duty..."},
		"choice_b": {"text":"Refuse and report it", "loyalty_delta": 1, "feedback":"You put duty above coin."}
	},
	{
		"text": "Your captain orders a risky patrol that may save civilians but endanger the squad. Do you follow the order?",
		"choice_a": {"text":"Follow the order", "loyalty_delta": 1, "feedback":"You obey the chain of command."},
		"choice_b": {"text":"Refuse to follow", "loyalty_delta": -1, "feedback":"You put personal doubts before duty."}
	},
	{
		"text": "You find a wounded messenger who asks you to deliver a secret letter to the castle. Doing so risks delay. What do you do?",
		"choice_a": {"text":"Help and deliver", "loyalty_delta": 1, "feedback":"You prioritized the mission and the messenger."},
		"choice_b": {"text":"Leave the messenger and go faster", "loyalty_delta": -1, "feedback":"You chose speed over helping a comrade."}
	}
]

@export var pass_threshold: int = 3  # minimum loyalty_score to pass
@export var coin_scene_path: String = "res://items/Coin_Loyalty.tscn"
@export var enable_timer: bool = false  # Set to true to enable timed scenarios
@export var scenario_time_limit: float = 12.0  # Time limit per scenario

# Runtime
var index: int = 0
var loyalty_score: int = 0
var buttons_disabled: bool = false

@onready var label_title: Label = $CanvasLayer/UIRoot/Title
@onready var scenario_text: RichTextLabel = $CanvasLayer/UIRoot/Scenario
@onready var btn_a: Button = $CanvasLayer/UIRoot/Buttons/ChoiceA
@onready var btn_b: Button = $CanvasLayer/UIRoot/Buttons/ChoiceB
@onready var progress: ProgressBar = $CanvasLayer/UIRoot/Progress
@onready var feedback: Label = $CanvasLayer/UIRoot/Feedback
@onready var scenario_timer: Timer = $ScenarioTimer

func _ready():
	label_title.text = "Trial of Loyalty"
	progress.max_value = scenarios.size()
	progress.value = 0
	feedback.text = ""
	
	# Connect button signals
	btn_a.pressed.connect(_on_choice_a_pressed)
	btn_b.pressed.connect(_on_choice_b_pressed)
	
	# Configure timer if enabled
	if enable_timer:
		scenario_timer.wait_time = scenario_time_limit
		scenario_timer.one_shot = true
		scenario_timer.timeout.connect(_on_scenario_timeout)
	
	show_current_scenario()

func show_current_scenario():
	if index >= scenarios.size():
		_finish_trial()
		return
	
	var s = scenarios[index]
	scenario_text.bbcode_text = s["text"]
	btn_a.text = s["choice_a"]["text"]
	btn_b.text = s["choice_b"]["text"]
	progress.value = index
	feedback.text = ""
	buttons_disabled = false
	btn_a.disabled = false
	btn_b.disabled = false
	
	# Start timer if enabled
	if enable_timer:
		scenario_timer.start()

func _apply_choice(delta: int, fb_text: String):
	# Prevent double-clicking
	if buttons_disabled:
		return
	
	buttons_disabled = true
	btn_a.disabled = true
	btn_b.disabled = true
	
	# Stop timer if running
	if scenario_timer.time_left > 0:
		scenario_timer.stop()
	
	loyalty_score += delta
	feedback.text = fb_text
	
	# Optional: Color code feedback
	if delta > 0:
		feedback.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))  # Green
	elif delta < 0:
		feedback.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))  # Red
	else:
		feedback.add_theme_color_override("font_color", Color(1.0, 1.0, 0.6))  # Yellow
	
	index += 1
	
	# Small delay so player sees feedback before next scenario
	await get_tree().create_timer(1.2).timeout
	_next_scenario()

func _next_scenario():
	# Reset feedback color
	feedback.add_theme_color_override("font_color", Color.WHITE)
	show_current_scenario()

func _on_choice_a_pressed():
	if buttons_disabled or index >= scenarios.size():
		return
	var s = scenarios[index]
	_apply_choice(s["choice_a"]["loyalty_delta"], s["choice_a"]["feedback"])

func _on_choice_b_pressed():
	if buttons_disabled or index >= scenarios.size():
		return
	var s = scenarios[index]
	_apply_choice(s["choice_b"]["loyalty_delta"], s["choice_b"]["feedback"])

func _on_scenario_timeout():
	# When player doesn't answer within time limit
	if buttons_disabled or index >= scenarios.size():
		return
	_apply_choice(-1, "You hesitated and the chance slipped away.")

func _finish_trial():
	progress.value = scenarios.size()
	btn_a.visible = false
	btn_b.visible = false
	
	# Determine pass/fail
	var passed = loyalty_score >= pass_threshold
	if passed:
		feedback.text = "You have proven your loyalty!"
		feedback.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	else:
		feedback.text = "You failed the Trial of Loyalty. Return when your heart is truer."
		feedback.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	
	# Show detailed results in scenario text
	var result_text = "[center]"
	if passed:
		result_text += "[color=#66ff66]✓ TRIAL PASSED[/color]\n\n"
	else:
		result_text += "[color=#ff6666]✗ TRIAL FAILED[/color]\n\n"
	result_text += "[/center]"
	result_text += "Final Loyalty Score: %d\n" % loyalty_score
	result_text += "Needed to Pass: %d\n" % pass_threshold
	result_text += "Total Scenarios: %d" % scenarios.size()
	scenario_text.bbcode_text = result_text
	
	# Emit signal for parent
	trial_completed.emit(passed, loyalty_score)
	
	# Give time for player to read, then clean up
	await get_tree().create_timer(7).timeout
	_on_finish_timeout()
	if loyalty_score == 3:
		Autoload.loalty_won.emit()
		Autoload.coins += 1
		Autoload.coin += 19
		print(Autoload.coins)
	else: 
		get_tree().change_scene_to_file("res://Scenes/loyalty_trial.tscn")


func _on_finish_timeout():
	# Clean up and return control to parent
	# The parent should handle scene changes or next steps
	queue_free()
