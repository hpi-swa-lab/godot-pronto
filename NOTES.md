# Iteration 2 - Week 1

## Was uns in Pronto fehlt:

Wir hätten uns eine Funktion gewünscht, die nachdem man die Maustaste gedrückt hält und wieder loslässt ein Signal auslöst, was die Dauer, die die Maustaste gedrückt war, übergibt.

Bei den Funktionsparametern in den Connection-Windows wäre es besser statt z.B. arg0, arg1 die tatsächlichen Parameternamen zu verwenden. 

## Problem mit Pronto-Framework

Uns ist aufgefallen, dass die move_direction Methode in dem Move Behavior seltsames Verhalten bei unterschiedlichen FPS aufweist. Dies sorgt zum Beispiel dafür, dass unsere Pfeile manchmal mit einer deutlich zu hohen velocity gespawnt werden, obwohl diese eigentlich konstant definiert ist.

## Probleme durch vorherige Iterationen:

Bei der Verwendung eines Spawners ist uns ein Problem mit dem `spwan_toward` und einem Move auf dem erzeugten Child-Node aufgefallen: In den Examples davor konnte man mit `move_right` ein erzeugtes Projektil in die gespawnte Richtung bewegen. Nun bewegt sich das Projektil jedoch immer nach rechts (das "globale" rechts), unabhängig von seiner (angezeigten) Rotation. Dies liegt scheinbar daran, dass nur der `path_corrector` rotiert ist, nicht jedoch die eigentlich erzeugte Instanz, was das Verhalten davon ein wenig kaputt macht.
