extends Control
class_name DashBarUI

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

const FRAME_COUNT := 6


func init_dash(_max_seconds: float) -> void:
	hide()


func update_dash(remaining: float, max_seconds: float) -> void:
	show()
	anim_sprite.stop()
	var t: float = clamp(1.0 - remaining / max(max_seconds, 0.001), 0.0, 1.0)
	anim_sprite.frame = int(t * (FRAME_COUNT - 1))


func set_ready() -> void:
	show()
	anim_sprite.stop()
	anim_sprite.frame = FRAME_COUNT - 1


func set_locked() -> void:
	hide()
