extends CharacterBody2D

const SPEED = 50
const ACCELERATION = 3000

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var anim_name = ""
var last_h = 1
var last_v = 1
var horizontal = ""
var vertical = ""

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func player_movement(direction, delta):

	if direction: 
		velocity = velocity.move_toward(direction * SPEED , delta * ACCELERATION)
	else: 
		velocity = Vector2.ZERO

func find_anim_direction(direction):
	
	if direction.x != 0:
		last_h = sign(direction.x)
	if direction.y != 0:
		last_v = sign(direction.y)
		
	horizontal = sign(direction.x) if direction.x != 0 else last_h
	vertical = sign(direction.y) if direction.y != 0 else last_v

func select_anim_name(prefix):
	
	if vertical < 0:
		return prefix + "_back_left" if horizontal < 0 else prefix + "_back_right"
	else:
		return prefix + "_front_left" if horizontal < 0 else prefix + "_front_right"

func movement_animation(direction):
	
	if direction == Vector2.ZERO:
		anim_name = select_anim_name("idle")
	else:
		anim_name = select_anim_name("walk")
		
	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)

func attack_animation():

	if Input.is_action_pressed("Attack"):
		anim_name = select_anim_name("attack")
		anim.play(anim_name)
		

func _physics_process(delta):

	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	player_movement(direction, delta)
	find_anim_direction(direction)
	movement_animation(direction)
	attack_animation()
	move_and_slide()
