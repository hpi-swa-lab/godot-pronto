
Gumdrop Aseprite Features & Scripts

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Installation:
You'll need to move the two .lua files in Scripts/ into your aseprite scripts folder.
If you can't find the aseprite scripts folder go to the scripts submenu under the file menu and select open script folder.

Instruction:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Color Swapping:

The easiest thing to understand is the palette.  Starting at index 70 the palette describes a body part in 5 color intervals.
Generally these five color ramps go from light to dark.
For example colors 155 through 159 refer only to the colors used on pants layers.
If those colors are shades of blue, then you can replace the colors of the pants without changing all the other blues.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Costume/Layer Management:

This is a more complex feature, but its very powerful

Costumes are batches of layers defined in the user data of any layer in the "_costumes" folder
Costumes names are defined by the layer's name and their contents are defined in it's user data

To access user data, right click the layer then choose properties.  There is a small checkbox which expands to show a "data" field.

The names of the costume layers can begin with "+" or "_"
Names starting "+" are managed with check boxes and called Options
Names starting "_" are managed with radio buttons, so are only active one at a time, these are called "Costumes"


The lists in the data fields don't refer to literal lauyer names but to all layers which match that name when you ignore everything after the ":" character
So "arms" refers to "North/arms:fg, South/arms:bg ... etc"

The syntax used in the costume data is pretty simple:
List layer names in between commas
You can include another costume in the list by listing it starting with the "_" character
A '-' character can remove (blacklist) a layer found in one of the costumes in the list


For example this is the content of the "_peasant" layer's user data:

_human, vest, pants, ehoes, sleeves, hood, tuft, shoes, -ears

This will include everything "_human" costume does, like a face and legs, 
but human includes ears which we shouldn't show when the hood is showing
The "-ears" entry will hide the ears

Having this data allows us to record and swap between costumes with the GumdropSprite.lua script

Run the script and select the manage costume options.

There is on unique layer called "placeholder" this contains an almost completely transparent pixel in each corner (index 64)
As long as this layer is active all your sprite sheets will line up, you'll need this to keep optional layers like swords aligned to the full sprite sheets

Any layer outside the "_costumes" folder that starts "_" is going to be ignored.  This keeps the interface clean and I use it for works in progress or concept art

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Exporting sprites:

This is only necessary if you plan on keeping your metadata in place when exporting your sprite.

You can use the export sprite option in the Gumdrop script dialog to create a copy which collapses the layers and creates a west face
when you separate both layers and tags in the sprite export dialog (set by default when it pops up) then you'll get everything you need
But if you also want the metadata there's another step.
Choose the 'mutate metadata' checkbox in the Gumdrop dialog before selecting the export button.
This will cause a file dialog to pop up after you do your export - it wants you to find the .JSON you just saved so the script can do some edits.

If you select the file and 'confirm' your metadata will include all direction+animation combinations for example:
IdleSouth, WalkNorth, SwingAWest, etc...
Both Godot and Unity have tools which import aseprite animations using this metadata

Oct 27th, 2022
Several continuity errors are still present in the public release, I'm trying to catch 'em all while I do some polish work rather than spamming hotfixes
