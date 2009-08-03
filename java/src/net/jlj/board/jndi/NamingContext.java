package net.jlj.board.jndi;

import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Map;

import javax.naming.Binding;
import javax.naming.Context;
import javax.naming.Name;
import javax.naming.NameClassPair;
import javax.naming.NameNotFoundException;
import javax.naming.NameParser;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.OperationNotSupportedException;

import org.apache.log4j.Logger;
/**
 * Minimal Naming Context implementation. Has exactly enough functionality to
 * provide jndi lookup for the JBoard application.
 * @author john
 *
 */
public class NamingContext implements Context
{
   private final Logger log = Logger.getLogger (getClass ().getName ());

   private final String mRoot;

   private final Hashtable<String, Object> mBoundObjects;

   private final Hashtable<String, Object> mEnvironment;

   public NamingContext ()
   {
      this ("");
   }

   public NamingContext (String root)
   {
      this (root, null, null);
   }

   public NamingContext (String root, Hashtable<String, Object> boundObjects, Hashtable<String, Object> environment)
   {
      mRoot = root;
      mBoundObjects = (boundObjects == null) ? new Hashtable<String, Object> () : boundObjects;
      mEnvironment =  new Hashtable<String, Object> ();
      if (environment != null)
      {
         mEnvironment.putAll (environment);
      }
   }

   public NamingEnumeration<NameClassPair> list (String root) throws NamingException
   {
      return new NameClassPairEnumeration<NameClassPair> (this, root);
   }

   public NamingEnumeration<Binding> listBindings (String root) throws NamingException
   {
      return new BindingEnumeration<Binding> (this, root);
   }

   public Object lookup (String pname) throws NameNotFoundException
   {
      String name = mRoot + ("".equals (mRoot)?"":"/") + pname;
      if ("".equals (name))
      {
         return new NamingContext (mRoot, mBoundObjects, mEnvironment);
      }
      Object found = mBoundObjects.get (name);
      if (found == null)
      {
         if (!name.endsWith ("/"))
         {
            name = name + "/";
         }
         for (Iterator<String> it = mBoundObjects.keySet ().iterator (); it.hasNext ();)
         {
            String boundName = it.next ();
            if (boundName.startsWith (name))
            {
               return new NamingContext (name, mBoundObjects, mEnvironment);
            }
         }
         throw new NameNotFoundException ("Name :" + mRoot + pname + " not bound; ");
      }
      return found;
   }

   public Object lookupLink (String name) throws NameNotFoundException
   {
      return lookup (name);
   }

   public void bind (String name, Object obj)
   {
      mBoundObjects.put (mRoot + ("".equals (mRoot)?"":"/") + name, obj);
   }

   public void unbind (String name)
   {
      mBoundObjects.remove (mRoot + ("".equals (mRoot)?"":"/") + name);
   }

   public void rebind (String name, Object obj)
   {
      bind (name, obj);
   }

   public void rename (String oldName, String newName) throws NameNotFoundException
   {
      Object obj = lookup (oldName);
      unbind (oldName);
      bind (newName, obj);
   }

   public Context createSubcontext (String name)
   {
      String newName = mRoot + ("".equals (mRoot)?"":"/") + name;
      Context subcontext = new NamingContext (newName, mBoundObjects, mEnvironment);
      bind (name, subcontext);
      return subcontext;
   }

   public void destroySubcontext (String name)
   {
      unbind (name);
   }

   public String composeName (String name, String prefix)
   {
      return prefix + name;
   }

   public Hashtable<String, Object> getEnvironment ()
   {
      return mEnvironment;
   }

   public Object addToEnvironment (String propName, Object propVal)
   {
      return mEnvironment.put (propName, propVal);
   }

   public Object removeFromEnvironment (String propName)
   {
      return mEnvironment.remove (propName);
   }

   public void close ()
   {
   }

   // no support for javax.naming.Name

   public NamingEnumeration<NameClassPair> list (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public NamingEnumeration<Binding> listBindings (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public Object lookup (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public Object lookupLink (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public void bind (Name name, Object obj) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public void unbind (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public void rebind (Name name, Object obj) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public void rename (Name oldName, Name newName) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public Context createSubcontext (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public void destroySubcontext (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public String getNameInNamespace () throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public NameParser getNameParser (Name name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public NameParser getNameParser (String name) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   public Name composeName (Name name, Name prefix) throws NamingException
   {
      throw new OperationNotSupportedException ("the use of javax.naming.Name is not supported");
   }

   private static abstract class AbstractNamingEnumeration<T> implements NamingEnumeration<T>
   {

      private Iterator<T> mIterator;

      private AbstractNamingEnumeration (NamingContext context, String proot) throws NamingException
      {
         if (!"".equals (proot) && !proot.endsWith ("/"))
         {
            proot = proot + "/";
         }
         String root = context.mRoot + proot;
         Map<String, T> contents = new HashMap<String, T> ();
         Iterator<String> it = context.mBoundObjects.keySet ().iterator ();
         while (it.hasNext ())
         {
            String boundName = it.next ();
            if (boundName.startsWith (root))
            {
               int startIndex = root.length ();
               int endIndex = boundName.indexOf ('/', startIndex);
               String strippedName = (endIndex != -1 ? boundName.substring (startIndex, endIndex) : 
                                                       boundName.substring (startIndex));
               if (!contents.containsKey (strippedName))
               {
                  try
                  {
                     contents.put (strippedName, createObject (strippedName, context.lookup (proot + strippedName)));
                  }
                  catch (NameNotFoundException ex)
                  {
                     // should never happen
                  }
               }
            }
         }
         if (contents.isEmpty ())
         {
            throw new NamingException ("Invalid root: " + context.mRoot + proot + "");
         }
         mIterator = contents.values ().iterator ();
      }

      protected abstract T createObject (String strippedName, Object obj);

      public boolean hasMore ()
      {
         return mIterator.hasNext ();
      }

      public T next ()
      {
         return mIterator.next ();
      }

      public boolean hasMoreElements ()
      {
         return mIterator.hasNext ();
      }

      public T nextElement ()
      {
         return mIterator.next ();
      }

      public void close ()
      {
      }
   }

   private static class NameClassPairEnumeration<T> extends AbstractNamingEnumeration<T>
   {

      private NameClassPairEnumeration (NamingContext context, String root) throws NamingException
      {
         super (context, root);
      }

      @SuppressWarnings ("unchecked")
      protected T createObject (String strippedName, Object obj)
      {
         return (T) new NameClassPair (strippedName, obj.getClass ().getName ());
      }
   }

   private static class BindingEnumeration<T> extends AbstractNamingEnumeration<T>
   {

      private BindingEnumeration (NamingContext context, String root) throws NamingException
      {
         super (context, root);
      }

      @SuppressWarnings ("unchecked")
      protected T createObject (String strippedName, Object obj)
      {
         return (T) new Binding (strippedName, obj);
      }
   }

}
