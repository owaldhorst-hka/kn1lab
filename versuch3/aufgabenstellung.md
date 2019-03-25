# Versuch 3 - Vermittlungsschicht

## Aufgabe 1

Wie viele erfolgreiche Start-Ups haben auch wir eine kleine Garage gemietet, in der wir die Entwicklung an unserer streng geheimen neuen Idee fortführen wollen. Unser Team besteht im Moment aus Lukas, Lisa, Ela, Ben und Elias.

Leider ist unser alter Netzwerkadministrator unerwartet ausgeschieden, deswegen sind wir sehr froh, dass Sie uns unterstützen möchten! Wir haben für das Netzwerk leider keine Zeit...

Jedes Teammitglied soll seinen eigenen Arbeitsplatz mit PC erhalten. Ein Network Attached Storage (NAS) als Dateiserver, einen Router und einen Switch haben wir bereits angeschafft. Unser alter Administrator hat die Geräte notdürftig verkabelt und konfiguriert – wir wissen nur leider nicht wie!

1. Bitte öffnen Sie das Mininet-Skript unter `~/Schreibtisch/kn1lab/versuch3/scripts/mininet-1.py` mit einem Texteditor und rekonstruieren (zeichnen) Sie die Netzwerkumgebung mit den Verbindungen!

1. Bitte bezeichnen Sie zusätzlich in ihrer Zeichnung die Netzwerkschnittstellen mit den richtigen IP-Adressen. Vermerken Sie auch die Routing-Tabellen-Einträge, die Sie anzeigen können mit `<hostname> route`.

1. Starten Sie nun die Mininet Topologie mit `sudo python ~/Schreibtisch/kn1lab/versuch3/scripts/mininet-1.py`. Testen Sie dann die Verbindung der PCs untereinander mit Hilfe des Tools ping, indem sie in der Mininet-Konsole den Befehl `<hostname-quelle> ping <hostname-ziel>` verwenden. Können sich alle Rechner gegenseitig erreichen?

1. Ben hat festgestellt, dass er den NAS nicht erreichen kann. Prüfen Sie das nach und notieren Sie den Fehlertext.

1. Wir haben festgestellt, dass wir den NAS leider von keinem der PCs aus erreichen können. Da scheint etwas mit den Routing-Tabellen nicht zu stimmen, beheben Sie den Fehler bitte schnellstmöglich!<br>
Tipp: Sehen Sie sich die IP-Adressen in den Tabellen genau an! Der Befehl `<hostname> traceroute <ziel-ip>` könnte Ihnen ebenfalls helfen.

## Aufgabe 2

Wir haben ein Büro in einem Gründerhaus bekommen! Es ist zwar nicht so groß, dass wir alle dort Platz haben können, aber es schafft wenigstens Platz für neue Mitarbeiter. Ihr Arbeitsplatz wird in dem neuen Büro sein, suchen Sie sich einen schönen Platz aus.

Von unserem neuen Büro gibt es einen Switch, der die PCs verbindet, sowie einen neuen Router. Das NAS in der Garage soll von den neuen PCs erreichbar sein, aber nicht die PCs der alten Teammitglieder in der Garage! Zur Vereinfachung gehen wir davon aus, dass die beiden Router "Garage" (`r1`) und "Buero" (`r2`) eine direkte Verbindung haben.

Hier ist die aktualisierte Liste, ich habe sie für Sie angepasst. Schauen Sie sich die **neuen Geräte und deren IPs** genau an.

| Gerät             | Typ        | IP                                        |
|-------------------|------------|-------------------------------------------|
| Garage (`r1`)     | Router     | 10.0.0.1/24, 10.0.3.1/24, **10.0.2.1/24** |
| **Buero (`r2`)**  | **Router** | **10.0.2.2/24, 10.0.4.1/24**              |
| sw1               | Switch     | **Keine IP**                              |
| **sw2**           | **Switch** | **Keine IP**                              |
| NAS               | Host       | 10.0.3.2                                  |
| Ela               | PC         | 10.0.0.2                                  |
| Lisa              | PC         | 10.0.0.3                                  |
| Ben               | PC         | 10.0.0.4                                  |
| Lukas             | PC         | 10.0.0.5                                  |
| Elias             | PC         | 10.0.0.6                                  |
| **Burak**         | **PC**     | **10.0.4.2**                              |

1. Für das neue Büro stehen uns `/24` IP-Adressen zur Verfügung. Wie viele Geräte können hier maximal genutzt werden?

1. Fügen Sie die neuen Geräte in die Zeichnung ein. Realisieren Sie die neue Topologie mit IP-Adressen/-Subnetzen und Routen im Mininet-Skript `mininet-2.py`. Hinweis zu den Routen: Orientieren Sie sich an dem Aufbau von Router 1! Einen Routing-Eintrag für ein Subnetz erstellen Sie mit dem Befehl `net['r1'].cmd("ip route add <subnetz> via <next-hop-ip>")`.