extends CharacterBody2D

const TILE_SIZE: int = 16
@export var walk_speed: float = 0.1
@onready var wall_detector = $wall_detector
@onready var bread_detector = $bread_detector
@onready var character = $Sprite2D
@onready var death_screen = $"UI/HBoxContainer/Death Screen"
@onready var win_screen = $UI/HBoxContainer/win_screen
@onready var level1 : PackedScene = load("res://Scenes/level1.tscn")

signal pick

var start_position
var died: bool = false
var previous_position = Vector2(0, 0)
var input_direction = Vector2(0, 0)
var is_moving: bool = false
var percent_moved_to_next_tile: float = 0.0
var rope : int = 30
var breadcrumbs : Array
var eating_bread : bool = false
var just_ate : bool = false
var level
var prev_char_pos = 1
var can_move : bool = true

func _ready():
	start_position = position
	previous_position = position
	level = get_tree().current_scene

func _physics_process(delta):
	if rope < 1:
		death()
	if (win_screen.visible or death_screen.visible) and Input.is_action_just_pressed("r"):
			get_tree().change_scene_to_packed(level1)
	elif can_move:
		if is_moving == false:
			process_player_input()
		elif input_direction != Vector2.ZERO:
			move(delta)
		else:
			is_moving = false

func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.get_action_strength("right")) - int(Input.get_action_strength("left"))
	else:
		input_direction.x = 0
	if input_direction.x == 0:
		input_direction.y = int(Input.get_action_strength("down")) - int(Input.get_action_strength("up"))

	if input_direction != Vector2.ZERO:
		previous_position = position
		is_moving = true
	else:
		$AnimationPlayer.play("idle")

func move(delta):
	wall_detector.target_position = TILE_SIZE * input_direction
	bread_detector.target_position = TILE_SIZE * input_direction
	wall_detector.force_raycast_update()
	bread_detector.force_raycast_update()

	if !wall_detector.is_colliding():
		percent_moved_to_next_tile += walk_speed + delta
		if percent_moved_to_next_tile >= 0.99:
			position = previous_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			character.rotation_degrees = 0
			character.offset.y = 0
			if prev_char_pos > 0:
				prev_char_pos = -1
			else:
				prev_char_pos = 1
			
			if not bread_detector.is_colliding() and not just_ate:
				eating_bread = false
			if not eating_bread:
				drop_bread(input_direction)
			just_ate = false
			$AnimationPlayer.play("walk")
			
		else:
			position = previous_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
			character.rotation_degrees = 10 * (input_direction.x + input_direction.y) * prev_char_pos
			character.offset.y = -2
	else:
		$AnimationPlayer.play("idle")
		is_moving = false
	
	move_and_slide()


func drop_bread(direction):
	var breadcrumb_scene = preload("res://Scenes/breadcrumb.tscn")
	breadcrumb_scene = breadcrumb_scene.instantiate()
	breadcrumb_scene.position = previous_position
	if direction.y != 0:
		breadcrumb_scene.rotate_vertical()
	if direction.x != 0:
		breadcrumb_scene.rotate_horizontal()
	level.drop_crumbs(breadcrumb_scene)
	breadcrumbs.append(breadcrumb_scene)

	rope -= 1
	if rope < 0:
		get_tree().quit()
	level.update_rope(rope)

func pick_bread(breadcrumb):
	var last_breadcrumb = breadcrumbs[breadcrumbs.size()-1]
	if last_breadcrumb == breadcrumb:
		eating_bread = true
		just_ate = true
		breadcrumb.queue_free()
		breadcrumbs.erase(breadcrumb)
		rope += 1
		level.update_rope(rope)
	else:
		var index = breadcrumbs.find(breadcrumb)
		var new_arr = breadcrumbs.slice(index)
		breadcrumbs = breadcrumbs.slice(0, index)
		
		for crumb in new_arr:
			eating_bread = true
			just_ate = true
			crumb.queue_free()
			rope += 1
			level.update_rope(rope)

func pick_rope(amount = 40):
	rope+=amount
	level.update_rope(rope)
	
func death():
	if not $end_screen.stream:
		$end_screen.stream = load("res://Failure.mp3")
		$end_screen.play()
	$animation_sfx.stop()
	$AnimationPlayer.play("idle")
	if !died:
		character.modulate = "ff1414"
		character.rotation_degrees = 70 * (input_direction.x + input_direction.y) * prev_char_pos
		died = true
	can_move = false
	death_screen.visible = true
	get_tree().current_scene.stop_music()

func victory():
	if not $end_screen.stream:
		$end_screen.stream = load("res://victory.mp3")
		$end_screen.play()
	$animation_sfx.stop()
	get_tree().current_scene.stop_music()
	$AnimationPlayer.play("idle")
	character.visible = false
	win_screen.visible = true
	can_move = false

func change_animation_pitch():
	$animation_sfx.pitch_scale = randf_range(0.8, 1.2)
