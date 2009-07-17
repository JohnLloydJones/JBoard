package net.jlj.board.delegate;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.persistence.EntityManagerFactory;
import javax.persistence.Query;

import net.jlj.board.BoardApp;
import net.jlj.board.metadata.Metadata;

public class SettingsDelegate extends AbstractDelegate
{
   private static Set<String> mState = new HashSet<String>();
   private static Set<String> mLogin = new HashSet<String>();
   private static Date mCachedTime = new Date (0);
   private static final long REFRESH_INTERVAL = 5 * 60 * 1000;
   private EntityManagerFactory mFactory;
   
   public SettingsDelegate (EntityManagerFactory emf)
   {
      /* The settings delegate needs to run with it's own EntityManager even if there is 
       * another EM created on this thread (to be able to close the EM cleanly). */
      mFactory = emf;
      mManager = mFactory.createEntityManager ();
   }
   
   @SuppressWarnings("unchecked")
   public List<Metadata> getStates ()
   {
      Query query = createNamedQuery ("meta_by_type");
      query.setParameter (1, "STATE");
      return query.getResultList ();      
   }
   
   @SuppressWarnings("unchecked")
   public List<Metadata> getLoginStates ()
   {
      Query query = createNamedQuery ("meta_by_type");
      query.setParameter (1, "LOGIN");
      return query.getResultList ();      
   }
   
   public static boolean stateContains (String state)
   {
      refreshIfStale ();
      return mState.contains (state);
   }
   public static boolean loginContains (String state)
   {
      refreshIfStale ();
      return mLogin.contains (state);
   }
   /**
    * States that can post are all LOGIN minus "validating"
    */
   public static boolean postContains (String state)
   {
      refreshIfStale ();
      return !"valdating".equals (state) && mLogin.contains (state);
      
   }
   private static Date cacheMetadata ()
   {
      SettingsDelegate delegate = null;
      try
      {
         delegate = BoardApp.getComponent (SettingsDelegate.class);
         List<Metadata> list = delegate.getStates ();
         HashSet <String> state = new HashSet<String> ();
         Iterator<Metadata> iterator = list.iterator ();
         while (iterator.hasNext ())
         {
            state.add (iterator.next().getValue());
         }
         synchronized (mState)
         {
            mState = state;
         }
         list  = delegate.getLoginStates ();
         HashSet<String> login = new HashSet<String> ();
         iterator = list.iterator ();
         while (iterator.hasNext ())
         {
            login.add (iterator.next().getValue());
         }
         synchronized (mLogin)
         {
            mLogin = login;
         }
      }
      finally
      {
         if ((mLogin.isEmpty () || mState.isEmpty ()) && delegate != null)
         {
            delegate.initializeMetadata ();
         }
         if (delegate != null)
         {
            delegate.close ();
         }
      }
      return new Date();
   }
   private static void refreshIfStale ()
   {
      if (new Date().getTime() > (mCachedTime.getTime () + REFRESH_INTERVAL))
      {
         mCachedTime = cacheMetadata ();
      }
   }
   /**
    * STATE_DATA and LOGIN_DATA are must have metadata, so seed them if they are not found.
    */
   private static final String[][] STATE_DATA = 
   {
      {"UNREGISTERED","unregistered", "Member has not registered"},
      {"VALIDATING",  "validating",   "Member has not completed registration"},
      {"MODERATED",   "moderated",    "Member has registered, but posts require moderating"},
      {"REGISTERED",  "registered",   "Member has registered"},
      {"BANNED",      "banned",       "Member has been banned"},
      {"DELETED",     "deleted",      "Member has been deleted"},
   };
   private static final String[][] LOGIN_DATA = 
   {
      {"VALIDATING",  "validating",   "Member has not completed registration"},
      {"MODERATED",   "moderated",    "Member has registered, but posts require moderating"},
      {"REGISTERED",  "registered",   "Member has registered"},
   };
   
   synchronized private void initializeMetadata ()
   {
      beginTx();
      if (mState.isEmpty ())
      {
         HashSet <String> state = new HashSet<String> ();
         for (int n = 0; n < STATE_DATA.length; n++)
         {
            String[] data = STATE_DATA [n];
            persist (new Metadata ("STATE", data[0], data[1], data [2]));  
            state.add (data[1]);
         }
         mState = state;
      }
      if (mLogin.isEmpty ())
      {
         HashSet <String> login = new HashSet<String> ();
         for (int n = 0; n < LOGIN_DATA.length; n++)
         {
            String[] data = LOGIN_DATA [n];
            persist (new Metadata ("LOGIN", data[0], data[1], data [2]));  
            login.add (data[1]);
         }
         mLogin = login;
      }
      commit ();
   }
}
