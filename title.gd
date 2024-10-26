extends Control

@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var options_button: Button = $MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    start_button.grab_focus()
    start_button.pressed.connect(_start_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _start_button_pressed():
    VFX.fadeout()
    await VFX.fadeout_finished
    get_tree().change_scene_to_file('res://game.tscn')
