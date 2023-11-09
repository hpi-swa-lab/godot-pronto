EXPORT_SCENES=`grep -r -l '^\[node name="ExportBehavior" type="Node2D" parent=".*"\]' . | tr " " "\n"`
COUNT=0
for scene in $EXPORT_SCENES
do
    GAME_FOLDER=`echo $scene | sed 's|\(.*\)/.*|\1|'`
    COUNT=$((COUNT+1))
done
if [ $COUNT -eq 1 ]
then
    echo $GAME_FOLDER
else
    # IMPORTANT: This message needs to start with "Error:" so that the CI fails
    echo "Error: Found ${COUNT} scenes with ExportBehavior:"
    # Print all scenes with ExportBehavior in them:
    for scene in $EXPORT_SCENES
    do
        echo $scene
    done
fi
