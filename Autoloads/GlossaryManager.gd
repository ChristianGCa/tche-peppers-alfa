extends Node

var known_terms: Dictionary = {}
var unviewed_terms: Dictionary = {}

signal new_term_unlocked(term_english: String, term_portuguese: String)

func unlock_term(term_english: String, term_portuguese: String):
	if not known_terms.has(term_english):
		known_terms[term_english] = term_portuguese
		unviewed_terms[term_english] = term_portuguese
		emit_signal("new_term_unlocked", term_english, term_portuguese)

func mark_all_as_viewed():
	unviewed_terms.clear()

func has_unviewed_terms() -> bool:
	return unviewed_terms.size() > 0
