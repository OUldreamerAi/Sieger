extends Control
@onready var label: Label = $CanvasLayer/Label
@onready var label2: Label = $CanvasLayer/Label2

func _ready() -> void:
	label.visible = false

	
func _process(_delta: float) -> void:
	label2.text = str(Autoload.coin)
	if  Input.is_action_pressed("interact"): 
		label.visible = false

func _on_gate_npc_body_entered(_body: Node2D) -> void:
	label.visible = true

func _on_gate_npc_body_exited(_body: Node2D) -> void:
	label.visible = false


func _on_swordmaster_npc_body_entered(_body: Node2D) -> void:
	label.visible = true



func _on_swordmaster_npc_body_exited(_body: Node2D) -> void:
	label.visible = false


func _on_loalty_body_entered(_body: Node2D) -> void:
	label.visible = true

func _on_loalty_body_exited(_body: Node2D) -> void:
	label.visible = false


func _on_area_2d_body_entered(_body: Node2D) -> void:
	label.visible = true


func _on_area_2d_body_exited(_body: Node2D) -> void:
	label.visible = false
