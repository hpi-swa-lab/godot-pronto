# Iteration 2 - Week 1

## Was uns in Pronto fehlt

Wir hätten uns eine Funktion gewünscht, die nachdem man die Maustaste gedrückt hält und wieder loslässt ein Signal auslöst, was die Dauer, die die Maustaste gedrückt war, übergibt.

Bei den Funktionsparametern in den Connection-Windows wäre es besser statt z.B. `arg0, arg1` die tatsächlichen Parameternamen zu verwenden.

## Problem mit Pronto-Framework

Uns ist aufgefallen, dass die move_direction Methode in dem Move Behavior seltsames Verhalten bei unterschiedlichen FPS aufweist. Dies sorgt zum Beispiel dafür, dass unsere Pfeile manchmal mit einer deutlich zu hohen velocity gespawnt werden, obwohl diese eigentlich konstant definiert ist.

Hierfür haben wir im Move Behavior in der Methode `move_direction()` folgende Änderung vorgenommen.

```python
#  velocity = velocity.lerp(direction * max_velocity, min(1.0, _accel * get_process_delta_time()))

velocity = velocity.lerp(direction * max_velocity, min(1.0, _accel * 0.006))
```

### Relative Position Spawner und seines Kind-Objekts

Was bei uns anfänglich für Verwirrung gesorgt hat ist, dass die Spawnposition von der relativen Position des Kindes in der Editor-Szene zum Spawner abhängt. Das Verwirrende hierbei ist, das bei den restlichen Connections und Behaviors die relative Position keine Rolle spielt. Schöner wäre es unserer Meinung, wenn die Position keine Rolle spielt und der Offset stattdessen z.B. im Inspector des Spawners einstellbar ist.

### Spawner im Spawner

Uns ist aufgefallen, dass es zu einem Fehler kommt, wenn ein gespawntes Element (sei dies "X") einen Spawner als Kindobjekt besitzt. Hierbei wird beim Starten der Szene das Kind dieses Spawners entfernt. Wenn nun ein Objekt "X" gespawnt wird, besitzt dessen Spawner kein Kind mehr, weshalb es zu einem Fehler kommt. Um dies einfach zu lösen, ist es aktuell ausreichend eine `Node2D` als erstes Kind dem inneren Spawner (von "X") zu setzen.

## Probleme durch vorherige Iterationen

Bei der Verwendung eines Spawners ist uns ein Problem mit dem `spawn_toward()` und einem Move auf dem erzeugten Child-Node aufgefallen: In den Examples davor konnte man mit `move_right()` ein erzeugtes Projektil in die gespawnte Richtung bewegen. Nun bewegt sich das Projektil jedoch immer nach rechts (das "globale" rechts), unabhängig von seiner (angezeigten) Rotation. Dies liegt scheinbar daran, dass nur der `path_corrector` rotiert ist, nicht jedoch die eigentlich erzeugte Instanz, was das Verhalten davon ein wenig kaputt macht.

## Wo mussten wir auf Code ausweichen

### Reflexion des Pfeils an Wänden

Um die Pfeilreflexion zu implementieren, mussten wir die Collision Behavior Klasse verändern. Dies liegt daran, dass wir möglichst einfach an die Collision-Normale erhalten wollen, welche aktuell mit dem bestehenden Interface des collision Signals nicht einfach zu errechnen ist. Hierfür haben wir das `KinematicCollision2D` CollisionObject im Move Behavior abgefangen und an das Collision Behavior weitergeleitet. Dies verfügt über die Methoden `get_collider()` und `get_normal()`. Anschließend können wir dann einfach mit einer Connection von dem CollisionBehavior `set_velocity()` aufrufen und mit der `bounce()` Methode und der Normalen die Reflexion umsetzen.

## Änderungsideen für nächste Woche

Folgende Dinge könnte man in der nächsten Woche angehen:

- Step Einstellungsmöglichkeit für das Value Behavior
- Collision-Normale zum Signal-Interface des Collision Behaviors hinzufügen
- Spawner:
  - Spawner in Spawnern fixen
  - Spawn-Radius statt relativer Kindposition
  - Spawn-Anzahl
  - spawn_at für absolute global_position unabhängig von Spawner-Position
- neues Code Behavior: Speicher für arbiträren Code welcher über Connections gecallt werden kann (mit z.B. Parametern)
- Renaming der Parameternamen in den Connection-Windows
- Neues Mausevent `mouse_up`, welches die Dauer des Tastendrucks mit übergibt.
