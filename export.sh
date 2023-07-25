EXPORT_FILES=""
# add pronto files
for entry in `find addons/pronto -type f`; do
    EXPORT_FILES="$EXPORT_FILES\"res://${entry}\", "
done

# add prototype files
SCENE_NAME=$1
echo "Creating export config for: $SCENE_NAME."
for entry in `find $SCENE_NAME -type f`; do
    EXPORT_FILES="$EXPORT_FILES\"res://${entry}\", "
done

# try removing the old export config
rm -f export_presets.cfg
# write new export config
cat << EOF >> export_presets.cfg
[preset.0]

name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="resources"
export_files=PackedStringArray(`echo $EXPORT_FILES | sed 's/\(.*\),/\1/'`)
include_filter=""
exclude_filter=""
export_path="build/web/index.html"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0, 0, 0, 1)
EOF

# start godot web export
godot --headless --export-release Web build/web/index.html