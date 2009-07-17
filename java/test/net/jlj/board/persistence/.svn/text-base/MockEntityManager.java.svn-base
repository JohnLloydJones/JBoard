package net.jlj.board.persistence;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.Stack;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.FlushModeType;
import javax.persistence.LockModeType;
import javax.persistence.Query;

public class MockEntityManager implements EntityManager
{
   private boolean mOpen = true;
   private EntityTransaction tx;
   private Stack<Object> managed = new Stack<Object>();
   private static long sequence_no = 2000;
   
   @Override
   public void clear ()
   {
      // TODO Auto-generated method stub

   }

   @Override
   public void close ()
   {
      mOpen = false;
   }

   @Override
   public boolean contains (Object arg0)
   {
      // TODO Auto-generated method stub
      return false;
   }

   @Override
   public Query createNamedQuery (String arg0)
   {
      return new MockQuery ();
   }

   @Override
   public Query createNativeQuery (String arg0)
   {
      return new MockQuery ();
   }

   @SuppressWarnings("unchecked")
   @Override
   public Query createNativeQuery (String arg0, Class arg1)
   {
      return new MockQuery ();
   }

   @Override
   public Query createNativeQuery (String arg0, String arg1)
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public Query createQuery (String arg0)
   {
      // TODO Auto-generated method stub
      return null;
   }

   @SuppressWarnings("unchecked")
   @Override
   public <T> T find (Class <T> arg0, Object arg1)
   {
      /* Cheat! Use MockQuery as it has the result stack. */
      return (T)new MockQuery().getSingleResult ();
   }

   /*
    Pretend to flush to the db by setting the oid on objects that have id = 0
    */
   @SuppressWarnings ("unchecked")
   @Override
   public void flush ()
   {
      if (!getTransaction().isActive ())
         return;
      Iterator <Object> iter = managed.iterator ();
      // Caution duck-typing ahead. We don't know the class, but
      // we will assume that it will have getId/setId methods
      while (iter.hasNext())
      {
         Object obj = iter.next ();
         Class cls = obj.getClass ();
         try
         {
            Method get_method = cls.getMethod ("getId");
            Object[] g_args = {};
            Long id = (Long)get_method.invoke (obj, g_args);
            if (id.longValue () == 0)
            {
               Method set_method = cls.getMethod ("setId", long.class);
               Object[] s_args = {sequence_no};
               set_method.invoke (obj, s_args);
               System.out.println ("Set id " + sequence_no + " to object of class " + cls.getSimpleName ());
               sequence_no += 1;
            }
         }
         catch (Exception e)
         {
            // didn't work. This is test code, so just log the problem.
            System.out.println ("flush error for object of class " + cls.getSimpleName ());
         }
      }

   }

   @Override
   public Object getDelegate ()
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public FlushModeType getFlushMode ()
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public <T> T getReference (Class <T> arg0, Object arg1)
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public EntityTransaction getTransaction ()
   {
      if (tx == null)
      {
         tx = new MockEntityTransaction ();
      }
      return tx;
   }

   @Override
   public boolean isOpen ()
   {
      return mOpen;
   }

   @Override
   public void joinTransaction ()
   {
      // TODO Auto-generated method stub

   }

   @Override
   public void lock (Object arg0, LockModeType arg1)
   {
      // TODO Auto-generated method stub

   }

   @Override
   public <T> T merge (T arg0)
   {
      return arg0;
   }

   @Override
   public void persist (Object item)
   {
      managed.push (item);

   }

   @Override
   public void refresh (Object item)
   {
      managed.push (item);
   }

   @Override
   public void remove (Object arg0)
   {
      // TODO Auto-generated method stub

   }

   @Override
   public void setFlushMode (FlushModeType arg0)
   {
      // TODO Auto-generated method stub

   }

}
