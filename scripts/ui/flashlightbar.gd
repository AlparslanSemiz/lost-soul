extends Control
class_name FlashlightBarUI

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

const FRAME_COUNT := 6


func update_battery(percent: float, _is_on: bool) -> void:
	show()
	anim_sprite.stop()
	anim_sprite.frame = int(clamp(percent, 0.0, 1.0) * (FRAME_COUNT - 1))


func set_locked() -> void:
	hide()
