import java.io.*;
import java.net.*;
import java.time.Duration;
import java.util.concurrent.*;

/**
 * Die Sender Klasse liest einen String von der Konsole und zerlegt ihn in einzelne Zeichen. Jedes Zeichen wird in ein
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
     * Erzeugt neuen Socket. Liest Text von Konsole ein und zerlegt diesen. Packt einzelne Zeichen in {@link Packet}
     * und schickt diese an {@link Medium}. Nutzt {@link Future} und {@link ExecutorService} um 5 Sekunden auf ACK zu
     * warten und das {@link Packet} ggf. nochmals zu versenden.
     * @throws IOException Wird geworfen falls Sockets nicht erzeugt werden können.
     */
    private void send() throws IOException {
    	/* Text einlesen und zerlegen */
        
        while (/* Iteration über den Konsolentext */) {
        	/* Pakete Empfangen und versenden */
        	
            try {
                /* Für 5 Sekunden auf ACK warten */
            } catch (InterruptedException | ExecutionException e) {
                e.printStackTrace();
            } catch (TimeoutException e) {
                /* Nach 5 Sekunden ExecuterService abbrechen und Schleifenzähler dekrementieren um Übertragung zu wiederholen */
            } finally {
                clientSocket.close();
                if(System.getProperty("os.name").equals("Linux")) {
                    clientSocket.disconnect();
                }
            }

            /* Wenn alle Packete versendet und von der Gegenseite bestätigt sind, Programm beenden */
            if () {
                clientSocket.close();
                System.exit(0);
                return;
            }
        }
    }

    /**
     * Nimmt ACKs des {@link Receiver} entgegen.
     * @param socketIn {@link Socket} auf dem ACKs erwartet wird.
     * @return Empfangene ACK-Nummer
     * @throws IOException Wird geworfen wenn nicht von {@link Socket} gelesen werden kann.
     * @throws ClassNotFoundException Wird geworfen falls {@link Packet} Klasse nicht gefunden wird.
     * @throws TimeoutException Wird geworfen wenn empfangenes {@link Packet} kein ACK ist um wiederholte Übertagung
     * auszulösen.
     */
    private int getAck(DatagramSocket socketIn) throws IOException, ClassNotFoundException, TimeoutException {
        if (/* Prüfen ob es sich um ACK handelt */) {
            /* Falls Packet ein ACK ist, ACK-Nummer übernehmen */
        } else {
            /* Falls Packet kein ACK ist, wiederholte Übertagung durch Exception auslösen */
            throw new TimeoutException();
        }

        return /* Neue ACK Nummer zurückgeben */;
    }
}
