@tool
extends VBoxContainer

signal changed_query

var query: PredicateQuery

func set_query(q: PredicateQuery):
	query = q
	$expression_edit.edit_script = q.predicate

func _change():
	query.set_predicate_source($expression_edit.text)
	changed_query.emit()
