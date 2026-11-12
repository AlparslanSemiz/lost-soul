extends Area2D

@export var orbit_group_name := "double_jump_orbit"


func _ready() -> void:
	add_to_group(orbit_group_name)
