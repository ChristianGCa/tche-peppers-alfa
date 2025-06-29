class_name DialogLine
extends Resource

enum SpeakerType { NPC, PLAYER }

@export var speaker_type: SpeakerType = SpeakerType.NPC
@export var text: String
@export var choices: Array[ChoiceOption] = []

@export var creates_objective: bool = false
@export var completes_objective: bool = false
@export var objective_text: String = ""

@export var triggers_minigame: bool = false
@export var minigame_json_path: String = ""
