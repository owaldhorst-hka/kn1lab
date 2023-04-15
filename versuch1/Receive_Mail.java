import java.util.Properties;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.internet.InternetAddress;

public class Receive_Mail {
	public static void main(String[] args) throws Exception {
		fetchMail();
	}
	
	public static void fetchMail() {
		try {
			Properties props = new Properties();
			props.put("mail.store.protocol", "pop3");
			props.put("mail.pop3.host", "localhost");

			Session session = Session.getInstance(props);

			Store store = session.getStore();
			store.connect("localhost", "labrat", "kn1lab");

			Folder folder = store.getFolder("INBOX");
			folder.open(Folder.READ_WRITE);
			Message[] messages = folder.getMessages();

			for (int i = 0; i < messages.length; i++) {
				String out = "";
				Message m = messages[i];
				InternetAddress s = (InternetAddress) m.getFrom()[0];

				out += "Nachricht " + i;
				out += ", Absender : " + s.getPersonal() + ", <" + s.getAddress() + ">";
				out += ", Betreff : " + m.getSubject();
				out += ", Versanddatum : " + m.getSentDate().toString();
				out += ", Inhalt : " + m.getContent().toString();

				System.out.println(out);
			}

		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}
