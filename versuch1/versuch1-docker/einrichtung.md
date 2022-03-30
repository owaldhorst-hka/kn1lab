# Einrichtung der Laborumgebung unter Nutzung von Docker
Hier wird Ihnen die Einrichtung der Laborumgebung beschrieben, falls Sie statt der virtuellen Maschine einen Docker Container
verwenden möchten. Dies bietet sich an, falls Sie die Aufgabenstellung an einem Pool-Rechner lösen möchten.

## Installation Docker / Docker Compose

Prüfen Sie ob auf ihrem Rechner Docker installiert ist und installieren Sie es bei Bedarf
```bash
docker --version # Prüfe ob Docker schon installiert ist
# Docker version 20.10.7, build 20.10.7-0ubuntu5~20.04.2
sudo apt install docker.io # Installiere Docker bei Bedarf
```

Installieren Sie Docker Compose
```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Make its Binary executable
sudo chmod +x /usr/local/bin/docker-compose
# Show version if installed correctly
docker-compose --version
# docker-compose version 1.29.2, build 5becea4c
```

## Konfiguration des Mail-Servers

Um den Mail-Server korrekt nutzen zu können, müssen Sie vor dessen Start noch dessen Konfiguration anpassen.
Öffnen dafür zuerst die Datei `docker-compose.yml` und tragen Sie in Zeile 7 den Hostname ihres Rechners ein.
Den Hostname erhalten sie z.B. mit diesem Befehl
```bash
hostname
```

## Erstmaliger Start

Um den Mail-Server zu starten und zu stoppen, können Sie folgende Befehle ausführen.
```bash
sudo docker-compose up -d # Start the Mail-Server
sudo docker-compose down # Stop the Mail-Server
```
Bei dem erstmaligen Start wird für Sie ein neuer Ordner `docker-data` angelegt werden, in dem sich unter anderem die Verzeichnisstruktur
MailDir befindet, und der Server wird in einen Fehlerzustand übergehen, da noch keine Benutzer angelegt wurden.
Sobald `/versuch1/versuch1-docker/docker-data` angelegt wurde, müssen Sie den Mail-Server noch einmal stoppen und mit dem Anlegen von Benutzern fortfahren.

## Anlegen von Benutzern
Um Benutzer anzulegen, steht ihnen das Script `/versuch1/versuch1-docker/setup.sh` zur Verfügung welches ihnen folgende
Befehle anbietet.
```bash
# Lege Benutzer an
sudo ./setup.sh email add <my-username@my-hostname> <my-password>
# Bsp. : sudo ./setup.sh email add oliver.waldhorst@kn1lab h-ka2022
# Lösche Benutzer
sudo ./setup.sh email del <my-username@my-hostname>
# Bsp. : sudo ./setup.sh email del oliver.waldhorst@kn1lab
```
Legen Sie zwei Benutzer an, die sich später E-Mails senden. Den Namen und das Passwort können Sie frei wählen, bitte denken Sie
aber daran, nach dem `@` ihren Hostname zu verwenden, den Sie während der Konfiguration schon herausgefunden haben.

## Letzt Schritte
Nachdem Sie zwei Benutzer angelegt haben, sollten Sie in `/versuch1/versuch1-docker/docker-data/dms/mail-data/<my-hostname>`
zwei Ordner sehen, die den Namen ihrer Benutzer entsprechen. In diesen Ordnern finden Sie später die E-Mails der Benutzer innerhalb
der schon vorgestellten Unterordner `cur`, `tmp` und `new` der MailDir Struktur.

Sie können nun den Mail-Server starten und mit der Lösung der Aufgaben fortfahren. Bitte denken Sie daran, diesen nachdem Sie fertig sind
wieder zu stoppen!