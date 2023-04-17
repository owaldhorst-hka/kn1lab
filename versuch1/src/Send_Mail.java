import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage; 

public class Send_Mail {
	public static void main(String[] args) {
		sendMail();   
	}
	
	public static void sendMail() {
		try {
			Properties props = new Properties();
			props.put("mail.smtp.host", "localhost");
			Session session = Session.getInstance(props, null);
			InternetAddress from = new InternetAddress("user@localhost", "user");

			try {
				MimeMessage msg = new MimeMessage(session);
				msg.setFrom(from);
				msg.setRecipients(Message.RecipientType.TO, "<labrat@localhost>");
				msg.setSubject("KN1-Lab 1 Aufgabe 2 Test 4");
				msg.setText("Testing, testing. 1 2 3. Hello?");
				Transport.send(msg);
			} catch (MessagingException mex) {
				System.out.println("send failed, exception: " + mex);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
