import java.io.*;
import java.net.*;
import java.time.Duration;
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
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String input = reader.readLine();
        String[] words = input.split("\\s+");
        // Socket erzeugen auf Port 9998 und Timeout auf 5 Sekunden setzen

        // Iteration über den Konsolentext
        DatagramSocket clientSocket = new DatagramSocket(9998);
        clientSocket.setSoTimeout(5000);
        int index = 0;
        int ackNum = 1;
        int seqNum = 1;
        InetAddress address = InetAddress.getByName("localhost");

        while (index <= words.length) {
            // Paket an Port 9997 senden
            byte[] byteArray;

            if(words.length == index){
                byteArray = (input + "EOT").getBytes();
            } else {
                byteArray = words[index].getBytes();
            }
            if(seqNum == ackNum) {
                ackNum = ackNum + byteArray.length;
            }
            Packet packetOut = new Packet(seqNum,ackNum,true,byteArray);
            ByteArrayOutputStream b = new ByteArrayOutputStream();
            ObjectOutputStream o = new ObjectOutputStream(b);
            o.writeObject(packetOut);
            byte[] buf = b.toByteArray();
            DatagramPacket dgp = new DatagramPacket(buf,buf.length,address,9997);
            clientSocket.send(dgp);
            try {
                // Auf ACK warten und erst dann Schleifenzähler inkrementieren
                byte[] recBuf = new byte[buf.length];
                dgp = new DatagramPacket(recBuf,recBuf.length);
                while(true) {
                    clientSocket.receive(dgp);
                    ObjectInputStream is = new ObjectInputStream(new ByteArrayInputStream(dgp.getData()));
                    Packet packetIn = (Packet) is.readObject();

                    if(ackNum != seqNum+packetIn.getPayload().length) {
                        break;
                    } else {
                        seqNum = seqNum + packetIn.getPayload().length;
                    }
                    String in = new String(packetIn.getPayload());
                    if(in.endsWith("EOT")) {
                        System.out.println(in.replace("EOT", ""));
                    } else {
                        System.out.println(in);
                    }
                    index++;
                    break;
                }
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (SocketTimeoutException e) {
                System.out.println("Receive timed out, retrying...");
            }
        }
        
        // Wenn alle Packete versendet und von der Gegenseite bestätigt sind, Programm beenden
        clientSocket.close();
        
        if(System.getProperty("os.name").equals("Linux")) {
            clientSocket.disconnect();
        }

        System.exit(0);
    }
}
