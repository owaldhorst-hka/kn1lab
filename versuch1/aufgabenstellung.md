# Versuch 1 - Anwendungsschicht

## Anmeldeinformationen und MailDir-Ordner

Benutzername: `user`<br>
Passwort: `password`<br>
MailDir-Ordner: `/home/user/Maildir`

## Aufgabe 1

Öffnen Sie die unter `~/Schreibtisch/kn1lab/versuch1/beispiel-nachricht.eml` abgelegte Beispiel-Nachricht mit einem Texteditor und erklären Sie grob den Aufbau der Nachricht, sowie die Aufgaben der einzelnen Bestandteile.

## Aufgabe 2

Die zweite Aufgabe umfasst das Senden einer E-Mail mit Hilfe der Java Mail API. Die Dokumentation dazu finden sie auf der Oracle Website unter:

https://eclipse-ee4j.github.io/javamail/docs/api/javax/mail/package-summary.html

Die Vorlage für diese Aufgabe finden Sie in Eclipse unter `versuch1/src/(default package)/Send_Mail.java`.

Der Mail-Server läuft auf `localhost`, d.h. die E-Mail-Adressen für Sender und Empfänger müssen auf `@localhost` enden, sind aber sonst frei wählbar. Um später erfolgreich eine Sitzung aufzubauen, benötigen Sie nur den Name des Hosts. Die E-Mail dürfen Sie direkt über den Code erzeugen.

Um zu kontrollieren, ob die E-Mail erfolgreich versendet wurde kann im Ordner `home/user/Maildir` im Unterordner `new` nachgeschaut werden. 

## Aufgabe 3

Die dritte Aufgabe dreht sich darum, alle versendeten E-Mails aus Aufgabe 2 abzurufen. Hierfür ist es völlig ausreichend sie in der Konsole auszugeben. In der Ausgabe sollte enthalten sein:

* Eine Nummerierung die angibt um die wievielte ausgegebene Mail es sich handelt
* Absender der E-Mail
* Der Betreff der E-Mail
* Das Versanddatum der E-Mail
* Der Inhalt der E-Mail

Die Vorlage für diese Aufgabe finden Sie in Eclipse unter `versuch1/src/(default package)/Receive_Mail.java`.

Um erfolgreich eine Sitzung aufzubauen, werden der Name des Hosts, dessen Store-Type und die Anmeldeinformationen benötigt.<br>
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
