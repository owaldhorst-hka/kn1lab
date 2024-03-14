# Labor Kommunikationsnetze 1

## Disclaimer zur Bearbeitung des Labors mit Multipass
Die Bearbeitung der Aufgaben ist an mehreren Stellen anders als bei der vorherigen Virtualbox-Lösung. Die Aufgabenstellungen sind dementsprechend angepasst und bei wichtigen Änderungen findet sich am Anfang der Datei ein Disclaimer, was es dort zu beachten gibt.

### Aufsetzen der Umgebung
Sie benötigen zur Bearbeitung [Visual Studio Code (VS Code)](https://code.visualstudio.com) mit der Erweiterung [Remote SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh). Nachdem Sie die IDE mit der entsprechenden Erweiterung eingerichtet haben, benötigen Sie noch das Programm [Multipass](https://multipass.run/) und die im Repo befindliche Datei `cloud-config.yaml`. In diese Datei müssen Sie unter `ssh_authorized_keys` Ihren öffentlichen SSH-Schlüssel angeben. Sollten Sie SSH noch nie verwendet haben, so können Sie ein Schlüsselpaar mit dem im Repo enthaltenen Skript `/versuch4/scripts/keygen.sh` erstellen. Diesen finden Sie unter Linux und Mac im Unterverzeichnis `.ssh` in Ihrem Wurzelverzeichnis in der Datei `id_rsa.pub`, deren Inhalt Sie vollständig kopieren müssen. Unter Windows finden Sie den Ordner `.ssh` im Verzeichnis `C:/Users/<User>/.ssh`, dabei müssen Sie die Datei `id_rsa.pub` mit einem Texteditor statt Microsoft Publisher öffnen. Mit dem folgenden Befehl können Sie darufhin in einem Terminal eine Virtuelle Ubuntu Maschine aufsetzen: 

```bash
multipass launch jammy --cpus 2 --disk 10G --memory 4G --cloud-init cloud-config.yaml
```

Mit dem Befehl `multipass info` Können Sie sich die IP-Adresse ihrer virtuellen Maschine ausgeben lassen. Mit dieser IP können Sie sich mit der Maschine über ssh verbinden, indem Sie diese als Host in Visual Studio Code anlegen. Dafür können Sie über den blauen Remote-Window-Knopf im linken unteren Eck mit der Option `Connect to Host` und der darauffolgenden Option `Add new SSH Host` unter Angabe von `ssh labrat@<IPAdresse>` die Einrichtung durchführen. Nach der Einrichtung können Sie sich mit der Maschine über deren Auswahl in der Option `Connect to Host` verbinden. Sobald Sie mit der Maschine verbunden sind, müssen Sie durch die Option `Open Folder` das Home-Verzeichnis Ihres Nutzers (`labrat`) öffnen und das Skript `setup.sh` im Unterordner `kn1lab` ausführen. Dafür müssen Sie ein Terminal öffnen, mit dem Befehl `cd kn1lab` in den Unterordner wechseln und das Skript mit `./setup.sh` ausführen. Dieses Skript setzt Ihre Umgebung final auf und installiert auch alle benötigten Erweiterungen für Visual Studio Code, sodass Sie danach alle Versuche bearbeiten können.

### Multipass mit in Windows
Multipass kann in Windows mit Hyper-V oder Virtualbox verwendet werden. Bei der Home-Version von Windows ist Hyper-V nicht verfügbar. Zur Verwendung von [Virtualbox](https://www.virtualbox.org/wiki/Downloads) müssen Sie es noch installieren.
Sollte beim Aufsetzen der virtuellen Maschine unter Windows der folgende Fehler auftauchen: `launch failed: Multipass support for Hyper-V requires Windows 10 or newer`, dann können Sie die Virtualisierung auf Virtualbox mit dem folgenden Befehl in einer Powershell mit Admin-Rechten umstellen:
```bash
multipass set local.driver=virtualbox
```
Nach dieser Änderung müssen Sie Ihren Computer neu starten.

Bei der Verwendung von Virtualbox müssen Sie jedoch auch den Befehl zum Starten der Maschine ändern. SIe benötigen dafür den Namen ihres Netzwerks. Diesen können Sie mit `multipass networks` auslesen und müssen diesen dann in den untweren Befehl einsetzen. Ohne diese Änderung des Befehls ist SSH in Ihrer virtuellen Maschine nicht verfügbar.
```bash
multipass launch jammy --cpus 2 --disk 10G --memory 4G --cloud-init cloud-config.yaml --network name="<Netzwerk-Name>"
```

### Probleme bei der Authentifizierung von Multipass unter Linux/Mac
Nach der Installation von multipass auf einem Linux Rechner kann es sein, dass Sie diesen für multipass authentifizieren müssen. Sollten Sie damit Schwierigkeiten haben, kann dieser [Link](https://multipass.run/docs/authenticating-clients) helfen.

Sollten Sie mit dieser Anleitung mit einem Mac nicht weiterkommen, kann der Workaround aus diesem [GitHub-Issue](https://github.com/canonical/multipass/issues/2549) helfen:

Stop the daemon: `sudo launchctl unload /Library/LaunchDaemons/com.canonical.multipassd.plist`

Delete `/var/root/Library/Application\ Support/multipassd/authenticated-certs/multipass_client_certs.pem`

Copy your user's public cert: `sudo cp ~/Library/Application\ Support/multipass-client-certificate/multipass_cert.pem /var/root/Library/Application\ Support/multipassd/authenticated-certs/multipass_client_certs.pem`

Start the daemon: `sudo launchctl load /Library/LaunchDaemons/com.canonical.multipassd.plist`

## Aufgabenstellungen

### [Versuch 1 - Anwendungsschicht](versuch1/aufgabenstellung.md)
### [Versuch 2 - Transportschicht](versuch2/aufgabenstellung.md)
### [Versuch 3 - Vermittlungsschicht](versuch3/aufgabenstellung.md)
### [Versuch 4 - Leistungsmessung](versuch4/aufgabenstellung.md)
