extends Area2D

var travelled_distance = 0

const SPEED = 500
const RANGE = 1600
@export var damage := 1.0
const EXPLOSION = preload("res://effects/explosion_effect.tscn")


func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Spawn explosion TRƯỚC KHI xóa đạn
	queue_free()
	if body.has_method("take_dame"):
		body.take_dame(damage)
		spawn_explosion()



func spawn_explosion() -> void:
	# Tạo explosion
	var explosion = EXPLOSION.instantiate()
	
	# Đặt vị trí = vị trí đạn
	explosion.global_position = global_position
	
	# Có thể random xoay cho đẹp
	explosion.rotation = randf() * TAU
	
	# Màu cho nổ lửa
	#explosion.modulate = Color(0.759, 0.322, 0.475, 1.0)
	
	# Random scale
	var random_scale = randf_range(3, 4)
	explosion.scale = Vector2(random_scale, random_scale)
	
	# Add vào scene chính (không phải vào bullet!)
	get_tree().current_scene.add_child(explosion)
	
	print("💥 Explosion created at: ", global_position)
