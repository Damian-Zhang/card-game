extends Control

@onready var panel:Panel =  $Panel

var tween:Tween
var is_ready:bool = false

func _ready() ->void:
	await get_tree().create_timer(0.2).timeout
	is_ready = true


func _on_panel_mouse_entered() -> void:
	get_parent().get_parent().move(get_index())


func _on_panel_mouse_exited() -> void:
	get_parent().get_parent().move(-1) # -1 means no card is hovered

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("Card clicked!")
			# Trigger your card play logic here
