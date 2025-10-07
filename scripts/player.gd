extends CharacterBody2D

const SPEED = 50
const ACCELERATION = 3000

var last_h = 1
var last_v = 1

var current_direction = "none"

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func player_movement(input, delta):

	if input: 
		velocity = velocity.move_toward(input * SPEED , delta * ACCELERATION)
	else: 
		velocity = Vector2.ZERO

func _select_anim_name(prefix, horizontal, vertical):
	if vertical < 0:
		return prefix + "_back_left" if horizontal < 0 else prefix + "_back_right"
	else:
		return prefix + "_front_left" if horizontal < 0 else prefix + "_front_right"

func player_animation(input):
	
	var anim = $AnimatedSprite2D
	
	if input.x != 0:
		last_h = sign(input.x)
	if input.y != 0:
		last_v = sign(input.y)
		
	var horizontal = sign(input.x) if input.x != 0 else last_h
	var vertical = sign(input.y) if input.y != 0 else last_v
	
	var name = ""
	
	if input == Vector2.ZERO:
		name = _select_anim_name("idle", horizontal, vertical)
	else:
		name = _select_anim_name("walk", horizontal, vertical)
		
	if anim.animation != name or not anim.is_playing():
		anim.play(name)


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _physics_process(delta):

	var input = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	player_movement(input, delta)
	player_animation(input)
	move_and_slide()
