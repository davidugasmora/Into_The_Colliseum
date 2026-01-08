extends CharacterBody2D

const SPEED = 50
const ACCELERATION = 3000

var health = 10

enum State { IDLE, MOVE, ATTACK, DIE }
var state : State = State.IDLE

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox : hit_box = $hit_box
@onready var hurtbox : hurt_box = $hurt_box

var last_h = 1
var last_v = 1
var facing_h = 1
var facing_v = 1

func _ready() -> void:
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	hurtbox.damaged.connect(take_dmg)
	anim.animation_finished.connect(_on_animation_finished)
	hitbox.set_deferred("monitoring", false)
	var shape = hitbox.get_node_or_null("CollisionShape2D2")
	if shape:
		shape.set_deferred("disabled", true)

func _physics_process(delta):

	var dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	_update_health()
	
	if state != State.ATTACK and Input.is_action_just_pressed("attack") and state != State.DIE:
		_enter_attack()
	
	match state:
		State.DIE:
			velocity = Vector2.ZERO
		State.ATTACK:
			velocity = Vector2.ZERO
			_attack_frame()
			move_and_slide()
			return
		State.MOVE, State.IDLE:
			_update_facing(dir)
			_update_hitbox_transform()
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
	_play_if_changed(_select_anim_name(prefix))

func _select_anim_name(prefix: String) -> String:

	if facing_v < 0:
		return prefix + "_back_left" if facing_h < 0 else prefix + "_back_right"
	else:
		return prefix + "_front_left" if facing_h < 0 else prefix + "_front_right"

func _enter_attack() -> void:
	
	state = State.ATTACK
	velocity = Vector2.ZERO
	_play_if_changed(_select_anim_name("attack"))

func _on_animation_finished() -> void:
	
	if state == State.ATTACK and anim.animation.begins_with("attack"):
		state = State.IDLE
		hitbox.set_deferred("monitoring", false)
		var shape = hitbox.get_node_or_null("CollisionShape2D2")
		if shape:
			shape.set_deferred("disabled", true)

func _attack_frame() -> void:
	if anim.animation.begins_with("attack"):
		var frame = anim.frame
		var active = (frame >= 2 and frame <= 3)
		hitbox.set_deferred("monitoring", active)
		var shape = hitbox.get_node_or_null("CollisionShape2D2")
		if shape:
			shape.set_deferred("disabled", not active)

func _play_if_changed(anim_name: String) -> void:

	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)
	
func _update_hitbox_transform():

	if facing_v < 0:
		if facing_h < 0:
			hitbox.rotation_degrees = -120
			hitbox.position = Vector2(-5, -5)
		else:
			hitbox.rotation_degrees = 120
			hitbox.position = Vector2(5, -5)
	elif facing_v > 0:
		if facing_h < 0:
			hitbox.rotation_degrees = -70
			hitbox.position = Vector2(-6, 1)
		elif facing_h > 0:
			hitbox.rotation_degrees = 70
			hitbox.position = Vector2(6, 1)

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
	await get_tree().create_timer(1.0).timeout
	queue_free()
