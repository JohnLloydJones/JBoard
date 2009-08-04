package net.jlj.board;

import java.io.InputStream;
import java.sql.Connection;
import java.util.Properties;

import javax.naming.Binding;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NameClassPair;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.apache.commons.dbcp.ConnectionFactory;
import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDataSource;
import org.apache.commons.pool.ObjectPool;
import org.apache.commons.pool.impl.GenericObjectPool;
import org.apache.log4j.Logger;

/**
 * Establish a DataSource and bind it to the expected jndi name.
 * @author john
 *
 */
public class DataSourceProvider
{
   private static Logger log = Logger.getLogger(DataSourceProvider.class.getName ());
   private static final String JNDI_PREFIX = "java:comp/env";
   private static final String JNDI_NAME = "jdbc/JBoardDB";
   private static final String FULL_JNDI_NAME = JNDI_PREFIX + "/" + JNDI_NAME;
   private static final String NAMING_FACTORY = "net.jlj.board.jndi.InitialContextFactory";
   private PoolingDataSource dataSource = null;

   /**
    * Create a datasource and bind it to the jndi name.
    * Constructor
    * @param driver
    * @param url
    * @param user
    * @param password
    */
   public DataSourceProvider (String driver, String url, String user, String password)
   {
      try
      {
         Class.forName (driver);
      }
      catch (ClassNotFoundException e)
      {
         log.error ("Failed to load driver", e);
         throw new RuntimeException ("Failed to load driver", e);
      }
      try
      {
         String namingFactory = System.getProperty (Context.INITIAL_CONTEXT_FACTORY);
         if (namingFactory == null)
         {
            namingFactory = NAMING_FACTORY;
            System.getProperties ().put (Context.INITIAL_CONTEXT_FACTORY, namingFactory);
         }
         System.out.println ("naming factory is: " + namingFactory);
         dataSource = setupDataSource (url, user, password);
         Properties p = new Properties ();
         p.put (Context.INITIAL_CONTEXT_FACTORY, namingFactory);
         Context ctx = new InitialContext(p);
         bind (ctx, FULL_JNDI_NAME, dataSource);
      }
      catch (NamingException e)
      {
         log.error ("Failed to bind the DataSource", e);
         throw new RuntimeException ("Failed to bind the DataSource", e);
      }
      catch (Throwable t)
      {
         log.error ("Failed to create the DataSource", t);
         throw new RuntimeException ("Failed to create the DataSource", t);
      }
   }
   /**
    * Bind to a context, creating the sub-contexts as required.
    * @param ctx the context to bind to
    * @param name the name (possibly compound), relative to the context 
    * @param obj the object to bind
    * @return
    * @throws NamingException
    */
   private Context bind (Context ctx, String name, Object obj) throws NamingException
   {
      String[] names = name.split ("/");
      Context subCtx = ctx;
      for (int n = 0; n < names.length -1; n++)
      {
         subCtx = lookupOrCreateSubcontext (subCtx, names[n]);
      }
      subCtx.rebind (names [names.length -1], obj);
      return subCtx;
   }
   /**
    * Lookup a context and if it doesn't exist, create it.
    * @param ctx
    * @param name
    * @return
    * @throws NamingException
    */
   private Context lookupOrCreateSubcontext (Context ctx, String name) throws NamingException
   {
      Context c = null;
      log.info ("For context " + ctx.getNameInNamespace ());
      try
      {
         c = (Context)ctx.lookup (name);
      }
      catch (Exception ex)
      {
         log.info ("Create subcontext " + name);
         c = ctx.createSubcontext (name);
      }
      return c;
   }


   private static Properties loadProperties (String name)
   {
      Properties props = new Properties ();
      InputStream in = DataSourceProvider.class.getResourceAsStream ("/" + name);
      try
      {
         props.load (in);
         in.close ();
      }
      catch (Exception e)
      {
         log.debug (e);
      }
      return props;
   }
   /**
    * Create a pooling DataSource.
    * @param connectURI
    * @param user
    * @param password
    * @return
    */
   private PoolingDataSource setupDataSource (String connectURI, String user, String password)
   {
      GenericObjectPool.Config config = new GenericObjectPool.Config ();
      config.maxActive = 150;
      config.maxIdle = 100;
      config.minIdle = 30;
      config.maxWait = 1000;

      
      ObjectPool connectionPool = new GenericObjectPool (null, config);
      ConnectionFactory connectionFactory = new DriverManagerConnectionFactory (connectURI, user, password);

      // Side effect sets the factory in the pool.
      @SuppressWarnings ("unused")
      PoolableConnectionFactory poolableConnectionFactory = new PoolableConnectionFactory (connectionFactory,
               connectionPool, null, null, false, true);
      PoolingDataSource poolingDataSource = new PoolingDataSource (connectionPool);
      
      return poolingDataSource;
   }
   /**
    * For test only.
    */
   public static void main (String [] args) throws Exception
   {
      Properties props;
      try
      {
         props = loadProperties ("jboard-ds.properties");
      }
      catch (RuntimeException e)
      {
         props = new Properties();
      }
      
      String driver = props.getProperty ("driverClassName", "org.apache.derby.jdbc.EmbeddedDriver");
      String username = props.getProperty ("username", "");
      String password = props.getProperty ("password", "");
      String url = props.getProperty ("url", "jdbc:derby:JBoardDB;create=true");
      
      DataSourceProvider provider = new DataSourceProvider (driver,  url, username, password);

      Context ctx = new InitialContext();
      NamingEnumeration<Binding> e = ctx.listBindings ("");
      System.out.println ("getting the elements in the root context:");
      int n = 0;
      while (e.hasMoreElements ())
      {
         NameClassPair p = e.nextElement ();
         System.out.println ("   " + ++n + ": " + p.toString ());
         String name = p.getName ();
         NamingEnumeration<Binding> e1 = ctx.listBindings (name);
         while (e1.hasMoreElements ())
         {
            NameClassPair p1 = e1.nextElement ();
            System.out.println ("      " + ++n + ": " + p1.toString ());
         }
      }
      System.out.println ("There were " + n + " elements");
      
      Context envCtx = (Context)ctx.lookup (JNDI_PREFIX);
      DataSource ds = (DataSource)envCtx.lookup (JNDI_NAME);
      Connection conn = ds.getConnection ();
      System.out.println ("Connection: " + conn);
      conn.close();
   }
}
