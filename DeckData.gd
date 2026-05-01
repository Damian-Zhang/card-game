# DeckData.gd
extends Resource
class_name DeckData

# only default data, the actual data coming from loading .tres resource
@export var deck_name: String = "Default Deck"
@export var sheet_texture: Texture2D
@export var columns: int = 2
@export var width: float = 718.0
@export var height: float = 1124.0
