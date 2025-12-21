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

func _physics_process(_delta):
	# Di chuyển, Cách này BỎ QUA collision hoàn toàn
	#global_position.x += speed * direction * delta
	#Muốn va chạm TileMap → PHẢI dùng:
	#velocity
	#move_and_slide() hoặc move_and_collide()
	velocity.x = speed * direction
	move_and_slide()

	# Đổi hướng khi chạm biên
	if global_position.x > start_x + right_limit:
		direction = -1

	elif global_position.x < start_x + left_limit:
		direction = 1
		
	# Nếu đụng tường thì quay đầu
	if is_on_wall():
		direction *= -1

	# Quay đầu/Lật sprite theo hướng bay
	anim.flip_h = direction > 0

func hit(damage: int):
	hp -= damage
	if hp <= 0:
		die()

func die():
	queue_free()   # 🐝 biến mất
