package experiment1;
import java.util.Properties;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Store;

public class Receive_Mail {
	
	public static void main(String[] args) throws Exception {
		fetchMail();
    }
	
	public static void fetchMail() {
	    // mail server connection parameters
	    String host = "localhost";
	    String user = "user";
	    String password = "password";

	    Properties properties = System.getProperties();

	    // uncomment for debugging
	 // properties.put("mail.debug", "true");
	 // properties.put("mail.debug.quote", "true");  
	    
	    Session session = Session.getDefaultInstance(properties);

	    // uncomment for debugging
	 // session.setDebug(true);
	    
		try {
		    // connect to my pop3 inbox
		    Store store = session.getStore("pop3");
		    store.connect(host, user, password);
		    Folder inbox = store.getFolder("Inbox");
		    inbox.open(Folder.READ_ONLY);

		    // get the list of inbox messages
		    Message[] messages = inbox.getMessages();

		    if (messages.length == 0) System.out.println("No messages found.");

		    // print all messages
		    for (int i = 0; i < messages.length; i++) {
		      System.out.println("Message " + (i + 1));
		      System.out.println("From : " + messages[i].getFrom()[0]);
		      System.out.println("To : " + messages[i].getAllRecipients()[0]);
		      System.out.println("Subject : " + messages[i].getSubject());
		      System.out.println("Sent Date : " + messages[i].getSentDate());
		      System.out.println(messages[i].getContent());
		      System.out.println();
		    }

		    inbox.close(true);
		    store.close();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
}
  


