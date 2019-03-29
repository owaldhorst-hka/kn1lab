import java.io.Serializable;

/**
 * Die Klasse "Packet" stellt Sequenznummern, Acknowledgementnummern, ACK-Flags und Payloads zu Verfügung, um UDP Pakete
 * mit Elementen des zuverlässigen Transports zu erweitern. Dazu wird ein Objekt der Klasse als Payload eines
 * {@link java.net.DatagramPacket} verwendet.
 */
public class Packet implements Serializable {
    private int seq, ackNum;
    private boolean ackFlag;
    private byte[] payload;

    /**
     * Konstruktor, erzeugt ein neues Packet.
     * @param seq Seqeuenznummer
     * @param ackNum Acknowledgementnummer
     * @param ackFlag ACK-Flag
     * @param payload Payload
     */
    public Packet(int seq, int ackNum, boolean ackFlag, byte[] payload) {
        this.seq = seq;
        this.ackNum = ackNum;
        this.ackFlag = ackFlag;
        this.payload = payload;
    }

    /**
     * Gibt Sequenznummer zurück.
     * @return Sequenznummer
     */
    public int getSeq() {
        return seq;
    }

    /**
     * Gibt Acknowledgementnummer zurück.
     * @return Acknowledgementnummer
     */
    public int getAckNum() {
        return ackNum;
    }

    /**
     * Gibt Payload zurück.
     * @return Payload
     */
    public byte[] getPayload() {
        return payload;
    }

    /**
     * Gibt boolschen Wert zurück, ob ACK-Flag gesetzt ist.
     * @return Ist ACK-Flag gesetzt.
     */
    public boolean isAckFlag() {
        return ackFlag;
    }
}
