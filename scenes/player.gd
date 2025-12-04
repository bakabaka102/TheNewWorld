extends CharacterBody2D

# Cố định cho nhân vật, không mượt như cách 2
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Cách 2
var jump_height = 60
var time_jump_apex = 0.6 #Thời gian đứng tại vị trí đó rồi mới bị rơi
var gravity
var jump_force

# Animation
@onready var anim = $animation_player


func _physics_process(delta: float) -> void:
	#gravity = (jump_height * 2) / pow(time_jump_apex, 2)
	#jump_force = gravity * time_jump_apex
	#Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta #velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction < 0.0:
		$animation_player.flip_h = true
	elif direction > 0.0:
		$animation_player.flip_h = false

	# Animation
	if direction != 0:
		anim.play("run")
	else:
		anim.play("idle")

	move_and_slide()
