# Versuch 2 - Transportschicht

## Aufgabe

Realisieren Sie in Java aufbauend auf UDP einen zuverlässigen Transport. Hierzu müssen UDP-Segmente innerhalb der Payload um Sequenz- und Acknowledgement-Nummern ergänzt werden (bereits in `Packet.java` implementiert). Implementieren Sie einen Sender, der über ein "Medium"-Prozess mit einem Empfänger-Prozess kommuniziert.

Die Skripte zum Starten von Empfänger und Medium finden Sie im Ordner `~/kn1lab/versuch2/scripts`. Die beiden Skripts `StartMedium.sh` und `StartReceiver.sh` müssen jeweils in einem eigenen (!) Terminal-Fenster gestartet werden. Der Befehl dafür lautet `./StartMedium.sh` bzw. `./StartReceiver.sh`.

Die Vorlagen für diese Aufgabe finden Sie in Eclipse unter `versuch2/src/`.

Beachten Sie, dass ein UDP-Socket nur Bytes versenden kann. Daher muss ein Objekt der Klasse `Packet` für die Übertragung in Bytes serialisiert werden. Sie können hierfür die Klasse `ByteArrayOutputStream` verwenden, z.B. so:

```java
// create new packet 
Packet packetOut = new Packet(/*...*/);

// serialize Packet for sending
ByteArrayOutputStream b = new ByteArrayOutputStream();
ObjectOutputStream o = new ObjectOutputStream(b);
o.writeObject(packetOut);
byte[] buf = b.toByteArray();
```

Ein empfangenes UDP-Datagramm kann z.B. so deserialisiert werden:

```java
byte[] buf = new byte[256];
DatagramPacket rcvPacketRaw = new DatagramPacket(/*...*/);

/*...*/

// deserialize Packet
ObjectInputStream is = new ObjectInputStream(new ByteArrayInputStream(rcvPacketRaw.getData()));
Packet packetIn = (Packet) is.readObject();
```

Senden Sie die Pakete an den Port `9997` des Mediums und erwarten Sie ACKs auf Port `9998`. Verwenden Sie dafür denselben Socket.

Beispiele zur Programmierung mit UDP-Sockets in Java finden Sie hier:

<https://docs.oracle.com/javase/tutorial/networking/datagrams/clientServer.html>
	
Implementieren Sie in `Sender.java` eine Funktion, die einen String von der Konsole liest und ihn in einzelne Worte zerlegt. Anschließend wird jedes Wort einzeln in ein Paket verpackt und über das Medium an den Empfänger gesendet.

Erst nach dem Erhalt des ensprchenden ACKs wird das nächste Paket verschickt. Erhält der Sender nach einem Timeout von 1000 Millisekunden nicht das korrekte oder gar kein ACK, überträgt er das Paket erneut.

Senden Sie, nachdem alle Zeichen übertragen wurden, zusätzlich den String `EOT` um den Empfänger dazu zu veranlassen, die empfangene Zeichenfolge nochmals am Stück auszugeben.
