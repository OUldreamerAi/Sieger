extends Control
@onready var label: Label = $CanvasLayer/Label
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	label.visible = false
	canvas_layer.visible = false
	
func _process(_delta: float) -> void:
	if  Input.is_action_pressed("interact"): 
		label.visible = false

func _on_gate_npc_body_entered(_body: Node2D) -> void:
	label.visible = true
	canvas_layer.visible = true

func _on_gate_npc_body_exited(_body: Node2D) -> void:
	label.visible = false


func _on_swordmaster_npc_body_entered(_body: Node2D) -> void:
	label.visible = true
	canvas_layer.visible = true


func _on_swordmaster_npc_body_exited(_body: Node2D) -> void:
	label.visible = false


func _on_loalty_body_entered(_body: Node2D) -> void:
	label.visible = true
	canvas_layer.visible = true

func _on_loalty_body_exited(_body: Node2D) -> void:
	label.visible = false
