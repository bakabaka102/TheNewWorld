extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(_delta):
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		$AnimatedSprite2DPlayer.play("run")
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2DPlayer.play("idle")

	move_and_slide()
