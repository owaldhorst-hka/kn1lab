# Versuch 1 - Anwendungsschicht

## Anmeldeinformationen und MailDir-Ordner

Benutzername: `labrat`<br>
Passwort: `kn1lab`<br>
MailDir-Ordner: `/home/labrat/Maildir`


Für diese Aufgabe können Sie das Verzeichnis `/home/labrat/kn1lab` in Visual Studio Code öffnen. Sie müssen dann aber noch das Verzeichnis `/home/labrat/Maildir` mit  der Option `Add Folder to Workspace/Ordner zu Arbeitsbereich hinzufügen` zu Ihrem aktuellen Verzeichnis hinzufügen.

## Aufgabe 1

Öffnen Sie die unter `versuch1/beispiel-nachricht.eml` abgelegte Beispiel-Nachricht mit einem Texteditor und erklären Sie grob den Aufbau der Nachricht, sowie die Aufgaben der einzelnen Bestandteile.

## Aufgabe 2

Die zweite Aufgabe umfasst das Senden einer E-Mail mit Hilfe der Java Mail API. Die Dokumentation dazu finden sie auf der Oracle Website unter:

<https://docs.oracle.com/javaee/7/api/javax/mail/package-summary.html>

<https://docs.oracle.com/cd/E26576_01/doc.312/e24930/javamail.htm#GSDVG00079>

Die Vorlage für diese Aufgabe finden Sie in Visual Studio Code unter `/kn1lab/versuch1/src/Send_Mail.java`.

Der Mail-Server läuft auf `localhost`, d.h. die E-Mail-Adressen für Sender und Empfänger müssen auf `@localhost` enden. Da es auf dem Rechner (normalerweise) nur den Benutzer `labrat` gibt, sollten Sie die Nachricht an `labrat@localhost` senden. Um später erfolgreich eine Sitzung aufzubauen, benötigen Sie nur den Name des Hosts. Die E-Mail dürfen Sie direkt über den Code erzeugen.

Um zu kontrollieren, ob die E-Mail erfolgreich versendet wurde, kann im Ordner `/home/labrat/Maildir` im Unterordner `new` nachgeschaut werden. 

## Aufgabe 3

Die dritte Aufgabe dreht sich darum, alle versendeten E-Mails aus Aufgabe 2 abzurufen. Hierfür ist es völlig ausreichend sie in der Konsole auszugeben. In der Ausgabe sollte enthalten sein:

* Eine Nummerierung die angibt um die wievielte ausgegebene Mail es sich handelt
* Absender der E-Mail
* Der Betreff der E-Mail
* Das Versanddatum der E-Mail
* Der Inhalt der E-Mail

Die Vorlage für diese Aufgabe finden Sie in Visual Studio Code unter `versuch1/src/Receive_Mail.java`.

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
