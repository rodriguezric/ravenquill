extends Node

var player_name := ""
var inventory := []
var stats := {
    "max_hp": 10,
    "hp": 10,
    "atk": 3,
}
var streets_counter := 0
var torch_flg := false
var battle_flg := false
var enemy = {}

var rng = RandomNumberGenerator.new()

func dice_roll(sides: int, mod := 0) -> int:
    return rng.randi_range(1, sides) + mod
