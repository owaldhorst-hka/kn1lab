# Versuch 1 - Anwendungsschicht

Zur Lösung dieses Versuchs steht ihnen neben einer virtuelle Maschine seit dem SS22 auch ein Docker-Container 
zur Verfügung.
Wir empfehlen ihnen dessen Nutzung, insofern Sie die Aufgaben Vor-Ort an einem Pool-Rechner lösen möchten.
Innerhalb des Docker-Containers befindet sich ein Mail-Server der unter anderem den notwendigen Mail Transfer Agent 
Postfix und Mail Delivery Agent Dovecot enthält.

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
Öffnen dafür zuerst die Datei "docker-compose.yml" und tragen Sie in Zeile 7 den Hostname ihres Rechners ein.
Den Hostname erhalten sie z.B. mit diesem Befehl
```bash
hostname
```

## Starten des Mail-Servers

Um den Mail-Server zu starten, führen Sie folgenden Befehl aus.
```bash
sudo docker-compose up
```

Um den Mail-Server zu stoppen, führen Sie folgenden Befehl aus.
```bash
sudo docker-compose down
```


## Anmeldeinformationen und MailDir-Ordner

Benutzername: `labrat`<br>
Passwort: `kn1lab`<br>
MailDir-Ordner: `/home/labrat/Maildir`

## Aufgabe 1

Öffnen Sie die unter `kn1lab/versuch1/beispiel-nachricht.eml` abgelegte Beispiel-Nachricht mit einem Texteditor und erklären Sie grob den Aufbau der Nachricht, sowie die Aufgaben der einzelnen Bestandteile.

## Aufgabe 2

Die zweite Aufgabe umfasst das Senden einer E-Mail mit Hilfe der Java Mail API. Die Dokumentation dazu finden sie auf der Oracle Website unter:

<https://docs.oracle.com/javaee/7/api/javax/mail/package-summary.html>

<https://docs.oracle.com/cd/E26576_01/doc.312/e24930/javamail.htm#GSDVG00079>

Für diese Aufgabe können Sie `kn1lab/versuch1` in IntelliJ öffnen. 
Die Vorlage für diese Aufgabe finden Sie in IntelliJ unter `versuch1/src/Send_Mail.java`.

Der Mail-Server läuft auf `localhost`, d.h. die E-Mail-Adressen für Sender und Empfänger müssen auf `@localhost` enden. Da es auf dem Rechner (normalerweise) nur den Benutzer `labrat` gibt, sollten Sie die Nachricht an `labrat@localhost` senden. Um später erfolgreich eine Sitzung aufzubauen, benötigen Sie nur den Name des Hosts. Die E-Mail dürfen Sie direkt über den Code erzeugen.

Um zu kontrollieren, ob die E-Mail erfolgreich versendet wurde, kann im Ordner `/home/user/Maildir` im Unterordner `new` nachgeschaut werden. 

## Aufgabe 3

Die dritte Aufgabe dreht sich darum, alle versendeten E-Mails aus Aufgabe 2 abzurufen. Hierfür ist es völlig ausreichend sie in der Konsole auszugeben. In der Ausgabe sollte enthalten sein:

* Eine Nummerierung die angibt um die wievielte ausgegebene Mail es sich handelt
* Absender der E-Mail
* Der Betreff der E-Mail
* Das Versanddatum der E-Mail
* Der Inhalt der E-Mail

Die Vorlage für diese Aufgabe finden Sie in IntelliJ unter `versuch1/src/Receive_Mail.java`.

Um erfolgreich eine Sitzung aufzubauen, werden der Name des Hosts, dessen Store-Type und die Anmeldeinformationen (siehe ganz oben in diesem Dokument) benötigt.

Zur Erinnerung: es handelt sich um einen POP3-Server mit unverschlüsselter Verbindung.

Bei Problemen können die folgenden Parameter gesetzt werden:

```java
properties.put("mail.debug", "true");
properties.put("mail.debug.quote", "true");
session.setDebug(true);
```

Hilfreich ist auch:

```bash
tail -f /var/log/mail.log
```
