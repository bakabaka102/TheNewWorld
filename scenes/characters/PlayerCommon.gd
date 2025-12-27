extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const DAMAGE_RATE = 1.0  # Fixed: Sửa chính tả DAME → DAMAGE

signal health_depleted

@export var max_health := 50.0  # Fixed: Thêm max_health
@export var health := 50.0       # Fixed: health mặc định = max_health

@onready var health_bar = $HealthBar

func _ready() -> void:
	add_to_group("player")
	
	# Fixed: Setup health bar NGAY trong _ready()
	health_bar.max_value = max_health
	health_bar.value = health
	
	print("Player ready! --- Health: ", health, "/", max_health)

func _physics_process(delta):
	# Di chuyển
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		$AnimatedSprite2DPlayer.play("run")
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2DPlayer.play("idle")
	
	move_and_slide()
	
	# Kiểm tra va chạm với enemy
	var overlap_mobs = %HurtBox.get_overlapping_bodies()
	if overlap_mobs.size() > 0:
		# Gây sát thương
		var damage = DAMAGE_RATE * overlap_mobs.size() * delta
		take_damage(damage)

# Fixed: Tách thành hàm riêng để dễ quản lý
func take_damage(amount: float) -> void:
	health -= amount
	health = max(health, 0)  # Không cho health < 0
	
	# Cập nhật health bar
	health_bar.value = health
	
	# Debug
	# print("Player took ", amount, " damage | Health: ", health, "/", max_health)
	
	# Chết
	if health <= 0:
		health_depleted.emit()

# Hàm hồi máu (bonus)
func heal(amount: float) -> void:
	health += amount
	health = min(health, max_health)  # Không vượt quá max
	health_bar.value = health
