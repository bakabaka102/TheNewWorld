extends CharacterBody2D

@export var left_limit: float = -100   # Giới hạn bên trái
@export var right_limit: float = 100   # Giới hạn bên phải
@export var speed: float = 50          # Tốc độ bay

var direction := 1                     # 1 = sang phải, -1 = sang trái
var start_x := 0.0                       # Lưu vị trí ban đầu

@export var hp := 1

@onready var anim = $AnimatedSprite2D

func _ready():
	add_to_group("enemy")
	
	start_x = global_position.x
	anim.play("fly")  # animation bay

func _physics_process(delta):
	# Di chuyển
	global_position.x += speed * direction * delta

	# Nếu chạm giới hạn thì đổi hướng
	if global_position.x > start_x + right_limit:
		direction = -1
		anim.flip_h = false             # lật sprite quay đầu

	if global_position.x < start_x + left_limit:
		direction = 1
		anim.flip_h = true
		
func hit(damage: int):
	hp -= damage
	if hp <= 0:
		die()

func die():
	queue_free()   # 🐝 biến mất
