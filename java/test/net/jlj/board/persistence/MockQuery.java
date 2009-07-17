package net.jlj.board.persistence;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Stack;

import javax.persistence.FlushModeType;
import javax.persistence.TemporalType;

public class MockQuery implements javax.persistence.Query
{
   private static Stack<ExpectedResult> results = new Stack<ExpectedResult> ();
   private Params  params = new Params ();
   
   public static void pushResult (ExpectedResult r)
   {
      results.push (r);
   }
   
   @Override
   public int executeUpdate ()
   {
      // TODO Auto-generated method stub
      return 0;
   }

   @SuppressWarnings("unchecked")
   @Override
   public List getResultList ()
   {
      ExpectedResult result = results.pop ();
      Param param = result.mArgs;
      if ((param == null && params.get(0) == null) ||
               params.get (param.mIndex).mValue.equals (param.mValue))
      {
         return (List) result.mResult;
      }
      return null;
   }

   @Override
   public Object getSingleResult ()
   { 
      ExpectedResult result = results.pop ();
      Param param = result.mArgs;
      if ((param == null && params.isEmpty ()) ||
         (params.get (param.mIndex).mValue.equals (param.mValue)))
      {
         return result.mResult;
      }
      return null;
   }

   @Override
   public javax.persistence.Query setFirstResult (int arg0)
   {
      return this;
   }

   @Override
   public javax.persistence.Query setFlushMode (FlushModeType arg0)
   {
      return this;
   }

   @Override
   public javax.persistence.Query setHint (String arg0, Object arg1)
   {
      return this;
   }

   @Override
   public javax.persistence.Query setMaxResults (int arg0)
   {
      return this;
   }

   @Override
   public javax.persistence.Query setParameter (String arg0, Object arg1)
   {
      return this;
   }

   @Override
   public javax.persistence.Query setParameter (int arg0, Object arg1)
   {
      if (params == null)
      {
         params = new Params ();
      }
      params.add (new Param (arg0, arg1));
      return this;
   }

   @Override
   public javax.persistence.Query setParameter (String arg0, Date arg1, TemporalType arg2)
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public javax.persistence.Query setParameter (String arg0, Calendar arg1, TemporalType arg2)
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public javax.persistence.Query setParameter (int arg0, Date arg1, TemporalType arg2)
   {
      // TODO Auto-generated method stub
      return null;
   }

   @Override
   public javax.persistence.Query setParameter (int arg0, Calendar arg1, TemporalType arg2)
   {
      // TODO Auto-generated method stub
      return null;
   }
   /**
    * Value object -- attributes are public; no behaviour. 
    *
    */
   public static class Param
   {
      public int mIndex;
      public Object mValue;
      public Param (int idx, Object o)
      {
         mIndex = idx;
         mValue = o;
      }
   }
   /**
    * Value object -- attributes are public; no behaviour. 
    *
    */
   public static class ExpectedResult
   {
      public Param mArgs;
      public Object mResult; 
      
      public ExpectedResult (Param args, Object result)
      {
         mArgs = args;
         mResult = result;
      }
   }
   
   public static class Params 
   {
      private List<Param> args;
      public Params ()
      {
         args = new ArrayList<Param> ();
      }
      public void add (Param p)
      {
         args.add (p);
      }
      public Param get (int n)
      {
         Iterator<Param> iterator = args.iterator ();
         while (iterator.hasNext ())
         {
            Param p = iterator.next ();
            if (p.mIndex == n)
               return p;
         }
         return null;
      }
      public boolean isEmpty ()
      {
         return args == null || args.isEmpty ();
      }
   };
}
