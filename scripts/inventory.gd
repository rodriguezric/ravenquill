extends GridContainer

signal option_selected
signal closed

var idx := 0
var buttons : Array[Button] = []

func _process(delta: float) -> void:
    if visible:
        if Input.is_action_just_pressed("ui_cancel"):
            visible = false
            option_selected.emit(-1)

func show_options(options):
    clear()
    options.map(append)

func append(_text: String):
    var button = Button.new()
    button.text = _text
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.pressed.connect(_button_pressed.bind(idx))

    add_child(button)
    buttons.append(button)

    if idx == 0:
        button.grab_focus()
    idx += 1

func clear():
    for button in buttons:
        button.queue_free()
    buttons = []
    idx = 0

func _button_pressed(_idx: int):
    visible = false
    option_selected.emit(_idx)
