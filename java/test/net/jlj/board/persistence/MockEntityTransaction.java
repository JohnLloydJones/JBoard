package net.jlj.board.persistence;

public class MockEntityTransaction implements javax.persistence.EntityTransaction
{
   private boolean mActive;
   private boolean mRollbackOnly;
   
   @Override
   public void begin ()
   {
      if (mActive)
         throw new IllegalStateException ("Transaction is already open.");
      mActive = true;
   }

   @Override
   public void commit ()
   {
      if (!mActive)
         throw new IllegalStateException ("No transaction");
      mActive = false;
   }

   @Override
   public boolean getRollbackOnly ()
   {
      if (!mActive)
         throw new IllegalStateException ("No transaction");
      return mRollbackOnly;
   }

   @Override
   public boolean isActive ()
   {
      return mActive;
   }

   @Override
   public void rollback ()
   {
      if (!mActive)
         throw new IllegalStateException ("No transaction");
      mActive = false;
   }

   @Override
   public void setRollbackOnly ()
   {
      if (!mActive)
         throw new IllegalStateException ("No transaction");
      mRollbackOnly = true;
   }

}
