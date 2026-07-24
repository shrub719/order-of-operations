extends Node2D

@export var board: Board
@export var playback_overlay: Sprite2D
var playback_overlay_opacity_target = 0.0
@export var playback_text: Sprite2D

@onready var playpause_button: PlaybackButton = $PlayPause
@onready var advance_button: PlaybackButton = $Advance
@onready var resetstop_button: PlaybackButton = $ResetStop

var is_in_playback_mode := false
var is_paused := false

var playback_text_cycle_cooldown = 0.0

func _ready() -> void:
	# TODO: set up signals
	advance_button.clicked.connect(advance_button_clicked)
	resetstop_button.clicked.connect(resetstop_button_clicked)
	playback_overlay.self_modulate.a = 0.0
	playback_overlay.visible = true

func _process(delta: float) -> void:
	playback_text_cycle_cooldown += delta
	playback_overlay.self_modulate.a = lerp(playback_overlay.self_modulate.a, playback_overlay_opacity_target, 0.1)
	
	if not is_in_playback_mode:
		playback_text.self_modulate.a = 0
	
	if playback_text_cycle_cooldown >= 1: # one second has passed
		playback_text_cycle_cooldown = 0
		if is_in_playback_mode:
			playback_text.self_modulate.a = 1.0 if playback_text.self_modulate.a != 1.0 else 0.25

func advance_button_clicked():
	update_playback_mode(true)
	update_paused(true)
	board.advance_stage()

func resetstop_button_clicked():
	if is_in_playback_mode:
		update_playback_mode(false)
	else:
		board.reset()

func update_paused(value):
	if is_paused == value: return
	is_paused = value

	if is_paused:
		playpause_button.frame_coords.x = 0
	else:
		playpause_button.frame_coords.x = 1

func update_playback_mode(value):
	if is_in_playback_mode == value: return
	is_in_playback_mode = value
	
	if is_in_playback_mode:
		# update buttons
		resetstop_button.frame_coords.x = 4
		# cache board state
		board.cache_board()
		Settings.can_drag_blocks = false
		playback_text_cycle_cooldown = 1
		playback_overlay_opacity_target = 1.0
	else:
		# update buttons
		playpause_button.frame_coords.x = 0
		resetstop_button.frame_coords.x = 3
		# load cached board state
		board.load_cache()
		Settings.can_drag_blocks = true
		playback_overlay_opacity_target = 0.0
