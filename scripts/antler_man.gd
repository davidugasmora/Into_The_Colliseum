extends CharacterBody2D

const SPEED = 50
const ACCELERATION = 3000

var health = 10

enum State { IDLE, MOVE }
var state : State = State.IDLE

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

enum Facing {
	FRONT,
	BACK,
	LEFT,
	RIGHT,
	FRONT_LEFT,
	FRONT_RIGHT,
	BACK_LEFT,
	BACK_RIGHT
}
var facing : Facing = Facing.FRONT

func _ready() -> void:
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta):

	var input_dir : Vector2 = Input.get_vector("left","right","up","down")
	
	match state:
		State.MOVE, State.IDLE:
			_move_character(input_dir, delta)
			_update_facing(input_dir)
			_update_animation(input_dir)

func _move_character(input_dir : Vector2, delta : float) -> void:

	if input_dir != Vector2.ZERO: 
		state = State.MOVE
		velocity = velocity.move_toward(input_dir * SPEED , delta * ACCELERATION)
	else: 
		state = State.IDLE
		velocity = Vector2.ZERO
	
	move_and_slide()
	
func _update_facing(input_dir : Vector2) -> void:
	
	if input_dir == Vector2.ZERO:
		return
	
	var d = input_dir.normalized()
	var x = d.x
	var y = d.y
	var ax = abs(x)
	var ay = abs(y)
	
	var bias := 1.2
	
	if ay > ax * bias:
		if y < 0.0:
			facing = Facing.BACK
		else:
			facing = Facing.FRONT
	
	elif ax > ay * bias:
		if x < 0.0:
			facing = Facing.LEFT
		else:
			facing = Facing.RIGHT
	
	else:
		if y < 0.0:
			if x < 0.0:
				facing = Facing.BACK_LEFT
			else:
				facing = Facing.BACK_RIGHT
		else:
			if x < 0.0:
				facing = Facing.FRONT_LEFT
			else:
				facing = Facing.FRONT_RIGHT

func _facing_to_anim_name(prefix : String) -> String:
	match facing:
		Facing.FRONT:
			return "%s_%s" % [prefix, "front"]
		Facing.BACK:
			return "%s_%s" % [prefix, "back"]
		Facing.LEFT:
			return "%s_%s" % [prefix, "left"]
		Facing.RIGHT:
			return "%s_%s" % [prefix, "right"]
		Facing.FRONT_LEFT:
			return "%s_%s_%s" % [prefix, "front", "left"]
		Facing.FRONT_RIGHT:
			return "%s_%s_%s" % [prefix, "front", "right"]
		Facing.BACK_LEFT:
			return "%s_%s_%s" % [prefix, "back", "left"]
		Facing.BACK_RIGHT:
			return "%s_%s_%s" % [prefix, "back", "right"]
		_:
			return "%s_%s" % [prefix, "front"]

func _play_if_changed(anim_name : String) -> void:
	
	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)

func _update_animation(input_dir : Vector2) -> void:
	
	var is_moving = input_dir != Vector2.ZERO
	var prefix = "walk" if is_moving else "idle"
	var anim_name = _facing_to_anim_name(prefix)
	
	_play_if_changed(anim_name)
