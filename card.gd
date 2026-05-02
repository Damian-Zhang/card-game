extends Control

@onready var panel:Panel =  $Panel
@onready var texture_rect = $CardArt

var tween: Tween # Keep a reference to the tween
var data: CardData
var is_ready:bool = false
var is_selected: bool = false # NEW: Tracks if the card has been played/clicked

func setup_card(deck: DeckData):
	
	var index = data.visual_index # Get index from the resource
	var sheet = deck.sheet_texture
	var columns = deck.columns
	var width = deck.width
	var height = deck.height
	
	# Calculate X and Y based on index
	var row = index / columns
	var col = index % columns
	
	# Create the AtlasTexture in code (Zero effort!)
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = sheet
	atlas_tex.region = Rect2(col * width, row * height, width, height)   
	texture_rect.texture = atlas_tex

func _ready() ->void:
	await get_tree().create_timer(0.2).timeout
	is_ready = true


func _on_panel_mouse_entered() -> void:
	get_parent().get_parent().move(get_index())


func _on_panel_mouse_exited() -> void:
	get_parent().get_parent().move(-1) # -1 means no card is hovered

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and is_ready:
			# NEW: Tell the Hand script to handle the selection logic
			get_parent().get_parent().select_card(self)
			
func deselect() -> void:
	is_selected = false
	z_index = 0
	# No tween needed here; the Hand's move() function will pull it back automatically

func move_to_center_right() -> void:
	if tween:
		tween.kill()
	is_selected = true
	
	# 1. Calculate Target: 100% width minus card width, 50% height
	var screen_size = get_viewport_rect().size
	
	# We take the full width (screen_size.x) and subtract the card's width (size.x)
	# This aligns the RIGHT edge of the card with the RIGHT edge of the screen.
	var target_pos = Vector2(screen_size.x - size.x * 1.5, screen_size.y * 0.5)
	
	# 2. Adjust Y-axis only to center it vertically
	# (Since target_pos.x is already the left-edge position we want, we only offset Y)
	target_pos.y -= size.y / 2
	
	# 3. Animate
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", 0, 0.5)
	
	z_index = 100
