#!/bin/bash

# Variables
VM_NAME="kn1lab"
PID_FILE="pidfile.txt"

####################################################################################################
# OS Detection and Path Setting

if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin" ]]; then
    OS_TYPE="Windows"
    VBOX_MANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="Mac"
    VBOX_MANAGE="/usr/local/bin/VBoxManage"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
    VBOX_MANAGE=$(command -v VBoxManage)
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

####################################################################################################
# Termination Logic

# 1. Check if pidfile.txt exists
if [ ! -f "$PID_FILE" ]; then
  echo "Fehler: $PID_FILE nicht gefunden! Die VM scheint nicht zu laufen."
  exit 1
fi

# 2. Read PID
PID=$(cat "$PID_FILE")

if [ -z "$PID" ]; then
  echo "Fehler: Keine Prozessnummer in $PID_FILE gefunden!"
  rm "$PID_FILE"
  exit 1
fi

# 3. Stop via VBoxManage (if applicable) for a graceful shutdown
# This releases the lock properly on Windows/Intel Mac/Linux
if [[ -f "$VBOX_MANAGE" ]]; then
    echo "Sende Poweroff-Befehl an VirtualBox VM: $VM_NAME..."
    "$VBOX_MANAGE" controlvm "$VM_NAME" poweroff 2>/dev/null
fi

# 4. Kill the process (Standard for QEMU or if VBox hangs)
if ps -p "$PID" > /dev/null; then
    echo "Beende Prozess $PID..."
    kill "$PID" 2>/dev/null
    sleep 1
    # Check if still running, then force
    if ps -p "$PID" > /dev/null; then
        echo "Prozess reagiert nicht, erzwinge Beenden (kill -9)..."
        kill -9 "$PID" 2>/dev/null
    fi
fi

# 5. Cleanup
rm -f "$PID_FILE"
# QEMU also creates a pidfile.txt via the -pidfile flag; we ensure it's gone.
[ -f pidfile.txt ] && rm pidfile.txt

echo "VM '$VM_NAME' wurde erfolgreich beendet."