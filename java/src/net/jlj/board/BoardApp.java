package net.jlj.board;

import java.io.InputStream;
import java.lang.reflect.Type;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import javax.naming.Binding;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.sql.DataSource;

import net.jlj.board.delegate.BoardDelegate;
import net.jlj.board.delegate.MemberDelegate;
import net.jlj.board.delegate.SettingsDelegate;

import org.apache.log4j.Logger;
import org.picocontainer.DefaultPicoContainer;
import org.picocontainer.PicoCompositionException;
import org.picocontainer.PicoContainer;
import org.picocontainer.injectors.FactoryInjector;
/**
 * Class to hold application scope information. 
 * @author john
 *
 */
public class BoardApp
{
   private static Logger log = Logger.getLogger(BoardApp.class.getName ());
   private static final String OPENJPA_PROPS = "openjpa.properties";
   protected PicoContainer mPico;
   protected static BoardApp mApp;
   /**
    * Injector for the openjpa EntityManagerFactory.
    * @author john
    *
    */
   public static class EmfInjector extends FactoryInjector<EntityManagerFactory> 
   {  
      private static EntityManagerFactory sFactory = Persistence.createEntityManagerFactory("board", initProperties ());
      public EntityManagerFactory getComponentInstance(PicoContainer container, final Type into) 
         throws PicoCompositionException 
      {  
         return sFactory;  
      }  
   };  
        
   protected BoardApp ()
   {
      mPico = new DefaultPicoContainer ();
   }
   
   public static BoardApp getInstance ()
   {
      if (mApp == null)
      {
         mApp = new BoardApp ();
         log.debug ("Initialising the container");
         mApp.init ();
      }
      return mApp;
   }
   
   public static <T> T getComponent (Class<T> o)
   {
      return getInstance ().mPico.getComponent (o);
   }
   
   private void init ()
   {
      DefaultPicoContainer pico = (DefaultPicoContainer) mPico;
      pico.addAdapter (new EmfInjector());
      pico.addComponent (MemberDelegate.class, MemberDelegate.class);
      pico.addComponent (BoardDelegate.class, BoardDelegate.class);
      pico.addComponent (SettingsDelegate.class, SettingsDelegate.class);
      pico.addComponent (Facade.class, Facade.class);
   }   
   /**
    * Get (or set) some properties. First load the openjpa.properties required for the EMF.
    * Check for Derby -- need to configure derby.system.home if it has not been set.
    * Check for an external datasource (as seen by the initial context factory). If none
    * configured, create one locally and bind it's jndi name.
    * @return
    */
   private static Properties initProperties ()
   {
      Properties props = loadProperties (OPENJPA_PROPS);
      // Special handling for Derby. Must set derby.system.home to something sensible.
      String dictionary = props.getProperty ("openjpa.jdbc.DBDictionary");
      log.info ("using " + dictionary + " DBDictionary");
      if (dictionary.startsWith ("derby"))
      {
         String dbHome = System.getProperty ("derby.system.home");
         log.info ("derby.system.home is currently " + dbHome);
         if (dbHome == null)
         {
            log.info ("set derby.system.home to " + System.getProperty ("user.home") + "/.jboard");
            System.setProperty ("derby.system.home", System.getProperty ("user.home") + "/.jboard");
         }
      }
      
      String namingFactory = System.getProperty (Context.INITIAL_CONTEXT_FACTORY);
      log.info ("Initial context factory: " + namingFactory);
      if ("Y".equals (props.getProperty ("force.local.datasource", "N")))
      {
         System.getProperties ().remove (Context.INITIAL_CONTEXT_FACTORY);
         namingFactory = System.getProperty (Context.INITIAL_CONTEXT_FACTORY);
      }
      if (namingFactory == null)
      {
         log.info ("No datasource (initial context factory not defined). Attempt to create one locally.");
         Properties dsProps;
         try
         {
            dsProps = loadProperties ("jboard-ds.properties");
         }
         catch (RuntimeException e)
         {
            log.info ("No jboard-ds.properties file; using default settings.");
            dsProps = new Properties();
         }
         String driver =   dsProps.getProperty ("driverClassName", "org.apache.derby.jdbc.EmbeddedDriver");
         String username = dsProps.getProperty ("username", "");
         String password = dsProps.getProperty ("password", "");
         String url =      dsProps.getProperty ("url", "jdbc:derby:JBoardDB;create=true");
         
         log.info ("Create DataSource using driver " + driver + " and url: " + url);
         DataSourceProvider provider = new DataSourceProvider (driver,  url, username, password);
         namingFactory = System.getProperty (Context.INITIAL_CONTEXT_FACTORY);
         log.info ("Initial context factory is now: " + namingFactory);
      }

/*     
      try
      {
         log.info ("Attempt to get a connection...");
         Context ctx = new InitialContext();
         NamingEnumeration<Binding> e = ctx.listBindings ("java:comp/env");
         log.info ("getting the elements in the root context:");
         int n = 0;
         while (e.hasMoreElements ())
         {
            NameClassPair p = e.nextElement ();
            log.info ("   " + ++n + ": " + p.toString ());
            NamingEnumeration<Binding> e1 = ctx.listBindings ("java:comp/env/" + p.getName ());
            while (e1.hasMoreElements ())
            {
               NameClassPair p1 = e1.nextElement ();
               log.info ("      " + ++n + ": " + p1.toString ());
            }
         }
         log.info ("There were " + n + " elements");
         Context envCtx = (Context)ctx.lookup ("java:comp/env");
         DataSource ds = (DataSource)envCtx.lookup ("jdbc/JBoardDB");
         Connection conn = ds.getConnection ();
         log.info ("Connection: " + conn);
         conn.close ();
      }
      catch (NamingException e)
      {
         log.error ("Failed to get the connection: " );
         log.error(e);
      }
      catch (SQLException e)
      {
         log.error ("Failed to get the connection: " );
         log.error(e);
      }
      
      log.info ("Properties for openjpa emf: " + props.toString ());
*/      
      return props;
   }
   
   private static Properties loadProperties (String name)
   {
      Properties props = new Properties();
      InputStream in = BoardApp.class.getResourceAsStream ("/" + name);
      try
      {
         props.load (in);
         in.close ();
      }
      catch (Exception e)
      {
         log.fatal (e);
         System.out.println ("Could not open " + name + ": " +  e.getMessage ());
         throw new RuntimeException ("Could not open " + name + ": ", e);
      }
      return props;
   }
}
