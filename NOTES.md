# Iteration 2 - Week 1

## Was uns in Pronto fehlt:

Wir hätten uns eine Funktion gewünscht, die nachdem man die Maustaste gedrückt hält und wieder loslässt ein Signal auslöst, was die Dauer, die die Maustaste gedrückt war, übergibt.

## Probleme durch vorherige Iterationen:

Bei der Verwendung eines Spawners ist uns ein Problem mit dem `spwan_toward` und einem Move auf dem erzeugten Child-Node aufgefallen: In den Examples davor konnte man mit `move_right` ein erzeugtes Projektil in die gespawnte Richtung bewegen. Nun bewegt sich das Projektil jedoch immer nach rechts (das "globale" rechts), unabhängig von seiner (angezeigten) Rotation. Dies liegt scheinbar daran, dass nur der `path_corrector` rotiert ist, nicht jedoch die eigentlich erzeugte Instanz, was das Verhalten davon ein wenig kaputt macht.
