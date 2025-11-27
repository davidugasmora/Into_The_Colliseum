extends CharacterBody2D

const SPEED = 50
const ACCELERATION = 3000

var health = 10

enum State { IDLE, MOVE }
var state : State = State.IDLE

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

var last_h = 1
var last_v = 1
var facing_h = 1
var facing_v = 1

func _ready() -> void:
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta):

	var dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	
	match state:
		State.MOVE, State.IDLE:
			_update_facing(dir)
			_move(dir, delta)
			_play_move_or_idle(dir)
			move_and_slide()

func _move(dir, delta : float) -> void:

	if dir != Vector2.ZERO: 
		state = State.MOVE
		velocity = velocity.move_toward(dir * SPEED , delta * ACCELERATION)
	else: 
		state = State.IDLE
		velocity = Vector2.ZERO

func _update_facing(dir : Vector2) -> void:
	
	if dir.x != 0:
		last_h = sign(dir.x)
	if dir.y != 0:
		last_v = sign(dir.y)
		
	facing_h = last_h
	facing_v = last_v
	
func _play_move_or_idle(dir : Vector2) -> void:
	
	var prefix := "walk" if dir != Vector2.ZERO else "idle"
	
	var anim_dir := dir
	if anim_dir == Vector2.ZERO:
		anim_dir = Vector2(facing_h, facing_v)
	
	_play_if_changed(_select_anim_name(prefix, anim_dir))
	
func _select_anim_name(prefix: String, dir: Vector2) -> String:
	
	if dir.x == 0 and dir.y != 0:
		return prefix + "_left" if dir.x < 0 else prefix + "_right"
	
	if dir.y == 0 and dir.x != 0:
		return prefix + "_back" if dir.y < 0 else prefix + "_front"
	
	if dir.y < 0:
		return prefix + "_back_left" if dir.x < 0 else prefix + "_back_right"
	else:
		return prefix + "_front_left" if dir.x < 0 else prefix + "_front_right"

func _play_if_changed(anim_name: String) -> void:

	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)
