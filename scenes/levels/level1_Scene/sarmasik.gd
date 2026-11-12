extends Area2D
@onready var asil_karakter: CharacterBody2D = $"../../asil_karakter"



func _on_body_entered(body: Node2D) -> void:
	if body == asil_karakter:
		asil_karakter.sarmasikta_mi = true
		print("sikik arda")


func _on_body_exited(body: Node2D) -> void:
	if body == asil_karakter:
		asil_karakter.sarmasikta_mi = false	
	
