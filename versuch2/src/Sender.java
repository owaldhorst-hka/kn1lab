import java.io.*;
import java.net.*;
import java.time.Duration;
import java.util.Scanner;
import java.util.concurrent.*;

/**
 * Die "Klasse" Sender liest einen String von der Konsole und zerlegt ihn in einzelne Worte. Jedes Wort wird in ein
 * einzelnes {@link Packet} verpackt und an das Medium verschickt. Erst nach dem Erhalt eines entsprechenden
 * ACKs wird das nächste {@link Packet} verschickt. Erhält der Sender nach einem Timeout von einer Sekunde kein ACK,
 * überträgt er das {@link Packet} erneut.
 */
public class Sender {
    /**
     * Hauptmethode, erzeugt Instanz des {@link Sender} und führt {@link #send()} aus.
     * @param args Argumente, werden nicht verwendet.
     */
    public static void main(String[] args) {
        Sender sender = new Sender();
        try {
            sender.send();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Erzeugt neuen Socket. Liest Text von Konsole ein und zerlegt diesen. Packt einzelne Worte in {@link Packet}
     * und schickt diese an Medium. Nutzt {@link SocketTimeoutException}, um eine Sekunde auf ACK zu
     * warten und das {@link Packet} ggf. nochmals zu versenden.
     * @throws IOException Wird geworfen falls Sockets nicht erzeugt werden können.
     */
    private void send() throws IOException {
      	//Text einlesen und in Worte zerlegen
        Scanner in = new Scanner(System.in);
        String input = in.nextLine();
        input += " EOT";
        String[] split = input.split(" ");

        // Socket erzeugen auf Port 9998 und Timeout auf eine Sekunde setzen
        DatagramSocket clientSocket = new DatagramSocket(9998);
        int timeout = 1000;
        clientSocket.setSoTimeout(timeout);

        int seq = 1;
        int ack = 1;
        int i = 0;

        // Iteration über den Konsolentext
        do {
            // Paket an Port 9997 senden
            Packet packetOut = new Packet(seq, ack, false, split[i].getBytes());

            ByteArrayOutputStream b = new ByteArrayOutputStream();
            ObjectOutputStream o = new ObjectOutputStream(b);
            o.writeObject(packetOut);
            byte[] buf = b.toByteArray();
            DatagramPacket packet
                    = new DatagramPacket(buf, buf.length, InetAddress.getLocalHost(), 9997);
            clientSocket.send(packet);

            try {
                // Auf ACK warten und erst dann Schleifenzähler inkrementieren
                byte[] recBuf = new byte[256];
                DatagramPacket rcvPacketRaw = new DatagramPacket(recBuf, recBuf.length);
                clientSocket.receive(rcvPacketRaw);

                ObjectInputStream is = new ObjectInputStream(new ByteArrayInputStream(rcvPacketRaw.getData()));
                Packet packetIn = (Packet) is.readObject();

                int newSeq = seq + split[i].getBytes().length;

                if (packetIn.getAckNum() == newSeq) {
                    seq = newSeq;
                    i++;
                }
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (SocketTimeoutException e) {
                System.out.println("Receive timed out, retrying...");
            }

        } while (i < split.length);
        
        // Wenn alle Packete versendet und von der Gegenseite bestätigt sind, Programm beenden
        clientSocket.close();
        
        if(System.getProperty("os.name").equals("Linux")) {
            clientSocket.disconnect();
        }

        System.exit(0);
    }
}
