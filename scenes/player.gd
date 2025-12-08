extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMP = 6

var jump_count = 0
var is_double_jumping = false   # Lock animation doublejump

var audio_jump_path = load("res://sounds/jump.wav")

@onready var anim = $AnimatedSprite2DPlayer
@onready var audio_jump = $AudioStreamPlayer_Jump


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	# --------------------------------------------------------
	#  multi-jump + doublejump animation
	# --------------------------------------------------------
	if Input.is_action_just_pressed("ui_accept"):
		# Nhảy được nếu đang đứng đất hoặc còn số lần nhảy
		if is_on_floor() or jump_count < MAX_JUMP:
			velocity.y = JUMP_VELOCITY
			jump_count += 1

			# Lần nhảy đầu
			if jump_count == 1:
				anim.play("jump")
				is_double_jumping = false
			
			# Từ lần 2 trở đi (double jump)
			else:
				anim.play("doublejump")
				is_double_jumping = true

			# Play âm thanh
			audio_jump.stream = audio_jump_path
			audio_jump.play()

	# ---------------------------------------
	#  ANIMATION fly (jump/fall logic)
	# ---------------------------------------
	if not is_on_floor():

		# Không override animation doublejump
		if is_double_jumping:
			velocity += get_gravity() * delta
			# vẫn rơi bình thường nhưng không đổi animation
			pass
		else:
			velocity += get_gravity() * delta
			
			if velocity.y < 0:
				anim.play("jump")
			else:
				anim.play("fall")
	else:
		# Reset số lần nhảy khi chạm đất
		if jump_count != 0:
			jump_count = 0
			is_double_jumping = false

		# Animation khi đứng đất
		if direction != 0:
			anim.play("run")
		else:
			anim.play("idle")

	# ---------------------------------------
	#  MOVEMENT
	# ---------------------------------------
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip sprite
	if direction < 0.0:
		anim.flip_h = true
	elif direction > 0.0:
		anim.flip_h = false

	move_and_slide()
