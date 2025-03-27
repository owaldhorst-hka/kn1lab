# Labor Kommunikationsnetze 1

## Aufsetzen der Umgebung
* Sie benötigen zur Bearbeitung [Visual Studio Code (VS Code)](https://code.visualstudio.com) mit der Erweiterung [Remote SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh). 
* Nachdem Sie die IDE mit der entsprechenden Erweiterung eingerichtet haben, benötigen Sie noch folgendes:
  * Windows: Die Programme [Virtualbox](https://www.virtualbox.org/wiki/Downloads) und [CdrTools](https://sourceforge.net/projects/cdrtoolswin/).
  * Linux: Das Programm [Virtualbox](https://www.virtualbox.org/wiki/Downloads) und das Kommandozeilenprogramm `genisoimage`, welches in den meisten Ubuntu Varianten bereits installiert ist.
  * Mac(Silicon): Den Paket-Manager [Homebrew](https://brew.sh/), um damit die Pakete `qemu` und `cdrtools` zu instalieren.
  * Mac(Intel): Den Paket-Manager [Homebrew](https://brew.sh/), um damit die Pakete `virtualbox` und `cdrtools` zu instalieren.
* Unter Windows müssen Sie Virtualbox noch zur Umgebungsvariable `Path` hinzufügen. Dafür müssen Sie den Pfad zum Verzeichnis, in das Sie Virtualbox installiert haben (meistens C:/Programme/Oracle/Virtualbox oder C:/Program Files/Oracle/Virtualbox) zu dieser Variable hinzufügen. Eine [Anleitung](https://www.windows-faq.de/2023/12/24/windows-path-variable/), wie sie dies umsetzen können gibt es von Windows FAQ. `Wichtig!` Nach dem Setzen der Umgebungsvariablen müssen Sie Ihren Computer neu starten, damit Sie das benötigte Skript ausführen können.
* Außerdem benötigen Sie die in diesem Repo befindliche Datei `kn1lab-install.sh`.
* Führen Sie unter Linux und Mac noch den Befehl `chmod +x kn1lab-install.sh` im entsprechenden Verzeichnis aus, um das Skript ausführbar zu machen.
* Mit dem folgenden Befehl können Sie darufhin in einem Terminal (unter Windows am besten git Bash verwenden) eine Virtuelle Ubuntu Maschine aufsetzen `(unter Windows müssen Sie für die Ausführung des Skripts Git Bash verwenden, da das Skript in Powershell oder der Eingabeaufforderung nicht ausgeführt werden kann)`: 

```bash
./kn1lab-install.sh
```

* Anschließend können Sie sich mit der Maschine über ssh verbinden, indem Sie diese als Host in Visual Studio Code anlegen. Dafür können Sie über den blauen Remote-Window-Knopf im linken unteren Eck mit der Option `Connect to Host` und der darauffolgenden Option `Add new SSH Host` unter Angabe von `ssh -p 2222 labrat@localhost` die Einrichtung durchführen.
* Nach der Einrichtung können Sie sich mit der Maschine über deren Auswahl in der Option `Connect to Host` verbinden.
* Sobald Sie mit der Maschine verbunden sind, müssen Sie durch die Option `Open Folder` das Home-Verzeichnis Ihres Nutzers (`labrat`) öffnen und das Skript `setup.sh` im Unterordner `kn1lab` ausführen.
* Dafür müssen Sie ein Terminal öffnen, mit dem Befehl `cd kn1lab` in den Unterordner wechseln und das Skript mit `./setup.sh` ausführen.
* Dieses Skript setzt Ihre Umgebung final auf und installiert auch alle benötigten Erweiterungen für Visual Studio Code, sodass Sie danach alle Versuche bearbeiten können.


## Aufgabenstellungen

### [Versuch 1 - Anwendungsschicht](versuch1/aufgabenstellung.md)
### [Versuch 2 - Transportschicht](versuch2/aufgabenstellung.md)
### [Versuch 3 - Vermittlungsschicht](versuch3/aufgabenstellung.md)
### [Versuch 4 - Leistungsmessung](versuch4/aufgabenstellung.md)
