extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	var enemies_in_range: Array[Node2D] = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy: CharacterBody2D = enemies_in_range.front()
		look_at(target_enemy.global_position)
	

func shoot():
	const BULLET: Resource = preload("res://scenes/projectiles/fire_bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
