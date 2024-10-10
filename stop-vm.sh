#!/bin/bash

# Prüfen, ob die Datei pidfile.txt existiert
if [ ! -f pidfile.txt ]; then
  echo "pidfile.txt nicht gefunden!"
  exit 1
fi

# Lesen der Prozessnummer aus der Datei
PID=$(cat pidfile.txt)

# Prüfen, ob eine PID vorhanden ist
if [ -z "$PID" ]; then
  echo "Keine Prozessnummer in pidfile.txt gefunden!"
  exit 1
fi

# Beenden des Prozesses mit der angegebenen PID
kill $PID

# Überprüfen, ob der kill-Befehl erfolgreich war
if [ $? -eq 0 ]; then
  echo "Prozess $PID wurde erfolgreich beendet."
else
  echo "Fehler beim Beenden des Prozesses $PID."
fi