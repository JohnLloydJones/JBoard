package net.jlj.board.delegate;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.EntityManagerFactory;

import net.jlj.board.metadata.Metadata;

public class MockSettingsDelegate extends SettingsDelegate
{
   public MockSettingsDelegate (EntityManagerFactory emf)
   {
      super (emf);
   }
   
   public List<Metadata> getStates ()
   {
      List<Metadata> states = new ArrayList<Metadata> ();
      states.add (new Metadata("STATE", "UNREGISTERED", "unregistered", "Member has not registered"));
      states.add (new Metadata("STATE", "VALIDATING",   "validating", "Member has not completed registering"));
      states.add (new Metadata("STATE", "MODERATED", "moderated", "Member is registered, but posts require moderating"));
      states.add (new Metadata("STATE", "REGISTERED",   "registered", "Member has registered"));
      states.add (new Metadata("STATE", "BANNED", "banned", "Member has been banned"));
      states.add (new Metadata("STATE", "DELETED", "deleted", "Member has been deleted"));
      return states;
   }
   
   public List<Metadata> getLoginStates ()
   {
      List<Metadata> states = new ArrayList<Metadata> ();
      states.add (new Metadata("LOGIN", "VALIDATING",   "validating", "Member has not completed registering"));
      states.add (new Metadata("LOGIN", "MODERATED", "moderated", "Member is registered, but posts require moderating"));
      states.add (new Metadata("LOGIN", "REGISTERED", "registered", "Member has registered"));
      return states;
   }
   
}
