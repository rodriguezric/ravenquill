extends Node2D

@onready var window_message: Control = $WindowMessage
@onready var line_edit: LineEdit = $LineEdit
@onready var the_end_label: Label = $"CanvasLayer/CenterContainer/the end"

signal got_player_name
signal battle_scene_completed

var rng := RandomNumberGenerator.new()
var streets_text_list = [
    "The cobblestones whisper under your weary boots, their rhythm laced with an unnerving silence.",
    "It's not the quietude of a calm night, but a hollowed silence, as if the world holds its breath.",
    "Despite the setting sun, a clammy dampness clings to the air, and every groan of the wind through the crooked houses sounds like a tortured whisper.",
    "The oppressive labyrinth of narrow streets tightens its grip on you with each twist and turn, amplifying your fear.",
    "The entity's unseen presence weighs heavily, its malice a chilling fog at the edges of your perception.",
]

var run_texts = [
    "You quickened your pace, as you feel your heart hammering against your ribs.",
    "The narrow streets morphed into an oppressive labyrinth, each twist and turn amplifying his fear.",
    "Suddenly, a hulking silhouette loomed ahead - the Raven's Quill Inn, its windows dark, boarded shut. But any refuge was better than the encroaching darkness.",
]

var rat = {
    "name": "Verminous Horror",
    "description": "A glint of obsidian eyes reflects the faintest light, fixed on you with chilling indifference.",
    "verbs": ["bites", "scratches"],
    "atk": 3,
    "hp": 10,
    "fire_weakness_flg": false
}

var slime = {
    "name": "Eldritch Slime",
    "description": "Tendrils, like translucent worms, writhe on the surface of a vile slime.",
    "verbs": ["splashes on", "oozes on"],
    "atk": 4,
    "hp": 7,
    "fire_weakness_flg": true
}

var madman = {
    "name": "Deranged",
    "description": "A stench of rot and forgotten knowledge precedes the his arrival.",
    "verbs": ["punches", "grabs"],
    "atk": 3,
    "hp": 12,
    "fire_weakness_flg": false
}

var enemies = [rat, slime, madman]

var woman = {
    "name": "Old Woman",
    "description": "The old woman, displeased with your uncertainty, gazes at you with a souless stare. You have this unshakable feeling that she intends to kill you.",
    "verbs": ["spits at", "screams at", "vomits on", "chokes"],
    "atk": 3,
    "hp": 8,
    "fire_weakness_flg": true
}


func use_potion():
    var hp := CTX.dice_roll(6)
    VFX.flash(Color.YELLOW)
    SFX.play_track(SFX.PORTAL)
    CTX.stats.hp = min(CTX.stats.hp + hp, CTX.stats.max_hp)
    window_message.scroll_text("Healed " + str(hp) + " HP.")
    await window_message.closed

var potion = {
    "name": "Potion",
    "description": "A medicinal potion.",
    "use": use_potion
}

func use_torch():
    if CTX.battle_flg:
        var hit_roll = CTX.dice_roll(6)
        if hit_roll == 1:
            VFX.flash(Color.RED)
            SFX.play_track(SFX.MISS)
            window_message.scroll_text("You drop the torch and burn yourself for 1 damage!")
            await window_message.closed

            CTX.stats.hp -= 1
            if CTX.stats.hp == 0:
                Music.stop()
                window_message.scroll_text("What a tragic way to die.")
                await window_message.closed

                VFX.fadeout()
                await VFX.fadeout_finished

                get_tree().change_scene_to_file('res://title.tscn')
        else:
            if CTX.enemy.fire_weakness_flg:
                SFX.play_track(SFX.HIT)
                window_message.scroll_text("The " + CTX.enemy.name + " bursts into flames!")
                await window_message.closed

                CTX.enemy.hp = 0
            else:
                SFX.play_track(SFX.HIT)
                var dmg = rng.randi_range(3, 6)
                window_message.scroll_text("You light the " + CTX.enemy.name + " on fire for " + dmg + " damage!")
                await window_message.closed

    else:
        CTX.torch_flg = true
        window_message.scroll_text("You lit a torch.")
        await window_message.closed

var torch = {
    "name": "Torch",
    "description": "A disposable torch.",
    "use": use_torch
}

func initialize_player():
    CTX.stats.hp = 10
    CTX.inventory = [potion.duplicate(), torch.duplicate(), torch.duplicate()]

func _ready() -> void:
    initialize_player()
    get_player_name()
    streets_text_list.shuffle()
    await got_player_name
    await window_message.closed

    window_message.scroll_text("Very well " + CTX.player_name + ". I hope you are prepared for a dark adventure")
    await window_message.closed

    Music.play_track(Music.EERIE)
    opening_scene()

func get_player_name():
    CTX.player_name = await window_message.prompt("What is your name?")
    if CTX.player_name:
        emit_signal("got_player_name")
    else:
        VFX.flash(Color.WHITE)
        SFX.play_track(SFX.CRIT)
        window_message.scroll_text("Please don't be difficult")
        await window_message.closed
        get_player_name()

func opening_scene():
    var text = "You are weary from work and stalked by an unseen horror. Cobblestones whisper under your feet, shadows writhe, and a clammy dread wraps around you."
    window_message.scroll_text(text)
    await window_message.closed

    await what_will_you_do()

func run():
    for text in run_texts:
        window_message.scroll_text(text)
        await window_message.closed

    await inn()

func inn():
    var text = "The creaking oak doors groan open, revealing a dusty interior bathed in pale moonlight."
    window_message.scroll_text(text)
    await window_message.closed

    text = "Cobwebs festoon the rafters, and an unsettlingly sweet musk hangs in the air."
    window_message.scroll_text(text)
    await window_message.closed

    text = "An old woman sits hunched behind a counter, her eyes glinting with an unnatural light."
    window_message.scroll_text(text)
    await window_message.closed

    Music.stop()
    text = "She whispers..."
    window_message.scroll_text(text)
    await window_message.closed

    text = "Hello " + CTX.player_name + " ..."
    window_message.scroll_text(text)
    await window_message.closed

    Music.play()

    window_message.show_menu(
        "What will you do?",
        ["TALK", "EXIT"]
    )
    var idx = await window_message.option_selected

    if idx == 0:
        window_message.scroll_text("You approach the woman to talk.")
        await window_message.closed

        talk_with_woman()
    elif idx == 1:
        window_message.scroll_text("You venture to the streets.")
        await window_message.closed

        streets()

func talk_with_woman():
    window_message.scroll_text("The woman leans closer, her voice dropping to a whisper.")
    await window_message.closed

    Music.stop()
    window_message.scroll_text("You sense it too, don't you?")
    await window_message.closed

    Music.play()
    window_message.scroll_text("The nameless horror that stalks the night, older than time and hungrier than the grave.")
    await window_message.closed

    window_message.scroll_text("The woman's touch sends a cold shiver down your spine.")
    await window_message.closed

    window_message.scroll_text("Within these walls, it cannot touch you,..")
    await window_message.closed

    window_message.scroll_text("The Quill protects... but the price is steep.")
    await window_message.closed

    window_message.show_menu(
        "What will you do?",
        ["PAY THE PRICE", "REFUSE"]
    )

    var idx = await window_message.option_selected
    if idx == 0:
        price()
    elif idx == 1:
        battle_scene(woman)
        await battle_scene_completed
        uncertainty()

func uncertainty():
    Music.play_track(Music.DANGER)
    window_message.scroll_text("As the last tremors fade, a wave of exhaustion washes over you.")
    await window_message.closed

    window_message.scroll_text("You slump to the ground, the weight of what you've done settling in.")
    await window_message.closed

    window_message.scroll_text("The lines blur, the answer lost in the chilling echo of the old woman's final, inhuman laughter.")
    await window_message.closed

    window_message.scroll_text("No sign of the quill could be found, nor the feeling of being persued.")
    await window_message.closed

    window_message.scroll_text("Was this all in your mind, after all?")
    await window_message.closed

    the_end()


func price():
    window_message.scroll_text("The ground trembles, and a bloodcurdling shriek pierces the night.")
    await window_message.closed
    window_message.scroll_text("The entity screams its hunger.")
    await window_message.closed
    window_message.scroll_text("Then...")
    await window_message.closed
    window_message.scroll_text("Silence...")
    await window_message.closed
    window_message.scroll_text("The woman is gone, replaced by a glowing quill.")
    await window_message.closed

    window_message.show_menu(
        "What will you do?",
        ["TAKE THE QUILL", "LEAVE IT"]
    )

    var idx = await window_message.option_selected
    if idx == 0:
        escape()
    elif idx == 1:
        refused_quill()

func refused_quill():
    window_message.scroll_text("You stumble, lungs burning, heart hammering a frantic dirge against your ribs. The cobblestones blur beneath your feet, twisted by the encroaching darkness that seeps from the nameless alleyways. Footsteps, rhythmic and heavy, thud closer, each echo a hammer blow upon the crumbling fortresses of your mind.")
    await window_message.closed

    window_message.scroll_text("Ahead, the moon hides its face, leaving you bathed in an oppressive gloom. You dare not glance back, for you know what you'll see – a silhouette vast and inhuman, eyes that pierce the veil of reality, its form a mockery of geometry itself. Every fiber of your being screams to ignore, to keep running, but curiosity, a barbed hook, draws your gaze back.")
    await window_message.closed

    Music.play_track(Music.BATTLE)

    window_message.scroll_text("The footsteps are at your heels now, each one closer than the last. You taste dust and despair, the tang of madness thick in the air. There's no escape, you know. The shadows themselves seem to constrict, squeezing the very air from your lungs.")
    await window_message.closed

    SFX.play_track(SFX.CRIT)
    VFX.flash(Color.RED)
    await get_tree().create_timer(0.5).timeout
    VFX.flash(Color.RED)
    await get_tree().create_timer(1).timeout

    the_end()

func escape():
    Music.play_track(Music.AMBIENT)

    window_message.scroll_text("You clutched the quill, a cold sense of dread settling in your stomach.")
    await window_message.closed

    window_message.scroll_text("You survived, but at what cost? You have bought your life with something precious, something your may never understand.")
    await window_message.closed

    window_message.scroll_text("As you stumble out of the inn, the first tendrils of dawn painted the sky, but the horror lingers within you")
    await window_message.closed

    window_message.scroll_text("You know that the entity won't remain quiet forever.")
    await window_message.closed

    window_message.scroll_text("The price of the Quill's protection will come due, and you can only pray that you will be strong enough to pay it when the time comes.")
    await window_message.closed

    the_end()


func the_end():
    VFX.fadeout()
    await VFX.fadeout_finished

    the_end_label.visible = true

    await get_tree().create_timer(2).timeout

    VFX.fadeout()
    await VFX.fadeout_finished

    Music.stop()

    await VFX.fadein_finished
    await get_tree().create_timer(1).timeout

    get_tree().change_scene_to_file('res://title.tscn')

func what_will_you_do():
    window_message.show_menu(
        "What will you do?",
        ["CONTINUE JOURNEY", "SEEK REFUGE", "ITEM"]
    )

    var idx = await window_message.option_selected
    if idx == 0:
        window_message.scroll_text("You continue your journey home...")
        await window_message.closed

        streets()
    elif idx == 1:
        window_message.scroll_text("You run, searching for shelter.")
        await window_message.closed
        await run()

    elif idx == 2:
        window_message.show_inventory()
        var invn_idx = await window_message.option_selected
        print("Got inventory idx: " + str(invn_idx))
        if invn_idx >= 0:
            var item = CTX.inventory.pop_at(invn_idx)
            await item.use.call()

        else:
            window_message.scroll_text("You fumble with your belongings...")
            await window_message.closed

        what_will_you_do()

func streets():
    var text = streets_text_list.pop_front()

    if CTX.streets_counter == 5:
        Music.play_track(Music.MEMORIES)
        window_message.scroll_text("Sanity, a tattered flag, fluttered limply. Yet, through the maddening whispers and geometries gone awry, a pinprick of light. It grew, a monstrous tear in the night's fabric, revealing a vista both wondrous and horrifying. Sunrise, not as you knew it, but a cosmic maw spitting forth light that pulsed with alien hues.")
        await window_message.closed

        window_message.scroll_text("Madness clawed, tempting surrender. But a defiant spark ignited within, fueled by a primal yearning for normalcy. You pressed on, mind screaming as it wrestled with the impossible dawn. Each step, a victory against the encroaching void.")
        await window_message.closed

        window_message.scroll_text("Finally, you stood bathed in the alien light, your fragile form dwarfed by its immensity. Tears streamed down your face, a mixture of terror and elation. You had glimpsed the abyss, yet emerged, forever marked but unbroken. The sun, both beautiful and terrible, was a reminder: sanity was fragile, the void ever-present, but even in the face of cosmic horror, there was defiance, a flicker of hope in the encroaching madness.")
        await window_message.closed

        the_end()

    elif CTX.streets_counter == 4:
        text = "Sun cracks, birthing eldritch light. Horizon bleeds, oozing madness. Shadows writhe, screaming defiance. Hope flickers, devoured by the hungry sky."

    var chance = rng.randi_range(1, 6)
    if CTX.torch_flg:
        chance = 6
        CTX.torch_flg = false
        window_message.scroll_text("A lone torch flickers in a darkness. Its dimming light wards off unseen horrors.")
        await window_message.closed

    if chance < 5:
        Music.stop()
        window_message.scroll_text("Something feels wrong...")
        await window_message.closed

        battle_scene()
        await battle_scene_completed

        VFX.fadeout()
        await VFX.fadeout_finished

        Music.play_track(Music.EERIE)

    window_message.scroll_text(text)
    await window_message.closed

    CTX.streets_counter += 1
    await what_will_you_do()

func battle_scene(enemy=null):
    CTX.battle_flg = true
    CTX.enemy = enemy
    if not enemy:
        CTX.enemy = enemies.pick_random().duplicate()

    VFX.fadeout()
    await VFX.fadeout_finished
    Music.play_track(Music.BATTLE)

    window_message.scroll_text(CTX.enemy.description)
    await window_message.closed

    while true:
        window_message.show_menu(
            "What will you do?",
            ["FIGHT", "ITEM", "FLEE"]
        )
        var idx = await window_message.option_selected
        if idx == 0:
            await player_attack()

        elif idx == 1:
            window_message.show_inventory()
            var invn_idx = await window_message.option_selected
            if invn_idx >= 0:
                var item = CTX.inventory.pop_at(invn_idx)
                await item.use.call()
            else:
                window_message.scroll_text("You fumble with your belongings...")
                await window_message.closed

        elif idx == 2:
            window_message.scroll_text("You attempt to flee and...")
            await window_message.closed

            if rng.randi_range(1, 6) > 2:
                window_message.scroll_text("You manage to escape.")
                await window_message.closed

                battle_scene_completed.emit()
                CTX.battle_flg = false
                return
            window_message.scroll_text("The " + CTX.enemy.name + " prevents you from escapng.")
            await window_message.closed

        if CTX.enemy.hp <= 0:
            window_message.scroll_text("You defeated the " + CTX.enemy.name)
            await window_message.closed

            battle_scene_completed.emit()
            CTX.battle_flg = false
            return

        await enemy_attack()

        if CTX.stats.hp <= 0:
            Music.stop()
            window_message.scroll_text("You were defeated...")
            await window_message.closed

            VFX.fadeout()
            await VFX.fadeout_finished

            get_tree().change_scene_to_file('res://title.tscn')

func player_attack():
    var hit_roll = rng.randi_range(1, 6)
    window_message.scroll_text("You attempt to hit the " + CTX.enemy.name)
    await window_message.closed

    if hit_roll == 1:
        window_message.scroll_text("but miss..")
        await window_message.closed

        return

    if hit_roll == 6:
        SFX.play_track(SFX.CRIT)
        VFX.flash(Color.WHITE)
        await get_tree().create_timer(0.5).timeout

        SFX.play_track(SFX.HIT)
        var crit_dmg = CTX.stats.atk * 2
        CTX.enemy.hp -= crit_dmg
        window_message.scroll_text("You hit " + CTX.enemy.name + " with a terrific blow for " + str(crit_dmg) + " damage!")
        await window_message.closed

        return

    SFX.play_track(SFX.HIT)
    var dmg = rng.randi_range(1, CTX.stats.atk)
    CTX.enemy.hp -= dmg
    window_message.scroll_text("You hit " + CTX.enemy.name + " for " + str(dmg) + " damage!")
    await window_message.closed

func enemy_attack():
    var hit_roll = rng.randi_range(1, 6)
    var verb = CTX.enemy.verbs.pick_random()
    window_message.scroll_text("The " + CTX.enemy.name + " attempts to attack you...")
    await window_message.closed

    if hit_roll == 1:
        window_message.scroll_text("but misses...")
        await window_message.closed

        return

    if hit_roll == 6:
        SFX.play_track(SFX.CRIT)
        VFX.flash(Color.RED)
        await get_tree().create_timer(0.5).timeout

        VFX.flash(Color.RED)
        await get_tree().create_timer(0.5).timeout

        SFX.play_track(SFX.HIT)
        var crit_dmg = CTX.enemy.atk * 2
        CTX.stats.hp -= crit_dmg
        window_message.scroll_text("The " + CTX.enemy.name + " fericiously " + verb + " you for " + str(crit_dmg) + " damage!")
        await window_message.closed

        return

    VFX.flash(Color.RED)
    SFX.play_track(SFX.HIT)
    var dmg = rng.randi_range(1, CTX.enemy.atk)
    CTX.stats.hp -= dmg
    window_message.scroll_text("The " + CTX.enemy.name + " " + verb + " you for " + str(dmg) + " damage...")
    await window_message.closed
