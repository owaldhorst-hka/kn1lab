# Labor Kommunikationsnetze 1

## Aufsetzen der Umgebung
* Sie benötigen zur Bearbeitung [Visual Studio Code (VS Code)](https://code.visualstudio.com) mit der Erweiterung [Remote SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh). 
* Nachdem Sie die IDE mit der entsprechenden Erweiterung eingerichtet haben, benötigen Sie noch das Programm [Virtualbox](https://www.virtualbox.org/wiki/Downloads), wenn Sie Windows verwenden, benötigen Sie außerdem das Programm [CdrTools](https://sourceforge.net/projects/cdrtoolswin/), welches Sie ebenfalls vor dem Aufsetzen der Umgebung installieren müssen. Außerdem benötigen Sie die in diesem Repo oder dem Ilias-Ordner `Setup` befindliche Datei `kn1lab-install.sh`.
* In diese Datei müssen Sie unter `ssh_authorized_keys` Ihren öffentlichen SSH-Schlüssel angeben. Dabei müssen Sie die vorhandenen Zeichen (`< und >`) löschen, den davor befindlichen Strich aber stehen lassen. 
* Sollten Sie SSH noch nie verwendet haben, so können Sie unter Linux und Mac ein Schlüsselpaar mit dem im Repo enthaltenen Skript `/versuch4/scripts/keygen.sh` erstellen. Auf einem Mac können Sie das Skript mit "sh keygen.sh" ausführen. 
* In Windows können Sie den Befehl `ssh-keygen` in der Eingabeaufforderung verwenden. 
* Den benötigten Key finden Sie unter Linux und Mac im Unterverzeichnis `.ssh` in Ihrem Wurzelverzeichnis in der Datei `id_rsa.pub`, deren Inhalt Sie vollständig kopieren müssen. 
* Unter Windows finden Sie den Ordner `.ssh` im Verzeichnis `C:/Users/<User>/.ssh`, dabei müssen Sie die Datei `id_rsa.pub` mit einem Texteditor statt Microsoft Publisher öffnen. Mit dem folgenden Befehl können Sie darufhin in einem Terminal (unter Windows am besten git Bash verwenden) eine Virtuelle Ubuntu Maschine aufsetzen: 

```bash
./kn1lab-install.sh
```

* Daraufhin können Sie sich mit der Maschine über ssh verbinden, indem Sie diese als Host in Visual Studio Code anlegen. Dafür können Sie über den blauen Remote-Window-Knopf im linken unteren Eck mit der Option `Connect to Host` und der darauffolgenden Option `Add new SSH Host` unter Angabe von `ssh labrat@localhost` die Einrichtung durchführen.
* Sollten Sie beim Aufbau der ssh-Verbindung einen Fehler bekommen, bzw. nach einem Passwort gefragt werden, müssen Sie im Skript `kn1lab-install.sh` den Port für das Host-System ändern (z.B. auf Port 2222). Daraufhin müssen Sie noch die Datei `cloud-init.iso` löschen, damit die Änderungen beim Erstellen der virtuellen Maschine angewandt werden. Daraufhin können Sie sich mit dem Befehl `ssh -p 2222 labrat@localhost` mit der Maschine verbinden.
* Nach der Einrichtung können Sie sich mit der Maschine über deren Auswahl in der Option `Connect to Host` verbinden.
* Sobald Sie mit der Maschine verbunden sind, müssen Sie durch die Option `Open Folder` das Home-Verzeichnis Ihres Nutzers (`labrat`) öffnen und das Skript `setup.sh` im Unterordner `kn1lab` ausführen.
* Dafür müssen Sie ein Terminal öffnen, mit dem Befehl `cd kn1lab` in den Unterordner wechseln und das Skript mit `./setup.sh` ausführen.
* Dieses Skript setzt Ihre Umgebung final auf und installiert auch alle benötigten Erweiterungen für Visual Studio Code, sodass Sie danach alle Versuche bearbeiten können.


## Aufgabenstellungen

### [Versuch 1 - Anwendungsschicht](versuch1/aufgabenstellung.md)
### [Versuch 2 - Transportschicht](versuch2/aufgabenstellung.md)
### [Versuch 3 - Vermittlungsschicht](versuch3/aufgabenstellung.md)
### [Versuch 4 - Leistungsmessung](versuch4/aufgabenstellung.md)
