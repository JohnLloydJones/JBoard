package net.jlj.board.jndi;

import java.util.Hashtable;

import javax.naming.Binding;
import javax.naming.Context;
import javax.naming.Name;
import javax.naming.NameClassPair;
import javax.naming.NameParser;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
/**
 * Implement the root context for jndi lookup.
 * @author john
 *
 */
public class LocalContextRoot implements Context
{
   private static final NamingContext mRootContext = new NamingContext();
   private final Hashtable<String, Object> mEnvironment;
   
   public LocalContextRoot (Hashtable<String,Object> env)
   {
      mEnvironment = new Hashtable<String, Object> (env);
   }
   
   @Override
   public Object addToEnvironment (String propName, Object propVal) throws NamingException
   {
      return mEnvironment.put (propName, propVal);
   }

   @Override
   public void bind (Name name, Object obj) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.bind (name, obj);
      }

   }

   @Override
   public void bind (String name, Object obj) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.bind (name, obj);
      }
   }

   @Override
   public void close () throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.close ();
      }
   }

   @Override
   public Name composeName (Name name, Name prefix) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.composeName (name, prefix);
      }
   }

   @Override
   public String composeName (String name, String prefix) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.composeName (name, prefix);
      }
   }

   @Override
   public Context createSubcontext (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.createSubcontext (name);
      }
   }

   @Override
   public Context createSubcontext (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.createSubcontext (name);
      }
   }

   @Override
   public void destroySubcontext (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.destroySubcontext (name);
      }
   }

   @Override
   public void destroySubcontext (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.destroySubcontext (name);
      }
   }

   @Override
   public Hashtable <?, ?> getEnvironment () throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.getEnvironment ();
      }
   }

   @Override
   public String getNameInNamespace () throws NamingException
   {
      return "";
   }

   @Override
   public NameParser getNameParser (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.getNameParser (name);
      }
   }

   @Override
   public NameParser getNameParser (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.getNameParser (name);
      }
   }

   @Override
   public NamingEnumeration <NameClassPair> list (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.list (name);
      }
   }

   @Override
   public NamingEnumeration <NameClassPair> list (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.list (name);
      }
   }

   @Override
   public NamingEnumeration <Binding> listBindings (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.listBindings (name);
      }
   }

   @Override
   public NamingEnumeration <Binding> listBindings (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.listBindings (name);
      }
   }

   @Override
   public Object lookup (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.lookup (name);
      }
   }

   @Override
   public Object lookup (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.lookup (name);
      }
   }

   @Override
   public Object lookupLink (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.lookupLink (name);
      }
   }

   @Override
   public Object lookupLink (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.lookupLink (name);
      }
   }

   @Override
   public void rebind (Name name, Object obj) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.rebind (name, obj);
      }
   }

   @Override
   public void rebind (String name, Object obj) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.rebind (name, obj);
      }
   }

   @Override
   public Object removeFromEnvironment (String propName) throws NamingException
   {
      synchronized (mRootContext)
      {
         return mRootContext.removeFromEnvironment (propName);
      }
   }

   @Override
   public void rename (Name oldName, Name newName) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.rename (oldName, newName);
      }
   }

   @Override
   public void rename (String oldName, String newName) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.rename (oldName, newName);
      }
   }

   @Override
   public void unbind (Name name) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.unbind (name);
      }
   }

   @Override
   public void unbind (String name) throws NamingException
   {
      synchronized (mRootContext)
      {
         mRootContext.unbind (name);
      }
   }

}
