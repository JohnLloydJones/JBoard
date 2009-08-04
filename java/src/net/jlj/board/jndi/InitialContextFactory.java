package net.jlj.board.jndi;

import java.util.Hashtable;

import javax.naming.Context;
import javax.naming.NamingException;

/**
 * Minimal InitialContextFactory implementation.
 * @author john
 *
 */
public class InitialContextFactory implements javax.naming.spi.InitialContextFactory
{
   @SuppressWarnings ("unchecked")
   @Override
   public Context getInitialContext (Hashtable <?, ?> env) throws NamingException
   {
      Context ctx = new LocalContextRoot ((Hashtable <String, Object>) env);
      ctx.createSubcontext ("java:comp"); // we are creating a jndi name context, so put this in now.
      return ctx;
   }

}
