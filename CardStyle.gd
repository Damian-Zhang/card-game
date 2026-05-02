# CardStyle.gd
extends Resource
class_name CardStyle

#preset for card sheet texture and region
#Front image
@export var front_sheet_texture: Texture2D
@export var front_columns: int = 0
@export var front_width: float = 0.0
@export var front_height: float = 0.0

#Back image
@export var back_sheet_texture: Texture2D
@export var back_columns: int = 0
@export var back_width: float = 0.0
@export var back_height: float = 0.0
