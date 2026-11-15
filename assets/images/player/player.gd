extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const MIN_JUMP_VELOCITY = -400.0
const MAX_JUMP_VELOCITY = -650.0
const MAX_CHARGE_TIME = 0.8

var current_charge: float = 0.0
var is_charging: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_charging = false
		current_charge = 0.0
		animated_sprite_2d.scale = Vector2.ONE
	else:
		if Input.is_action_pressed("jump"):
			is_charging = true
			current_charge = min(current_charge + delta, MAX_CHARGE_TIME)
			#charge up
			var charge_ratio := current_charge / MAX_CHARGE_TIME
			animated_sprite_2d.scale = Vector2(1.0 + (0.3 * charge_ratio), 1.0 - (0.3 * charge_ratio))
			
		elif is_charging and Input.is_action_just_released("jump"):
			var charge_ratio := current_charge / MAX_CHARGE_TIME
			velocity.y = lerp(MIN_JUMP_VELOCITY, MAX_JUMP_VELOCITY, charge_ratio)
			
			is_charging = false
			current_charge = 0.0
			animated_sprite_2d.scale = Vector2.ONE
#regular movement
	var direction := Input.get_axis("left", "right")
	if is_charging:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
#animations
	if not is_on_floor():
		animated_sprite_2d.animation = "jumping"
	elif velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"

	if direction < 0:
		animated_sprite_2d.flip_h = false
	elif direction > 0:
		animated_sprite_2d.flip_h = true
