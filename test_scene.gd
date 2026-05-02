extends Control

const CARD = preload("uid://bao6qsv2rq2x1")

@onready var hand: Control = $Hand
@onready var button: Button = $Button
@export var active_deck: DeckData

var my_deck = DeckData.new()
var card_0 = preload("res://Card_Resources/Backup_Fund_Data.tres")
var card_1 = preload("res://Card_Resources/Strike_Data.tres")
var base_pos: Vector2:
	get:
		return get_viewport_rect().size * Vector2(0.5, 1.0)
var card_size:int = 0

func _ready():
	active_deck = load("res://StartingDeck.tres") 
	if active_deck == null:
		print("Failed to load deck resource! Check your file path.")
	
	for i in range(6):
		my_deck.card_list.append(card_1)
	my_deck.card_list.append(card_0)
	my_deck.initialize_deck()

func _on_button_pressed() -> void:
	add_card()
	
func add_card():
	if my_deck.draw_pile.is_empty():
		print("Deck is empty! No more cards to draw.")
		return
	
	var new_card = CARD.instantiate()
	new_card.front_data = my_deck.draw_pile.pop_front()
	new_card.back_data = new_card.front_data.duplicate();
	new_card.back_data.visual_index = new_card.back_data.visual_index + 1
	hand.add_child(new_card)
	
	new_card.setup_card() # setup new card
	
	new_card.global_position = button.global_position
	card_size += 1
	await get_tree().create_timer(0.1). timeout
	move()
	
func select_card(new_card):
	# 1. Loop through all cards in the hand
	for card in hand.get_children():
		# If another card is already selected, put it back
		if card.get("is_selected") and card != new_card:
			card.deselect()
			if card.has_method("flip_card"):
				card.flip_card(false)
	
	# 2. Move the new card to the center right
	new_card.move_to_center_right()
	
	if new_card.has_method("flip_card"):
		new_card.flip_card(true)
	
	# 3. Refresh the rest of the hand positions
	move()
	
func move(hovered_index: int = -1):
	var spread_dist = 40.0
	var lift_dist = 150.0
	var center_num = (card_size - 1) / 2.0
	
	for i in card_size:
		var card = hand.get_child(i)
		
		# If the card has the 'is_selected' variable and it's true, skip it!
		if card.get("is_selected") == true:
			continue
			
		if card.get("tween"):
			card.tween.kill()
		
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
		
