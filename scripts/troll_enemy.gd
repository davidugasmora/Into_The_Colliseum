extends CharacterBody2D

const SPEED = 15

var player_chase = false
var player = null

var last_h = 1
var last_v = 1

var current_direction = "none"

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false

func _select_anim_name(prefix, horizontal, vertical):
	if vertical < 0:
		return prefix + "_back_left" if horizontal < 0 else prefix + "_back_right"
	else:
		return prefix + "_front_left" if horizontal < 0 else prefix + "_front_right"

func player_animation(direction: Vector2) -> void:
	
	var anim = $AnimatedSprite2D
	
	if direction.x != 0:
		last_h = sign(direction.x)
	if direction.y != 0:
		last_v = sign(direction.y)
		
	var horizontal = sign(direction.x) if direction.x != 0 else last_h
	var vertical = sign(direction.y) if direction.y != 0 else last_v
	
	var name = ""
	
	if direction == Vector2.ZERO:
		name = _select_anim_name("idle", horizontal, vertical)
	else:
		name = _select_anim_name("walk", horizontal, vertical)
		
	if anim.animation != name or not anim.is_playing():
		anim.play(name)

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	if player_chase:
		direction = (player.position - position).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	player_animation(direction)
	move_and_slide()
