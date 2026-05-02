# DeckData.gd
extends Resource
class_name DeckData

# This is your "Database" for this specific deck!
@export var card_list: Array[CardData] = [] 

# This will be our actual runtime deck (shuffled)
var draw_pile: Array[CardData] = []

func initialize_deck():
	draw_pile = card_list.duplicate() # Copy the list
	draw_pile.shuffle()               # Mix them up
