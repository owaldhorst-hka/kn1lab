import java.util.Date;
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
		// mail server connection parameters
	    String host = "localhost";
	    String user = "user";
	    String password = "password";
	    String from = "me@example.com";
	    String to = "you@localhost";
	    String subject = "JavaMail hello world example";
	    String text = "Hello, world!\\n";

	    Properties properties = System.getProperties();
	    // properties.put("mail.smtp.host", host);
	    
	    // uncomment for debugging
	 // properties.put("mail.debug", "true");
	 // properties.put("mail.debug.quote", "true");  
	    
	    Session session = Session.getDefaultInstance(properties);
	    
	    // uncomment for debugging
	 // session.setDebug(true);
		
		try {
	        MimeMessage msg = new MimeMessage(session);
	        msg.setFrom(from);
	        msg.setRecipients(Message.RecipientType.TO, to);
	        msg.setSubject(subject);
	        msg.setSentDate(new Date());
	        msg.setText(text);
	        Transport.send(msg, user, password);
	        
	        System.out.println("Mail sent successfully!");

	   } catch (MessagingException mex) {
		   System.out.println("Send failed, exception: " + mex);
		   }
		}
}