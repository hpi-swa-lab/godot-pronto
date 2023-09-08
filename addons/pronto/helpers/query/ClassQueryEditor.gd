@tool
extends HBoxContainer

signal changed_query

var query: ClassQuery

func set_query(q: ClassQuery):
	query = q

func _ready():
	var names_of_classes = Utils.all_node_classes()
	$OptionButton.clear()
	for index in range(names_of_classes.size()):
		var c = names_of_classes[index]
		$OptionButton.add_item(c)
		if c == query.name_of_class:
			$OptionButton.select(index)

func _change(index):
	query.name_of_class = $OptionButton.get_item_text(index)
	changed_query.emit()
