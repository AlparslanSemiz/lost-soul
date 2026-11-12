extends Node
class_name PlayerHealthComponent


@export var initial_health := 100
var is_dead := false


func init_health(health_bar: ProgressBar) -> void:
	health_bar.init_health(initial_health)


func can_receive_actions() -> bool:
	return not is_dead


func apply_damage(health_bar: ProgressBar, amount: int) -> bool:
	if is_dead:
		return false
	health_bar.health -= amount
	return health_bar.health <= 0


func apply_heal(health_bar: ProgressBar, amount: int) -> void:
	if is_dead:
		return
	health_bar.health += amount


func mark_dead() -> void:
	is_dead = true


func revive() -> void:
	is_dead = false
