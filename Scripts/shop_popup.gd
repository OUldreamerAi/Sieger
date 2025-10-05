extends Control

# Signals
signal item_purchased(item_id: String, item_name: String, price: int)
signal shop_closed

# Shop configuration
@export var shop_items := [
	{
		"id": "cosmeic",
		"name": "Cowboy Hat",
		"description": "Its like on a farm",
		"price": 19,
		"icon": "res://Assets/NewAssets/cowboyHat.png"  # Optional
	},
	{
		"id": "cosmetic",
		"name": "Sailor Hat",
		"description": "This one's sea worthy",
		"price": 15,
		"icon": "res://Assets/NewAssets/sailorHat (1).png"
	},
	{
		"id": "cosmeic",
		"name": "statchel",
		"description": "Carry your stuf",
		"price": 7,
		"icon": "res://Assets/NewAssets/satchel (1).png"
	},

]

@export var shop_title: String = "Merchant's Shop"

# UI References
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var panel: Panel = $CanvasLayer/Panel
@onready var title_label: Label = $CanvasLayer/Panel/MarginContainer/VBox/Title
@onready var gold_label: Label = $CanvasLayer/Panel/MarginContainer/VBox/GoldDisplay
@onready var items_container: VBoxContainer = $CanvasLayer/Panel/MarginContainer/VBox/ScrollContainer/ItemsList
@onready var close_button: Button = $CanvasLayer/Panel/MarginContainer/VBox/CloseButton
@onready var info_label: Label = $CanvasLayer/Panel/MarginContainer/VBox/InfoLabel

func _ready():
	# Hide shop initially
	canvas_layer.visible = false
	
	# Connect close button
	close_button.pressed.connect(_on_close_pressed)
	
	# Setup title
	title_label.text = shop_title
	
	# Populate shop items
	_populate_shop()
	_update_gold_display()

func _populate_shop():
	# Clear existing items
	for child in items_container.get_children():
		child.queue_free()
	
	# Create item buttons
	for item in shop_items:
		var item_btn = _create_item_button(item)
		items_container.add_child(item_btn)

func _create_item_button(item: Dictionary) -> Control:
	# Create a shop item entry
	var item_panel = PanelContainer.new()
	item_panel.custom_minimum_size = Vector2(0, 80)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	item_panel.add_child(hbox)
	
	# Item icon (optional)
	if item.has("icon") and ResourceLoader.exists(item["icon"]):
		var icon = TextureRect.new()
		icon.texture = load(item["icon"])
		icon.custom_minimum_size = Vector2(64, 64)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon)
	
	# Item info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = item["name"]
	name_label.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = item["description"]
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	info_vbox.add_child(desc_label)
	
	var price_label = Label.new()
	price_label.text = "Price: %d gold" % item["price"]
	price_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	info_vbox.add_child(price_label)
	
	# Buy button
	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	buy_btn.custom_minimum_size = Vector2(100, 0)
	buy_btn.pressed.connect(_on_buy_pressed.bind(item))
	hbox.add_child(buy_btn)
	
	# Store reference for enabling/disabling
	item_panel.set_meta("buy_button", buy_btn)
	item_panel.set_meta("item_data", item)
	
	return item_panel

func _on_buy_pressed(item: Dictionary):
	# Check if player has enough gold
	if Autoload.coin >= item["price"]:
		# Deduct gold
		Autoload.coin -= item["price"]
		_update_gold_display()
		
		# Show purchase feedback
		info_label.text = "Purchased: %s" % item["name"]
		info_label.modulate = Color(0.4, 1.0, 0.4)  # Green
		
		# Emit signal
		Autoload.item_purchased.emit(item["id"], item["name"], item["price"])
		print("signal emited")
		# Update button states
		_update_button_states()
		
		# Clear message after delay
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(info_label):
			info_label.text = ""
	else:
		# Not enough gold
		info_label.text = "Not enough gold!"
		info_label.modulate = Color(1.0, 0.4, 0.4)  # Red
		
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(info_label):
			info_label.text = ""

func _update_gold_display():
	gold_label.text = "Gold: %d" % Autoload.coin

func _update_button_states():
	# Enable/disable buy buttons based on affordability
	for item_panel in items_container.get_children():
		if item_panel.has_meta("buy_button") and item_panel.has_meta("item_data"):
			var buy_btn = item_panel.get_meta("buy_button")
			var item = item_panel.get_meta("item_data")
			buy_btn.disabled = Autoload.coin < item["price"]

func _on_close_pressed():
	close_shop()

func open_shop(_gold: int = -1):

	
	_update_gold_display()
	_update_button_states()
	info_label.text = ""
	canvas_layer.visible = true
	
	# Optional: animate opening
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)

func close_shop():
	# Optional: animate closing
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	await tween.finished
	
	canvas_layer.visible = false
	shop_closed.emit()

func set_player_gold(gold: int):
	Autoload.coin = gold
	_update_gold_display()
	_update_button_states()

func get_player_gold() -> int:
	return Autoload.coin

# Handle ESC key to close
func _input(event):
	if canvas_layer.visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled()
