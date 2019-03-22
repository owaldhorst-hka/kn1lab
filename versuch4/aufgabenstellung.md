# Versuch 4 - Leistungsmessung

## Einführung

In dieser Aufgabe werden wir die Leistung von verschiedenen Transportprotokollen untersuchen und dabei Stationen betrachten, die auch in realen Netzen vorkommen können. Dazu werden wir die nachfolgend beschriebenen Werkzeuge und virtuellen Netztopologien verwenden.

### Erzeugung von Paketströmen mit `iperf3`

Das Programm `iperf3` ermöglicht das Erzeugen von TCP- und UDP-Datenströmen zwischen zwei Rechnern. `iperf3` ist eine Client-Server-Anwendung. Der Server wartet auf eingehende `iperf3`-Verbindungen. Er kann mit dem Kommando

```bash
iperf3 -s
```

gestartet werden.

Wenn der Rechner, auf dem der Server laufen soll, wie im unten betrachteten Fall zwei Netzschnittstellen besitzt, kann der Server mit 

```bash
iperf3 -s -B <IP-Adresse>
```

gezielt an die Schnittstellen mit der angegebenen IP-Adresse gebunden werden.

Einen Client, der einen TCP-Datenstrom erzeugt, kann man mit

```bash
iperf3 -c <IP-Adresse des Servers> -Z -t <Dauer der Übertragung>
```

starten. `-Z` bedeutet dabei "Zero copy", was die Leistung des Clients erhöht.

Einen Client, der einen UDP-Datenstrom erzeugt, kann man mit 

```bash
iperf3 -c <IP-Adresse des Servers> -u -b <Bandbreitenlimit>
```

erzeugen. Das Bandbreitenlimit ist standardmäßig auf 1 Mbit/s begrenzt und kann z.B. mit `-b 10M` auf 10 Mbit/s gesetzt werden. 

### Anzeigen / aufzeichnen des Durchsatzes mit `cpunetlog`

Das Werkzeug `cpunetlog` kann die aktuelle CPU-Auslastung und den aktuellen Netzdurchsatz eines Rechners anzeigen. Die CPU-Auslastung ist für diesen Versuch nicht relevant, daher werden wir auf den Durchsatz fokussieren. `cpunetlog` kann einfach mit dem Kommando 

```bash
cpunetlog
```

gestartet werden. *Abbildung 1* zeigt eine typische Ausgabe von `cpunetlog` auf einem Rechner mit drei Netzschnittstellen `sv1-eth0`, `sv1-eth1` und `sv1-eth2`. Das Programm kann durch Drücken der Taste `q` beendet werden.

![Ausgabe von cpunetlog](images/ausgabe-cpunetlog.png)<br>
*Abbildung 1: Ausgabe von `cpunetlog`*

Außerdem erlaubt `cpunetlog` das Aufzeichnen des zeitlichen Verlaufs von CPU-Auslastung und Netzdurchsatz zur späteren Auswertung. Diese kann mit

```bash
cpunetlog -l
# bzw.
cpunetlog -l --nics <Liste der Schnittstellen>
```

gestartet werden, wenn der Netzdurchsatz der in der Liste angegebenen Schnittstellen aufgezeichnet werden soll (vgl. *Tabelle 1*). Im Fenster sollte dann oben rechts in der Ecke `Logging: enabled` stehen. Die Log-Dateien werden nach `/tmp/cpunetlog` geschrieben und können mit dem Kommando

```bash
~/cpunetlog/cnl_plot.py -nsc 0.01 <Log-Datei>
```

ausgewertet werden. `-nsc 0.01` setzt die maximale Datenrate auf 10 Mbit/s. Eine beispielhafte Ausgabe zeigt *Abbildung 2*.<br>
**Achtung: Das Plotten funktioniert nicht über eine SSH-Verbindung, daher muss das Plot-Kommando auf dem "echten" PC gestartet werden!**

![Ausgabe von cnl_plot.py](images/ausgabe-plot.png)<br>
*Abbildung 2: Ausgabe von `cnl_plot.py`*

Für eine Aufzeichnung lassen sich Durchschnittswerte mit dem Kommando

```bash
~/cpunetlog/summary.py <Log-Datei>
```

berechnen.

## Verwendete Mininet-Topologie

Für den Versuch haben wir Ihnen in den Skripten `Aufgabe4-1.py` bis `Aufgabe4-3.py` eine Mininet-Topologie vorgegeben, die in *Abbildung 3* dargestellt ist. Die Namen der Schnittstellen aller Hosts kann *Tabelle 1* entnommen werden.

![Verwendete Mininet-Topologie](images/topologie.png)<br>
*Abbildung 3: Verwendete Mininet-Topologie*

| Server (`sv1`)             | Client-1 (`c1`)      | Client-2 (`c2`)      |
|----------------------------|----------------------|----------------------|
| sv1-eth0 (11.0.0.3)        | c1-eth0 (11.0.0.1)   | c2-eth0 (12.0.0.2)   |
| sv1-eth1 (12.0.0.3)        | c1-eth1 (SSH)        | c2-eth1 (SSH)        |
| sv1-eth2 (SSH)             |                      |                      |
| `--nics sv1-eth0 sv1-eth1` | `--nics c1-eth0`     | `--nics c2-eth0`     |

*Tabelle 1: Schnittstellen der Hosts in der Mininet-Topologie inkl. Parameter für `cpunetlog`*

Die Leistungsmessung zwischen den Rechnern `c1`, `c2` und `sv1` wird über die schwarz dargestellten Netzverbindungen und die Switches `S1` und `S2` erfolgen. Die rot dargestellten Netzverbindungen und der Switch `S3` werden lediglich zur Steuerung der Experimente verwendet. Die Das Mininet-Netz kann beispielsweise mit

```bash
sudo python ~/Schreibtisch/kn1lab/versuch4/scripts/Aufgabe4-1.py
```

gestartet werden. Das benötigte Passwort ist `password`.

Um `iperf3` oder `cpunetlog` auf einen der Rechner `c1`, `c2` oder `sv1` zu starten, ist das Mininet-CLI nicht ausreichend. Sie müssen sich stattdessen beispielsweise für `c1` – während das Mininet-Script in einem Terminal läuft – von einem anderen Terminal aus mit

```bash
ssh 10.0.0.1
```

verbinden. Das benötigte Passwort ist `password`.

Für die Rechner `c2` und `sv1` sind die entsprechenden Adressen aus dem Subnetz `10.0.0.0/24` zu wählen.

## Aufgabe 1 - Ein TCP-Strom

Verwenden Sie für diese Aufgabe die Mininet-Topologie `Aufgabe4-1.py`.

1. Generieren Sie mit Hilfe von `iperf3` einen TCP-Datenstrom zwischen Client `c1` und Server `sv1`. Dabei soll der `iperf3`-Client auf `c1` und der `iperf3`-Server auf `sv1` laufen. `iperf3` gibt das Staukontrollfenster `CWND` des TCP-Datenstroms aus. Wie verhält sich dieses und wie hoch ist es, nachdem der Strom eine Weile gelaufen ist?

1. Zeichen Sie diesen Datenstrom nun auf dem Server `sv1` mit Hilfe von `cpunetlog` für 60 Sekunden auf und stellen Sie das Ergebnis grafisch dar. Bewahren Sie einen Screenshot der Ausgabe für die Abnahme auf. Achten Sie auf eine entsprechende Skalierung der Plots!

1. Wie hoch war die durchschnittliche Auslastung der Netzschnittstelle? 

## Aufgabe 2 - Fairness

Verwenden Sie für diese Aufgabe ebenfalls die Mininet-Topologie `Aufgabe4-1.py`. Wir wollen nun untersuchen, ob sich zwei TCP-Datenströme die verfügbare Bandbreite fair teilen. Dazu benötigen wir zwei Datenströme, jeweils einen von Client `c1` bzw. Client `c2` zu Server `sv1`. Zu beachten sind die zwei Netzschnittstellen des Servers `sv1`; jede befindet sich in einem anderen Subnetz. Um die zwei Datenströme mit `cpunetlog` unterscheiden zu können, ist es notwendig, dass je einer der TCP-Ströme an einer der beiden Schnittstellen ankommt. Anderenfalls kann nicht zentral auf dem Server gemessen werden, welcher Datenstrom welchen Durchsatz erreicht. 

1. Erstellen Sie die notwendigen Datenströme mit `iperf3`, zeichnen Sie diese auf den Server mit `cpunetlog` für 1 Minute auf und stellen Sie das Ergebnis grafisch dar. Bewahren Sie einen Screenshot der Ausgabe für die Abnahme auf.

1. Wie war die durchschnittliche Auslastung der Netzverbindung, war diese besser oder schlechter als für einen einzelnen Strom?

1.	War die Aufteilung der Bandbreite fair?

1. Wiederholen Sie das Experiment, indem sie nun einen TCP-Strom gegen einen UDP-Strom mit einem Bandbreiten-Limit von 10 Mbit/s testen. Was ist das Ergebnis?

## Aufgabe 3 - Auswirkungen von hohem Paketverlust auf den TCP-Durchsatz

In dieser Aufgabe simulieren wir eine schlechte Verbindung vom Client zum Server, indem wir den Paketverlust auf der Leitung zwischen den zwei Switches von 0% auf 5% erhöhen. Verwenden Sie für diese Aufgabe die Mininet-Topologie `Aufgabe4-2.py`.

1. Erstellen Sie einen TCP-Datenstrom vom Client `c1` zum Server `sv1` und zeichnen Sie diesen auf dem Server für eine Minute auf. Wenn Sie den Wert `CWND`, den `iperf3` ausgibt, beobachten und mit dem aus 1.1 vergleichen, was fällt Ihnen auf? Warum ist dies so?

1. Vergleichen Sie die Plots aus 3.1 und vor allem den durchschnittlichen Durchsatz, mit dem aus der ersten Aufgabe. Weichen diese signifikant ab? Wenn ja, warum könnte dies so sein?

## Aufgabe 4 - Auswirkungen von hohem Paketverlust auf den UDP-Durchsatz

Verwenden Sie für diese Aufgabe die Mininet-Topologie `Aufgabe4-3.py`, in dem der Paketverlust auf der Leitung zwischen den zwei Switches auf 10% erhöht wurde.

1. Erstellen Sie einen UDP-Datenstrom mit einer maximalen Bandbreite von 10 Mbit/s vom Client `c1` zum Server `sv1`. Messen Sie nun sowohl die gesendeten Daten auf Client-Seite als auch empfangenen Daten auf Server-Seite jeweils mit `cpunetlog`.

1. Was fällt Ihnen bezüglich der Datenrate auf, wenn Sie den Durchsatz beider Aufzeichnungen vergleichen? Was ist der Grund für dieses Verhalten? Welcher elementare Teil von TCP ist dafür verantwortlich, dass das Verhalten in den Versuchen 3.x signifikant anders war?
