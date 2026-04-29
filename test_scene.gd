extends Control

const CARD = preload("uid://bao6qsv2rq2x1")

@onready var hand: Control = $Hand
@onready var button: Button = $Button

var base_pos: Vector2:
	get:
		return get_viewport_rect().size * Vector2(0.5, 1.0)
var card_size:int = 0

func _on_button_pressed() -> void:
	add_card()
	
func add_card():
	var new_card = CARD.instantiate()
	hand.add_child(new_card)
	new_card.global_position = button.global_position
	card_size += 1
	await get_tree().create_timer(0.1). timeout
	move()
	
func move(hovered_index: int = -1):
	var spread_dist = 40.0
	var lift_dist = 150.0
	var center_num = (card_size - 1) / 2.0
	
	for i in card_size:
		var card = hand.get_child(i)
		
		# 1. Calculate base angle and fan position
		var angle = (i - center_num) * 3
		if card_size % 2 == 0:
			angle = (i - center_num) * 3 + 1
			
		var offset = Vector2(
			sin(deg_to_rad(angle + 90)) * angle * 60, 
			-cos(deg_to_rad(angle + 90)) * angle * 35
		)
		
		# 2. Apply Hover logic
		if hovered_index != -1:
			if i < hovered_index:
				offset.x -= spread_dist # Shift left neighbors further left
			elif i > hovered_index:
				offset.x += spread_dist # Shift right neighbors further right
			elif i == hovered_index:
				offset.y -= lift_dist   # Lift the hovered card
				card.z_index = 1        # Move to front layer
		
		if i != hovered_index:
			card.z_index = 0 # Ensure non-hovered cards stay behind
			
		var target_position = base_pos + offset - card.size / 2
		target_position.y -= 200
		
		# 3. Animate using Tween
		# We use the card's metadata or a local variable to manage individual tweens
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "global_position", target_position, 0.15)
		tween.parallel().tween_property(card, "rotation_degrees", angle, 0.15)
