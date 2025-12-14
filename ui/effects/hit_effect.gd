extends Node2D

func _ready():
	$AnimationPlayer.play("hit")

func _on_animation_finished(_name):
	queue_free()
