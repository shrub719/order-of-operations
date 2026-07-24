extends Node2D

@export var board: Board

@onready var playpause_button: PlaybackButton = $PlayPause
@onready var advance_button: PlaybackButton = $Advance
@onready var resetstop_button: PlaybackButton = $ResetStop

var is_in_playback_mode := false
var is_paused := false

func _ready() -> void:
	# TODO: set up signals
	advance_button.clicked.connect(advance_button_clicked)
	resetstop_button.clicked.connect(resetstop_button_clicked)

func advance_button_clicked():
	update_playback_mode(true)
	update_paused(true)
	board.advance_stage()

func resetstop_button_clicked():
	update_playback_mode(false)

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
	else:
		# update buttons
		playpause_button.frame_coords.x = 0
		resetstop_button.frame_coords.x = 3
		# load cached board state
		board.load_cache()