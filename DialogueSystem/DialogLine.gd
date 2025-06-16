extends Resource
class_name DialogLine

@export var speaker_name: String
@export var text: String
@export var portrait: Texture
@export var choices: Array[ChoiceOption] = []

# Novos campos para manipular objetivos
@export var creates_objective: bool = false
@export var completes_objective: bool = false
@export var objective_text: String = ""
