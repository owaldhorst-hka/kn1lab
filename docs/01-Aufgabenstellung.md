# Versuch 1 - Anwendungsschicht

## Anmeldeinformationen & mehr

Benutzername: `user`<br>
Passwort: `password`<br>
Pfad zum MailDir Ordner: `/home/user/Maildir`

## Aufgabe 1

Die erste Aufgabe umfasst das Senden einer E-Mail mit Hilfe der Java Mail API. Die Dokumentation dazu finden sie auf der Oracle Website unter:

https://eclipse-ee4j.github.io/javamail/docs/api/javax/mail/package-summary.html

Die E-Mail-Adressen für Sender und Empfänger sind frei wählbar, müssen aber auf `@localhost` enden. Um später erfolgreich eine Sitzung aufzubauen, werden Benutzername und Passwort des Kontos benötigt. Weiterhin sollte überlegt werden welcher SMTP Host zu verwenden ist und auf welchem Port dieser anzusprechen ist. 

Mit den genannten Informationen kann eine Sitzung aufgebaut werden. Die E-Mail darf direkt über den Code erzeugt werden.

Um zu kontrollieren, ob die E-Mail erfolgreich versendet wurde kann im Ordner `home/user/Maildir` im Unterordner `new` nachgeschaut werden. 

## Aufgabe 2

Die zweite Aufgabe dreht sich darum, alle versendeten E-Mails aus Aufgabe 1 abzurufen.  Hierfür ist es völlig ausreichend sie in der Konsole auszugeben. In der Ausgabe sollte enthalten sein:

* Eine Nummerierung die angibt um die wievielte ausgegebene Mail es sich handelt
* Absender der E-Mail
* Der Betreff der E-Mail
* Das Versanddatum der E-Mail
* Der Inhalt der E-Mail

Um erfolgreich eine Sitzung aufzubauen werden der Name des Hosts, dessen Store Type, der entsprechende Port, auf dem die Kommunikation läuft, und die Kontoinformationen benötigt. 

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