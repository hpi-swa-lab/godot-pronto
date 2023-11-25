-- costume manager

-- uses special layer data in _costume folder
-- the _costume layers use the user data field
-- and a special syntax to control and save constumes

-- I call the building blocks of costumes "meta_layers"
-- A meta_layer is every layer in the project with the same name
-- the name check ignores anything after ":" like foreground/background
-- the name check grabs layers across separate folders
-- the name check skips layers starting with '_' which indicates a WIP

-- A costume is a combination of different elements
-- the _costumes folder's layers are each a costume
-- to see the costume's information double click the layer's name
-- you'll see a layer properties box with a small check box
-- the check box expands to show 'user data'
-- that's where a costume is described


-- The syntax for costumes is simple
-- words between the commas are the "meta_layers" which will be visible
-- if a word starts with "_" it's referring to another costume
-- so "_human" is a short way to say "head","torso","arms","legs","face","ears"
-- if a word starts with a "-" sign it is removed
-- a common use is to add "-ears" to any use of a hood which would cover them up
-- using "-face" improves normal map generation pipelines

-- finally a "placeholder" layer exists so sheets which only feature certain frames
-- will lay over the normal sprite sheet early, for example the sword or smear layers


--constants
json = dofile('./dkjson.lua')
orientations = {North=true,South=true,West=true,East=true}
BUTTON_ROWS = 3


--utility function
function hide_layers(group)
	for i, layer in ipairs(group.layers) do
		if layer.isGroup then
			hide_layers(layer)
		else
			layer.isVisible=false
		end
	end
end

--returns table referencing all layers ignoring groups
--filters out groups starting with _ which are reserved for data

function get_layers(group, rtrn_layers)
	group = group and group or app.activeSprite
	local normal_layers = rtrn_layers and rtrn_layers or {}
	for idx, layer in ipairs(group.layers) do
		if layer.isGroup then
			normal_layers = get_layers(layer, normal_layers)
		elseif layer.name:sub(0,1) ~= '_' and layer.name:sub(0,1) ~= '+' then
			table.insert(normal_layers,layer)
		end
	end
	return normal_layers
end

--builds table from layer names
--groups layers across folders regardless of foreground/backrgound
--does this by ignoring ":" and everything after in layer name
function get_meta_layers()
	input_layers = get_layers()
	local meta_layers = {}
	for _, layer in ipairs(input_layers) do
		local stripped_name = string.sub(layer.name,1,
			layer.name:find(':') and layer.name:find(':')-1 or nil)
		if not meta_layers[stripped_name] then
			meta_layers[stripped_name] = {layer}
		else
			table.insert(meta_layers[stripped_name],layer)
		end
	end
	return meta_layers
end

--filters superlayers having names starting "_"
--this is used to format wip and utility layers
function get_user_meta_layers(meta_layers)
	local user_meta_layers = {}
	for name, included in ipairs(meta_layers) do
		if not name:gmatch('^_') then
			user_meta_layers[name]=included
		end
	end
	return user_meta_layers
end

--assemble a table of costume costume options
--from _costume folder, includes data section as string
--uses layer names as keys

function get_costume_user_data()
	local costume_group = {layers={}}
	local costume_user_data = {}
	for i,layer in ipairs(app.activeSprite.layers) do
		if layer.name == '_costumes' then
			costume_group = layer
			break
		end
	end
	for i, data_layer in ipairs(costume_group.layers) do
		costume_user_data[data_layer.name] = data_layer.data
	end
	return costume_user_data
end


-- takes costume data and creates a hash table per costume
-- hash contains names of metalayers in each costume
-- returns table of costume and hashes (table of metalayer names)
-- "_" prefix combines layers from another costume
-- "-" prefix removes layer from hash

function parse_costume_data()
	costume_user_data = get_costume_user_data()
	local parsed_data = {}
	for name, data_string in pairs(costume_user_data) do
		hash = helper_parser(costume_user_data, name)
		parsed_data[name]=hash
	end
	return parsed_data
end

--combines data strings from all costume referred to be other costume
--then manages blacklisted layers and returns hash

--parses the string in the user data field of a costume layer
--syntax explained above
--we only chase a reference 10 costumes "deep" to avoid infinite loops

function helper_parser(costume_data,first_costume_name)
	data_string = ''
	local depth = 0
	local list = {}
	for s in string.gmatch(costume_data[first_costume_name],'[^,^%s]+') do
		list[#list+1]=s
	end
	local hash = {}
	for i,s in ipairs(list) do
		if string.sub(s,1,1) == "_" and costume_data[s] then
			depth = depth + 1
			if depth > 10 then break end
			local add_list = {}
			for _s in string.gmatch(costume_data[s],'[^,^%s]+') do
				add_list[#add_list+1]=_s
			end
			for _i, _s in ipairs(add_list) do
				list[#list+1]=_s
			end
		end
	end
	--handles blacklist layers
	for i,s in ipairs(list) do
		if string.sub(s,1,1) == "-" then
			for _i, _s in ipairs(list) do
				if list[_i] == string.sub(s,2) then
					list[_i] = '-'
				end
			end
		end
	end
	--creates hash out of normal super layers in list
	for i, s in ipairs(list) do
		if not (string.sub(s,1,1) == "-" or string.sub(s,1,1) == "_") then
			hash[s]=true
		end
	end
	return hash
end

-- associates costumes with layers in their super layers
-- creates table used by dialog

function get_costume_data()
	parsed_data = parse_costume_data()
	meta_layers = get_meta_layers()
	local costume_data = {costumes={},options={}}
	for name, hash in pairs(parsed_data) do
		target_table = name:sub(0,1)=='+' and 'options' or 'costumes'
		table.insert(costume_data[target_table], {name=name,layers={}})
		for entry in pairs(hash) do
			if meta_layers[entry] then
				for i,layer in ipairs(meta_layers[entry]) do
					table.insert(costume_data[target_table][#costume_data[target_table]].layers,layer)
				end
			end
		end
	end
	return costume_data
end

-- creates dialog to swap costume characters using costume_data
-- debug function dialogs

function init_costumes_dialog()
	local costume_data = get_costume_data()
	local costumes = costume_data.costumes
	local options  = costume_data.options
	local j = -1
	dlg = Dialog()
	for i, option_entry in ipairs(options) do
		j = j + 1
		if j % BUTTON_ROWS == 0 then
			dlg:newrow()
		end
		dlg:check{
			id = option_entry.name:sub(2),
			selected = false,
			text = string.sub(option_entry.name,2),
			onclick = function()
				for _, layer in ipairs(option_entry.layers) do
					layer.isVisible = dlg.data[option_entry.name:sub(2)]
				end
				app.refresh()
			end
		}
	end
	dlg:separator()
	for i, costume_entry in ipairs(costumes) do
		if (i-1) % BUTTON_ROWS == 0 then
			dlg:newrow()
		end
		dlg:radio{
			id = costume_entry.name:sub(2),
			text = string.sub(costume_entry.name,2),
			onclick = function()
				hide_layers(app.activeSprite)
				for i, option_entry in ipairs(options) do
					for _, layer in ipairs(option_entry.layers) do
						layer.isVisible = dlg.data[option_entry.name:sub(2)]
					end
				end
				for _, layer in ipairs(costume_entry.layers) do
					layer.isVisible = true
				end
				app.refresh()
			end
		}
	end
	dlg:newrow()
	dlg:button{
		text = "clear",
		onclick = function()
			hide_layers(app.activeSprite)
			app.refresh()
		end
	}
	dlg:newrow()
	dlg:button{
		text = "done",
		onclick = function()
			dlg:close()
		end
	}
	dlg:show()
end

--gets folder references in standard json metadata
function getOris(jdata)
	local layers = jdata.meta.layers
	local orientations = {}
	for i=#layers, 1 , -1 do
		orientations[#layers- i + 1] = layers[i].name
	end
	return orientations
end
--gets updated version of frame tags in metadata
function getOriTags(jdata)

	tags = jdata.meta.frameTags

	local oris = getOris(jdata)
	local oriTags = {}
	local frame = 0

	for i, otag in ipairs(tags) do
		local tagLength = otag.to - otag.from
		for j ,ori in ipairs(oris) do
			local pTag ={}
			for k, v in pairs(otag) do
				pTag[k] = v
			end
			pTag.name = otag.name .. ori
			pTag.from = frame
			pTag.to = frame + tagLength
			oriTags[#oriTags+1]=pTag
			frame = pTag.to + 1
		end
	end

	return oriTags

end		

--create extra entries for animations based on 
--orientation/direction permutations derived from
--folders and tags

function mutate_metadata(draft_json_path)
	file = io.open(draft_json_path,'r')
	idata = file:read('*a')
	jdata = json.decode(idata)
	file:close()

	ntags = {}

	jdata.meta.frameTags = getOriTags(jdata)

	ndata = json.encode(jdata,{indent=true})

	file = io.open(draft_json_path,'w')

	file:write(ndata)

	file:close()

	

end


--folders should be arranged 
-- _costumes
-- north
-- east
-- south
-- here we flatten and flip east folder into west

function make_west_folder(flat_sprite)
	app.activeSprite = flat_sprite
	flat_sprite.filename = 'Flat_'..flat_sprite.filename
	app.activeLayer = flat_sprite.layers[2]
	app.command.DuplicateLayer()
	app.range:clear()
	app.range.layers={flat_sprite.layers[2]}
	app.command.FlattenLayers(flat_sprite.layers[2])
	flat_sprite.layers[3].name = "East"
	local west_group = flat_sprite:newGroup()
	west_group.name = "West"
	flat_sprite.layers[2].parent=west_group
	west_group.stackIndex = 4
	app.activeLayer = west_group.layers[1]
	app.activeLayer.name = "west_flat"
	app.range:clear()
	app.range.layers={app.activeLayer}
	for i,x in ipairs(app.range.editableImages) do
		app.activeImage = x 
		app.activeSprite.selection:selectAll()
		app.command.Flip({target="mask"})
	end
end

--just flattens the orientation folders single layers

function flatten_facing_groups(in_sprite)
	for idx=1, #in_sprite.layers do
		local layer = in_sprite.layers[idx]
		if orientations[layer.name] then
			local name = layer.name
			local data = layer.data
			app.range:clear()
			app.range.layers = {layer}
			app.command.FlattenLayers()
			in_sprite.layers[idx].name = name
			in_sprite.layers[idx].data = data
		end
	end
end

--brings out the standard exporting dialog
--then asks to select the .json which was exported
--which will be mutated based on this script

function init_export_dialog(mutate_requested)
	app.command.ExportSpriteSheet {
	  ui=true,
	  askOverwrite=true,
	  type=SpriteSheetType.ROWS,
	  textureFilename= "GUMDROP.PNG",
	  dataFilename= "GUMDROP.JSON",
	  dataFormat=SpriteSheetDataFormat.JSON_ARRAY,
	  filenameFormat="{title} ({layer}) {frame}.{extension}",
	  openGenerated=true,
	  layer="",
	  tag="",
	  splitLayers=true,
	  splitTags=true,
	  listLayers=true,
	  listTags=true,
	  listSlices=true
	}
	if mutate_requested then
		mutate_metadata(reopen_metadata())
	end
end

--calls a dialog to find the exported metadata file

function reopen_metadata()
	local dlg = Dialog()
	dlg:label{
		id="label",
		label="Select the JSON file you just saved"}
	dlg:file{ id="filepath",
	          label="Sprite Metadata:",
	          title="Sprite Metadata Refactoring",
	          filetypes={'JSON'},
	          load = true
	         }
	dlg:newrow()
	dlg:button{ id="cancel", text="Cancel" }
	dlg:button{ id="confirm", text="Confirm"}
	dlg:show()
	return dlg.data.filepath
end


function init_gumdrop_dialog()
	local dlg = Dialog{title="Gumdrop Utility Tools"}
	dlg:button{ id="costumes", text="Costumes", 
				onclick = function()
				init_costumes_dialog() 
				dlg:close()
				end }
	dlg:newrow()
	dlg:check{ id = "mutate", text="Permutate Metadata",value=true}
	dlg:newrow()
	dlg:button{ id="export", text="Export Sprite",
				onclick = function()
					local flat_sprite = Sprite(app.activeSprite)
					make_west_folder(flat_sprite)
					flatten_facing_groups(flat_sprite)
					init_export_dialog(dlg.data.mutate)
					flat_sprite:close()
					dlg:close()
				end }
	dlg:show()
end

init_gumdrop_dialog()