extends Control

@onready var label: Label = $WindowMessage/MarginContainer/Label
@onready var timer: Timer = $WindowMessage/Timer
@onready var line_edit: LineEdit = $LineEdit
@onready var v_menu: VBoxContainer = $VMenu
@onready var inventory: GridContainer = $MarginContainer/Inventory
@onready var window_message: MarginContainer = $WindowMessage

signal closed
signal finished_displaying_text
signal option_selected
signal confirmation

var text := ""
var finished := false
var active := true

func show_text(_text: String):
    text = _text
    label.text = _text
    label.visible_characters = label.get_total_character_count()
    visible = true
    finished = true

func scroll_text(_text: String):
    text = _text
    label.text = _text
    label.visible_characters = 0
    visible = true
    finished = false
    timer.start()

func prompt(_text: String, scrolling := true):
    if scrolling:
        scroll_text(_text)
    else:
        show_text(_text)
    await finished_displaying_text
    active = false

    line_edit.visible = true
    line_edit.grab_focus()
    await line_edit.text_submitted
    active = true

    line_edit.visible = false
    return line_edit.text

func show_menu(_text: String, options: Array, scrolling := true):
    if scrolling:
        scroll_text(_text)
    else:
        show_text(_text)
    await finished_displaying_text
    active = false

    v_menu.visible = true
    v_menu.show_options(options)
    var option_idx = await v_menu.option_selected
    active = true

    option_selected.emit(option_idx)

func confirm(_text: String, scrolling := true):
    show_menu(_text, ["YES", "NO"])
    var idx = await option_selected
    confirmation.emit(idx == 0)

func show_inventory():
    label.text = ""
    window_message.visible = false
    active = false

    inventory.visible = true
    inventory.show_options(CTX.inventory.map(func(x): return x.name))
    var idx = await inventory.option_selected
    window_message.visible = true
    active = true
    option_selected.emit(idx)

func _ready() -> void:
    visible = false
    label.anchor_left = 0
    label.anchor_right = 1
    label.autowrap_mode = TextServer.AUTOWRAP_WORD
    timer.timeout.connect(_on_timer_timeout)

func _process(_delta: float) -> void:
    if visible and active:
        if Input.is_action_just_pressed("ui_accept"):
            if finished:
                visible = false
                emit_signal("closed")
            else:
                label.visible_characters = label.get_total_character_count()


func _on_timer_timeout() -> void:
    if visible and not finished:
        label.visible_characters += 1
        if label.visible_characters >= label.get_total_character_count():
            finished = true
            finished_displaying_text.emit()
            timer.stop()