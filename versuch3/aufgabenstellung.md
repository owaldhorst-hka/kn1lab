# Versuch 3 - Vermittlungsschicht

## Generelle Hinweise

* Mit dem Befehl `<knotenname> ifconfig` können Sie sich die Liste aller Netzwerkschnittstellen dieses Netzwerkknotens mit ihren jeweiligen Konfigurationen ausgeben lassen, dies schließt auch die zugewiesene IP-Adresse ein (`inet`).

## Aufgabe 1

Wie viele erfolgreiche Start-Ups haben auch wir eine kleine Garage gemietet, in der wir die Entwicklung an unserer streng geheimen neuen Idee fortführen wollen. Unser Team besteht im Moment aus Lukas, Lisa, Ela, Ben und Elias.

Leider ist unser alter Netzwerkadministrator unerwartet ausgeschieden, deswegen sind wir sehr froh, dass Sie uns unterstützen möchten! Wir haben für das Netzwerk leider keine Zeit...

Jedes Teammitglied soll seinen eigenen Arbeitsplatz mit PC erhalten. Ein Network Attached Storage als Dateiserver (`NAS`), einen Router (`r1`) und einen Switch (`sw1`) haben wir bereits angeschafft. Unser alter Administrator hat die Geräte notdürftig verkabelt und konfiguriert – wir wissen nur leider nicht wie!

1. Bitte öffnen Sie das Mininet-Skript unter `~/kn1lab/versuch3/scripts/topology.py` mit PyCharm und rekonstruieren (zeichnen) Sie die Netzwerkumgebung mit den Verbindungen!

1. Bitte bezeichnen Sie zusätzlich in ihrer Zeichnung die Netzwerkschnittstellen mit den richtigen IP-Adressen. Vermerken Sie auch von den Routing-Tabellen-Einträgen die Attribute `Ziel` und `Router`. Starten Sie dazu die Mininet Topologie mit PyCharm oder mit `sudo python ~/kn1lab/versuch3/scripts/topology.py`. Das benötigte Passwort ist `password`. Anschließend können Sie mit `<knotenname> route` die Routing-Tabellen-Einträge ausgeben lassen. Falls Sie in der Ausgabe unerwartete Rechnernamen (z.B. `_gateway`) statt IP-Adressen sehen und dies nicht wollen, dann geben Sie das Argument `-n` mit (z.B. `host1 route -n`).

1. Testen Sie nun die Verbindung der PCs untereinander mit Hilfe des Tools `ping`, indem sie in der Mininet-Konsole den Befehl `<knotenname-quelle> ping -c 3 <ip-ziel>` verwenden. Dadurch wird das Ziel 3 mal angepingt. Können sich alle Teammitglieder gegenseitig erreichen?

1. Ben hat festgestellt, dass er den `NAS` nicht erreichen kann. Prüfen Sie dies ebenfalls mit `ping` nach und notieren Sie sich die Statistik. Pingen Sie hier das Ziel 5 mal an.

1. Wir haben festgestellt, dass wir den `NAS` leider von keinem der PCs aus erreichen können. Da scheint etwas mit den Routing-Tabellen nicht zu stimmen, beheben Sie den Fehler bitte schnellstmöglich!<br>
Tipp: Sehen Sie sich die IP-Adressen in den Tabellen genau an! Der Befehl `<knotenname-quelle> traceroute -m 5 <ziel-ip>` könnte Ihnen ebenfalls helfen. Die Argumente `-m 5` geben an, dass nach 5 Hops abgebrochen wird. Auch hier gilt, dass Sie das Argument `-n` mitgeben können, um alle Ergebnisse als IP-Adressen anzeigen zu lassen (z.B. `host1 traceroute -n host2`).

## Aufgabe 2

Wir haben ein Büro in einem Gründerhaus bekommen! Es ist zwar nicht so groß, dass wir alle dort Platz haben können, aber es schafft wenigstens Platz für neue Mitarbeiter. Ihr Arbeitsplatz wird in dem neuen Büro sein, suchen Sie sich einen schönen Platz aus. Unsere alten Teammitglieder werden vorerst weiterhin von der Garage aus arbeiten.

In unserem neuen Büro gibt es außer Ihrem PC (`Burak`) noch einen Switch, der die PCs verbindet (`sw2`), sowie einen neuen Router (`r2`). Der Plan ist, dass die PCs aus dem Gründerhaus von den Geräten in der Garage nur den `NAS` erreichen können sollen, die PCs der alten Teammitglieder sollen aber nicht erreichbar sein.

Hier ist die aktualisierte Liste. Schauen Sie sich die neuen Geräte und deren IPs genau an, diese habe ich für Sie **fett markiert**.

| Gerät             | Typ        | IP                                        |
|-------------------|------------|-------------------------------------------|
| r1 (Garage)       | Router     | 10.0.0.1/26, 10.0.1.1/29, **10.0.1.64/31** |
| **r2 (Buero)**    | **Router** | **10.0.2.1/25, 10.0.1.65/31**              |
| sw1               | Switch     | Keine IP                                  |
| **sw2**           | **Switch** | **Keine IP**                              |
| NAS               | Host       | 10.0.1.2                                  |
| Ela               | PC         | 10.0.0.2                                  |
| Lisa              | PC         | 10.0.0.3                                  |
| Ben               | PC         | 10.0.0.4                                  |
| Lukas             | PC         | 10.0.0.5                                  |
| Elias             | PC         | 10.0.0.6                                  |
| **Burak**         | **PC**     | **10.0.2.2**                              |

1. Für das neue Büro stehen uns `/25` IP-Adressen zur Verfügung. Wie viele Geräte können hier maximal genutzt werden?

1. Fügen Sie die neuen Geräte und ihre IP-Adressen in die Zeichnung ein. Erweitern Sie die existierende Topologie in `~/kn1lab/versuch3/scripts/topology.py` mit den neuen Geräten, IP-Adressen, Subnetzen und Routen.

### Hinweise zu Aufgabe 2.2:

* Zur Vereinfachung gehen wir davon aus, dass die beiden Router `r1` (Garage) und `r2` (Buero) eine direkte Verbindung haben. Dies bedeutet auch, dass Sie für `r1` eine weitere Netzwerkschnittstelle hinzufügen müssen. 

* Orientieren Sie sich bei den Routen am Aufbau von Router 1. Einen Routing-Eintrag für ein Subnetz, dessen nächster Hop ein Router ist, erstellen Sie mit dem Aufruf `net['<router>'].cmd('ip route add <subnetz> via <next-hop-ip>')`.

* Wenn Sie Netzwerkknoten per `addLink()` mit einem Router verbinden, dann bestimmt die Reihenfolge dieser Aufrufe mit welcher Netzwerkschnittstelle des Routers die Netzwerkknoten verbunden werden (z.B. erster Aufruf von `addLink(r2, <host>)` = `eth0`, zweiter Aufruf = `eth1`, usw.). Hier kann es hilfreich sein, wenn Sie über `ifconfig` in Erfahrung bringen, welcher Netzwerkschnittstelle welche IP-Adresse zugewiesen ist und Sie dies zusätzlich in Ihrer Zeichnung vermerken.

* Wenn Sie bei einem Befehl als Ziel einen Router angeben wollen, dann sollten Sie anstatt des Hostnamens die IP-Adresse der jeweiligen Netzwerkschnittstelle verwenden (z.B. mit `host1 ping 10.0.0.1`), denn über den Hostnamen eines Routers lässt sich nur *eine* seiner Netzwerkschnittstellen erreichen. Dies kann auch den Fehler `connect: Das Netzwerk ist nicht erreichbar` verursachen.
