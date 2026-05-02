extends Control

@onready var panel:Panel =  $Panel
@onready var front_texture_rect = $Front_CardArt
@onready var back_texture_rect = $Back_CardArt

var tween: Tween # Keep a reference to the tween
var front_data: CardData
var back_data: CardData
var is_ready:bool = false
var is_selected: bool = false # NEW: Tracks if the card has been played/clicked
var is_face_down: bool = false

func setup_card():
	
	var front_index = front_data.visual_index # Get index from the resource
	var front_sheet = front_data.texture_preset.sheet_texture
	var front_columns = front_data.texture_preset.columns
	var front_width = front_data.texture_preset.width
	var front_height = front_data.texture_preset.height
	
	# Calculate X and Y based on index
	var front_row = front_index / front_columns
	var front_col = front_index % front_columns
	
	# Create the AtlasTexture in code (Zero effort!)
	var front_atlas_tex = AtlasTexture.new()
	front_atlas_tex.atlas = front_sheet
	front_atlas_tex.region = Rect2(front_col * front_width, front_row * front_height, front_width, front_height)   
	front_texture_rect.texture = front_atlas_tex
	
	var back_index = back_data.visual_index # Get index from the resource
	var back_sheet = back_data.texture_preset.sheet_texture
	var back_columns = back_data.texture_preset.columns
	var back_width = back_data.texture_preset.width
	var back_height = back_data.texture_preset.height
	
	# Calculate X and Y based on index
	var back_row = back_index / back_columns
	var back_col = back_index % back_columns
	
	# Create the AtlasTexture in code (Zero effort!)
	var back_atlas_tex = AtlasTexture.new()
	back_atlas_tex.atlas = back_sheet
	back_atlas_tex.region = Rect2(back_col * back_width, back_row * back_height, back_width, back_height)   
	back_texture_rect.texture = back_atlas_tex

func _ready() ->void:
	await get_tree().create_timer(0.2).timeout
	is_ready = true
	back_texture_rect.visible = false


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
	var d_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	d_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)

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
	target_pos.y -= (size.y * 1.5) / 2
	
	# 3. Animate
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.3)
	tween.parallel().tween_property(self, "rotation_degrees", 0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.5)
	
	z_index = 100
	
	await tween.finished
	
func flip_card(show_front: bool):
	if is_face_down == show_front:
		return
	
	is_face_down = show_front
	
	# 1. Determine the target scale based on selection status
	var target_scale_value = 1.5 if is_selected else 1.0
	var target_scale = Vector2(target_scale_value, target_scale_value)
	
	# Ensure pivot is centered so the rotation looks natural
	pivot_offset = Vector2(0, 0)
	
	var flip_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	# 2. Shrink X to 0, but keep Y at the target scale to prevent vertical jumping
	flip_tween.tween_property(self, "scale", Vector2(0.0, target_scale.y), 0.1)
	
	# 3. Swap visibility of the Art nodes
	flip_tween.tween_callback(func():
		front_texture_rect.visible = !is_face_down
		back_texture_rect.visible = is_face_down
	)
	
	# 4. Grow back to the correct final scale
	flip_tween.tween_property(self, "scale", target_scale, 0.1)
