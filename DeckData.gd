# DeckData.gd
extends Resource
class_name DeckData

# only default data, the actual data coming from loading .tres resource
@export var deck_name: String = "Default Deck"
@export var sheet_texture: Texture2D
@export var columns: int = 2
@export var width: float = 718.0
@export var height: float = 1124.0

# This is your "Database" for this specific deck!
@export var card_list: Array[CardData] = [] 

# This will be our actual runtime deck (shuffled)
var draw_pile: Array[CardData] = []

func initialize_deck():
	draw_pile = card_list.duplicate() # Copy the list
	draw_pile.shuffle()               # Mix them up
