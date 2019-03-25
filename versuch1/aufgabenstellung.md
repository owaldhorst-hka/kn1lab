# Versuch 1 - Anwendungsschicht

## Anmeldeinformationen & mehr

Benutzername: `user`<br>
Passwort: `password`<br>
Pfad zum MailDir Ordner: `/home/user/Maildir`

## Aufgabe 1

Die erste Aufgabe umfasst das Senden einer E-Mail mit Hilfe der Java Mail API. Die Dokumentation dazu finden sie auf der Oracle Website unter:

https://eclipse-ee4j.github.io/javamail/docs/api/javax/mail/package-summary.html

Die Vorlage für diese Aufgabe finden Sie in Eclipse unter `versuch1/src/(default package)/Send_Mail.java`.

Der SMTP-Server läuft auf `localhost`, d.h. die E-Mail-Adressen für Sender und Empfänger müssen auf `@localhost` enden, sind aber sonst frei wählbar. Um später erfolgreich eine Sitzung aufzubauen, werden der Name des Hosts und die Anmeldeinformationen benötigt.

Mit den genannten Informationen kann eine Sitzung aufgebaut werden. Die E-Mail darf direkt über den Code erzeugt werden.

Um zu kontrollieren, ob die E-Mail erfolgreich versendet wurde kann im Ordner `home/user/Maildir` im Unterordner `new` nachgeschaut werden. 

## Aufgabe 2

Die zweite Aufgabe dreht sich darum, alle versendeten E-Mails aus Aufgabe 1 abzurufen.  Hierfür ist es völlig ausreichend sie in der Konsole auszugeben. In der Ausgabe sollte enthalten sein:

* Eine Nummerierung die angibt um die wievielte ausgegebene Mail es sich handelt
* Absender der E-Mail
* Der Betreff der E-Mail
* Das Versanddatum der E-Mail
* Der Inhalt der E-Mail

Die Vorlage für diese Aufgabe finden Sie in Eclipse unter `versuch1/src/(default package)/Receive_Mail.java`.

Um erfolgreich eine Sitzung aufzubauen, werden der Name des Hosts, dessen Store Type und die Anmeldeinformationen benötigt. 

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