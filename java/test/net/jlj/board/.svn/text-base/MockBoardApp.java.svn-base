package net.jlj.board;

import java.lang.reflect.Type;

import javax.persistence.EntityManagerFactory;

import org.picocontainer.DefaultPicoContainer;
import org.picocontainer.PicoCompositionException;
import org.picocontainer.PicoContainer;
import org.picocontainer.injectors.FactoryInjector;

import net.jlj.board.BoardApp;
import net.jlj.board.Facade;
import net.jlj.board.delegate.BoardDelegate;
import net.jlj.board.delegate.MemberDelegate;
import net.jlj.board.delegate.MockSettingsDelegate;
import net.jlj.board.delegate.SettingsDelegate;
import net.jlj.board.persistence.MockEntityManagerFactory;

public class MockBoardApp extends BoardApp
{

   public static class MockEmfInjector extends FactoryInjector<EntityManagerFactory> 
   {  
      private static EntityManagerFactory sFactory = new MockEntityManagerFactory ();
      public EntityManagerFactory getComponentInstance(PicoContainer container, final Type into) 
         throws PicoCompositionException 
      {  
          return sFactory;  
      }  
   };
     
   public MockBoardApp ()
   {
      super();
      mPico = new DefaultPicoContainer ();
   }
   public static void createInstance ()
   {
      mApp = new MockBoardApp ();
      ((MockBoardApp)mApp).initForTest ();
   }
   
   private void initForTest ()
   {
      DefaultPicoContainer pico = (DefaultPicoContainer) mPico;
      pico.addAdapter (new MockEmfInjector ());
      pico.addComponent (MemberDelegate.class, MemberDelegate.class);
      pico.addComponent (BoardDelegate.class, BoardDelegate.class);
      pico.addComponent (SettingsDelegate.class, MockSettingsDelegate.class);
      pico.addComponent (Facade.class);
   }   
   
}
