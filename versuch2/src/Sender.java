import java.io.*;
import java.net.*;
import java.time.Duration;
import java.util.concurrent.*;

/**
 * Die "Klasse" Sender liest einen String von der Konsole und zerlegt ihn in einzelne Worte. Jedes Wort wird in ein
 * einzelnes {@link Packet} verpackt und an das {@link Medium} verschickt. Erst nach dem Erhalt eines entsprechenden
 * ACKs wird das nächste {@link Packet} verschickt. Erhält der Sender nach einem Timeout von 5 Sekunden kein ACK,
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
     * und schickt diese an {@link Medium}. Nutzt {@link SocketTimeoutException}, um 5 Sekunden auf ACK zu
     * warten und das {@link Packet} ggf. nochmals zu versenden.
     * @throws IOException Wird geworfen falls Sockets nicht erzeugt werden können.
     */
    private void send() throws IOException {
    	/* Text einlesen und in Worte zerlegen */

        /* Socket erzeugen auf Port 9998 und Timeout auf 5 Sekunden setzen */
        
        while (/* Iteration über den Konsolentext */) {
        	/* Paket an Port 9997 senden */
        	
            try {
                /* Auf ACK warten und erst dann Schleifenzähler inkrementieren */
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (SocketTimeoutException e) {
            	System.out.println("Receive timed out, retrying...");
            }
        }
        
        /* Wenn alle Packete versendet und von der Gegenseite bestätigt sind, Programm beenden */
        clientSocket.close();
        
        if(System.getProperty("os.name").equals("Linux")) {
            clientSocket.disconnect();
        }
        
        System.exit(0);
    }

    /**
     * Nimmt ACKs des {@link Receiver} entgegen.
     * @param socketIn {@link Socket} auf dem ACKs erwartet wird.
     * @return Empfangene ACK-Nummer
     * @throws IOException Wird geworfen wenn nicht von {@link Socket} gelesen werden kann.
     * @throws ClassNotFoundException Wird geworfen falls {@link Packet} Klasse nicht gefunden wird.
     * @throws SocketTimeoutException Wird geworfen wenn empfangenes {@link Packet} kein ACK ist um wiederholte Übertagung
     * auszulösen.
     */
    private int getAck(DatagramSocket socketIn) throws IOException, ClassNotFoundException, SocketTimeoutException {
        /* Paket empfangen und in "Packet"-Objekt deserialisieren */

        if (/* Prüfen ob es sich um ACK handelt */) {
            return /* Neue ACK Nummer zurückgeben */;
        }

        /* Falls Packet kein ACK ist, wiederholte Übertagung durch Exception auslösen */
        throw new SocketTimeoutException();
    }
}
