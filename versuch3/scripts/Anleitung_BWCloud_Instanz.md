# Anleitung zum Einrichten einer Ubuntu-Instanz in der BWCloud

1.	Falls im Ordner .ssh Ihres PCs noch keine SSH-Schlüssel existieren, führen Sie das Skript keygen.sh im Ordner Versuch4 mit dem Befehl `./keygen.sh` im Terminal aus. Der Ordner .ssh liegt in Ihrem Persönlichen Ordner, Sie können durch setzen der Option `verborgene Dateien anzeigen` im Explorer auf den Ordner zugreifen. Falls der Ordner noch gar nicht existiert, müssen Sie diesen erst erstellen.

2.	Melden Sie sich unter der nachfolgenden URL bei der BWCloud an, als Hochschule wählen Sie bitte `Hochschule Karlsruhe`.      https://portal.bw-cloud.org/auth/login/?next=/project/ 


3.	Importieren Sie im Bereich Schlüsselpaare Ihren öffentlichen SSH-Schlüssel. Durch einen Rechtsklick können Sie durch das Setzen der Option `verborgene Dateien anzeigen` den Ordner .ssh anzeigen lassen, in dem Ihr öffentlicher Schlüssel als .pub Datei liegt.

4.	Erstellen Sie als nächstes im Reiter Instanzen eine neue Instanz mit Ubuntu 20.04 als Betriebssystem. Wählen Sie die Variante m1.tiny, eine bessere sollte auch nicht ohne Weiteres verfügbar sein. Weitere Einstellungen müssen Sie für die Instanz nicht vornehmen.


5.	Über die auf der Webseite angezeigte IP-Adresse können Sie sich mit dem Standard Nutzer `ubuntu` und dem folgenden Befehl über ein Terminal mit der gestarteten Instanz verbinden. `ssh ubuntu@<IP-Adresse>`

6.	Kopieren Sie die Skripte `bwcloud.sh` und `keygen.sh` auf ihre Instanz, indem sie die folgenden Befehle in einem Terminal ohne SSH-Verbindung ausführen. Je nachdem wo Sie Ihr Projekt für das Labor auf Ihrem PC abgelegt haben, müssen Sie unter Umständen die Pfade in den Befehlen ändern.
```bash
scp -r ~/kn1lab-master/versuch4/scripts/keygen.sh ubuntu@<IP-Adresse>:/home/ubuntu
scp -r ~/kn1lab-master/versuch4/scripts/bwcloud.sh ubuntu@<IP-Adresse>:/home/ubuntu
```
    

7.	Führen Sie die beiden eben kopierten Skripte in einem Terminal mit einer offenen SSH-Verbindung zu Ihrer Instanz aus. Wie sie ein Skript ausführen, ist in Schritt 1 erklärt. Falls Sie einen `Permission denied` Fehler bekommen, müssen Sie folgenden Befehl im gleichen Terminal ausführen.
```bash
chmod -x bwcloud.sh
```
    Das Ausführen des `bwcloud.sh` Skripts kann etwas länger dauern, da alle nötigen Anwendungen dadurch installiert werden.
