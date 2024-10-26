extends VBoxContainer

signal option_selected

var idx := 0
var buttons := []

func show_options(options):
    clear()
    options.map(append)

func append(_text: String):
    var button = Button.new()
    button.text = _text
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
    option_selected.emit(_idx)
    visible = false
