extends Control

signal health_depleted

var health := 5: set = set_health
var coins := 0: set = set_coins

@onready var _heart_h_box_container: HBoxContainer = %HBoxContainer
@onready var _coin_icon: TextureRect = %CoinIcon
@onready var _coin_label: Label = %CoinLabel

func _ready() -> void:
	set_health(health)
	set_coins(coins)

func set_health(new_health: int) -> void:
	#ANCHOR:health_display
	health = clampi(new_health, 0, 5)
	for child in _heart_h_box_container.get_children():
		child.visible = health > child.get_index()
	#END:health_display

	#ANCHOR:health_depletes
	if health == 0:
		health_depleted.emit()
		#END:health_depletes
		
func get_coin_ui_position() -> Vector2:
	return _coin_label.global_position + _coin_icon.size / 2

func set_coins(new_value) -> void:
	coins = maxi(0, new_value)
	if _coin_label != null:
		_coin_label.text = str(coins)
