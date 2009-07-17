package net.jlj.board.delegate;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;

import org.apache.log4j.Logger;

/**
 * Base class for delegates keeps the EntityManager in a ThreadLocal variable. All delegates derived
 * from this class share the same thread local instance of the EntityManager.
 * @author john
 *
 */
public class AbstractDelegate
{
   private static Logger log = Logger.getLogger (AbstractDelegate.class);
   private static EntityManagerFactory sFactory;
   private static final ThreadLocal<EntityManager> sTl = new ThreadLocal<EntityManager> ()
   {
      @Override 
      protected EntityManager initialValue ()
      {
         return sFactory.createEntityManager ();
      }
   };
   protected EntityManager mManager;
   
   protected AbstractDelegate ()
   {
      
   }
   public AbstractDelegate (EntityManagerFactory emf)
   {
      sFactory = emf;
      mManager = sTl.get ();
   }
   public <T> T find (Class<T> cls, Object obj)
   {
      return mManager.find (cls, obj);
   }
   public void persist (Object o)
   {
      mManager.persist (o);
   }
   public void remove (Object o)
   {
      mManager.remove (o);
   }
   public Query createNamedQuery (String name)
   {
      return mManager.createNamedQuery (name);
   }
   @SuppressWarnings("unchecked")
   public Query createNativeQuery (String sql, Class cls)
   {
      return mManager.createNativeQuery (sql, cls);
   }
   /**
    * Start a transaction if it isn't active.
    */
   public void beginTx ()
   {
      EntityTransaction tx = mManager.getTransaction ();
      if (!tx.isActive ())
      {
         tx.begin ();
      }
   }
   public boolean isTxActive ()
   {
      EntityTransaction tx = mManager.getTransaction ();
      return tx.isActive ();
   }
   /**
    * Commit and close the EntityManager.
    */
   public void commit ()
   {
      EntityTransaction tx = mManager.getTransaction ();
      if (tx.isActive ())
      {
         try
         {
            tx.commit ();
         }
         catch (Exception e)
         {
            
            log.error ("Commit error: ", e);
            throw new RuntimeException (e);
         }
      }
      close ();
   }
   /**
    * Synchronize the persistence context to the underlying database. 
    */
   public void flush ()
   {
      try
      {
         mManager.flush ();
      }
      catch (Exception e)
      {
         log.error ("Flush error: ", e);
         throw new RuntimeException (e);
      }
   }
   /**
    * Commits a transaction but does not close the EntityManager. 
    */
   public void commitAndKeepOpen ()
   {
      EntityTransaction tx = mManager.getTransaction ();
      try
      {
         tx.commit ();
      }
      catch (Exception e)
      {
         log.error ("Commit error: ", e);
         throw new RuntimeException (e);
      }
   }
   /**
    * Rollback a transaction (if active) and close the EntityManager (if required).
    */
   public void close ()
   {
      if (mManager != null && mManager.isOpen ())
      {
         try
         {
            EntityTransaction tx = mManager.getTransaction ();
            if (tx.isActive ())
            {
               tx.rollback ();
            }
            mManager.close ();
         }
         finally
         {
            mManager = null;
            sTl.remove ();
         }
      }
   }
   
}
