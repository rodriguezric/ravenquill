extends CanvasLayer

signal fadeout_finished
signal fadein_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
    color_rect.visible = false
    animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name):
    match animation_name:
        "fadeout":
            animation_player.play("fadein")
            fadeout_finished.emit()
        "fadein", "flash":
            color_rect.visible = false
            fadein_finished.emit()

func fadeout():
    color_rect.visible = true
    color_rect.color = Color(0, 0, 0, 1)
    animation_player.play("fadeout")

func flash(color: Color):
    color_rect.visible = true
    color_rect.color = color
    animation_player.play("flash")
