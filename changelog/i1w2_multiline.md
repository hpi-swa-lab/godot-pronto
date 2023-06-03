# Changelog

## Iteration 1 Week 2

### Multiline Editing with Side Effects
* Expressions in the pronto connection editor now support multiline editing with responsive text boxes
* All text fields where values are returned now require an explicit "return" statement
	- Such return statements will be automatically placed inside text boxes where they are needed
	- (Missing return statements will not throw an error during compilation)

#### How this affects you
* Old connections with custom code values will need to have the return statement added (this does not happen automatically)

#### Misc
* Previously, return statements were added in front of the text box code (based on the connection type). Now, the whole textbox is the executed code.
* The responsiveness and behavior of text boxes seems to vary between different resolutions and UI scales. This is likely caused by Godot itself.