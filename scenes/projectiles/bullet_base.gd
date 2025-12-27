extends Area2D

@export var speed := 300.0
var direction := Vector2.RIGHT

@export var damage := 1
const EXPLOSION = preload("res://effects/explosion_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# đảm bảo signal được connect
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta
	pass

func _on_body_entered(body: Node):
	if body.is_in_group("enemy"):
		print_debug("body.hit()")
		if body.has_method("hit"):
			body.hit(damage)
			queue_free()   # 💥 huỷ đạn
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
	
	# Random scale từ 3 đến 4
	var random_scale = randf_range(3, 4)
	explosion.scale = Vector2(random_scale, random_scale)
	
	# Add vào scene chính (không phải vào bullet!)
	get_tree().current_scene.add_child(explosion)
	
	print("💥 Explosion created at: ", global_position)
