extends CharacterBody2D

const SPEED = 50
const ACCELERATION = 3000

var health = 10

enum State { IDLE, MOVE, ATTACK, DIE}
var state : State = State.IDLE

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox : hit_box = $hit_box
@onready var hurtbox : hurt_box = $hurt_box

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
	anim.animation_finished.connect(_on_animation_finished)
	hitbox.set_deferred("monitoring", false)
	var shape = hitbox.get_node_or_null("CollisionShape2D")
	if shape:
		shape.set_deferred("disabled", true)
	hurtbox.damaged.connect(take_dmg)

func _physics_process(delta):

	var input_dir : Vector2 = Input.get_vector("left","right","up","down")
	if state != State.ATTACK and Input.is_action_just_pressed("attack") and state != State.DIE:
		_enter_attack()
	_update_health()
	
	match state:
		State.DIE:
			velocity = Vector2.ZERO
		State.ATTACK:
			velocity = Vector2.ZERO
			_attack_frame()
		State.MOVE, State.IDLE:
			_move_character(input_dir, delta)
			_update_facing(input_dir)
			_update_non_attack_animation(input_dir)

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
			hitbox.rotation_degrees = 90
			hitbox.position = Vector2(0, -8)
		else:
			facing = Facing.FRONT
			hitbox.rotation_degrees = 90
			hitbox.position = Vector2(0, 3)
	
	elif ax > ay * bias:
		if x < 0.0:
			facing = Facing.LEFT
			hitbox.rotation_degrees = 0
			hitbox.position = Vector2(-6.5, -3)

		else:
			facing = Facing.RIGHT
			hitbox.rotation_degrees = 0
			hitbox.position = Vector2(6.5, -3)
	
	else:
		if y < 0.0:
			if x < 0.0:
				facing = Facing.BACK_LEFT
				hitbox.rotation_degrees = 45
				hitbox.position = Vector2(-4, -7.5)
			else:
				facing = Facing.BACK_RIGHT
				hitbox.rotation_degrees = -45
				hitbox.position = Vector2(4, -7.5)
		else:
			if x < 0.0:
				facing = Facing.FRONT_LEFT
				hitbox.rotation_degrees = -45
				hitbox.position = Vector2(-5.5, 2)
			else:
				facing = Facing.FRONT_RIGHT
				hitbox.rotation_degrees = 45
				hitbox.position = Vector2(5.5, 2)

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

func _update_non_attack_animation(input_dir : Vector2) -> void:
	
	var is_moving = input_dir != Vector2.ZERO
	var prefix = "walk" if is_moving else "idle"
	
	_play_if_changed(_facing_to_anim_name(prefix))

func _enter_attack() -> void:
	
	state = State.ATTACK
	velocity = Vector2.ZERO
	
	_play_if_changed(_facing_to_anim_name("attack"))

func _on_animation_finished() -> void:
	
	if state == State.ATTACK and anim.animation.begins_with("attack"):
		state = State.IDLE
		hitbox.set_deferred("monitoring", false)
		var shape = hitbox.get_node_or_null("CollisionShape2D")
		if shape:
			shape.set_deferred("disabled", true)

func _attack_frame() -> void:
	if anim.animation.begins_with("attack"):
		var frame = anim.frame
		var active = (frame >= 2 and frame <= 3)
		hitbox.set_deferred("monitoring", active)
		var shape = hitbox.get_node_or_null("CollisionShape2D")
		if shape:
			shape.set_deferred("disabled", not active)

func take_dmg(damage : int) -> void:

	health -= damage
	if health <= 0:
		_enter_die()

func _update_health():
	
	var health_bar = $health_bar
	health_bar.value = health
	
	if health >= 10:
		health_bar.visible = false
	else:
		health_bar.visible = true

func _enter_die():
	
	state = State.DIE
	anim.play("death")
	anim.animation_finished.connect(queue_free)

func _on_regen_timer_timeout() -> void:
	if health < 10:
		health += 1
	
	if health <= 0:
		health = 0
