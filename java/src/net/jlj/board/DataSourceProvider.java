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
   private static final String JNDI_NAME = "jdbc/JBoardDB";
   private static final String NAMING_FACTORY = "net.jlj.board.jndi.InitialContextFactory";
   private PoolingDataSource dataSource = null;

   /**
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
         e.printStackTrace ();
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
         ctx.createSubcontext ("java:comp")
                  .createSubcontext ("env")
                  .createSubcontext ("jdbc")
                  .bind("JBoardDB", dataSource);
      }
      catch (NamingException e)
      {
         e.printStackTrace();
         log.error ("Failed to create the DataSource", e);
      }
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
    * @throws NamingException
    */
   private PoolingDataSource setupDataSource (String connectURI, String user, String password) throws NamingException
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
      
      
      DataSource ds = (DataSource)ctx.lookup (JNDI_NAME);
      Connection conn = ds.getConnection ();
      System.out.println ("Connection: " + conn);
      conn.close();
   }
}
