package net.jlj.board.persistence;

import java.util.Map;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;

public class MockEntityManagerFactory implements EntityManagerFactory
{
   public MockEntityManagerFactory ()
   {
      System.out.println ("MockEntityManagerFactory c'tor");
   }
   @Override
   public void close ()
   {

   }

   @Override
   public EntityManager createEntityManager ()
   {
      return new MockEntityManager ();
   }

   @Override
   public EntityManager createEntityManager (Map arg0)
   {
      return new MockEntityManager ();
   }

   @Override
   public boolean isOpen ()
   {
      return true;
   }
}
