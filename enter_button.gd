extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    button_down.connect(_on_button_down)

func _on_button_down():
    pass
