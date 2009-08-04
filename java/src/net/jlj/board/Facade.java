package net.jlj.board;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;

import net.jlj.board.delegate.BoardDelegate;
import net.jlj.board.delegate.MemberDelegate;
import net.jlj.board.delegate.SettingsDelegate;
import net.jlj.board.dom.Board;
import net.jlj.board.dom.Category;
import net.jlj.board.dom.DomEntity;
import net.jlj.board.dom.Event;
import net.jlj.board.dom.Forum;
import net.jlj.board.dom.Link;
import net.jlj.board.dom.Member;
import net.jlj.board.dom.Message;
import net.jlj.board.dom.Post;
import net.jlj.board.dom.Topic;
/**
 * Single interface to the JBoard back end.  
 * @author john
 *
 */
public class Facade
{
   private static Logger log = Logger.getLogger (Facade.class.getName ());
   private MemberDelegate mMemberDelegate;
   private BoardDelegate  mBoardDelegate;
   private Member mLoggedOnAs;
   
   /**
    * Delegates are injected into the constructor. 
    */
   public Facade (MemberDelegate mdelegate, BoardDelegate bdelegate)
   {
      mMemberDelegate = mdelegate;
      mBoardDelegate = bdelegate;
   }
   public static Facade getInstance ()
   {
      return BoardApp.getComponent (Facade.class);
   }
   public static Facade getInstance (Member user)
   {
      Facade facade = BoardApp.getComponent (Facade.class);
      facade.mLoggedOnAs = user;
      return facade;
   }
   public static Facade getInstance (String name)
   {
      Facade facade = BoardApp.getComponent (Facade.class);
      facade.setLoggedOnUser (name);
      return facade;
   }
   
   /* ======== Member methods ======== */
   public Member getUser (String name)
   {
      return name == null ? null : mMemberDelegate.getUser (name.trim ());
   }
   public Member getUser (long id)
   {
      return mMemberDelegate.find (Member.class, id);
   }
   public Member getUserByEmail (String email)
   {
      return mMemberDelegate.getUserByEmail (email);
   }
   public Member getValidatedUser ()
   {
      return mLoggedOnAs;
   }
   public boolean hasPostRights ()
   {
      return hasPostRights (mLoggedOnAs);
   }
   public boolean hasPostRights (Member member)
   {
      return member != null && SettingsDelegate.postContains (member.getState ());
   }
   public boolean isModerated ()
   {
      return isModerated (mLoggedOnAs);
   }
   public boolean isModerated (Member member)
   {
      return "moderated".equals (member.getState ());
   }
   public boolean isAdmin ()
   {
      return mLoggedOnAs.isAdmin ();
   }
   public boolean isAdmin (String name)
   {
      return getUser(name).isAdmin ();  
   }
   public boolean validateUser (String name, String password)
   {
      mLoggedOnAs = mMemberDelegate.getValidatedUser (name, password);
      boolean ok = mLoggedOnAs != null 
          && SettingsDelegate.loginContains (mLoggedOnAs.getState ());
      return ok;
   }
   public List<Member> getAllMembers ()
   {
      return mMemberDelegate.getMembers ("%");
   }
   public List<Member> getMembers (String filter)
   {
      return mMemberDelegate.getMembers (filter);
   }
   public List<Member> getAdmins ()
   {
      return mMemberDelegate.getAdmins ();
   }
   public List<String> getModerators (long category_id)
   {
      Category category = getCategory (category_id);
      return category.getModerators ();
   }
   public void addLink (Link link)
   {
      mMemberDelegate.addLink (mLoggedOnAs, link);
   }
   public void removeLink (Link link)
   {
      mMemberDelegate.removeLink (mLoggedOnAs, link);
   }
   
   /* ======== Board methods ======== */
   public Board getBoard ()
   {
      return mBoardDelegate.getBoard ("main");
   }
   public Category getCategory (long id)
   {
      return mBoardDelegate.find (Category.class, id);
   }
   public Category getCategoryForForum (long forum_id)
   {
      return mBoardDelegate.getCategoryForForum (forum_id);
   }
   public Category getCategoryForTopic (long topic_id)
   {
      return mBoardDelegate.getCategoryForTopic (topic_id);
   }
   public Forum getForum (long id)
   {
      return mBoardDelegate.find (Forum.class, id);
   }
   public Topic getTopic (long id)
   {
      return mBoardDelegate.find (Topic.class, id);
   }
   public Post getPost (long id)
   {
      return mBoardDelegate.find (Post.class, id);
   }
   public Message getMessage (long id)
   {
      return mBoardDelegate.find (Message.class, id);
   }
   public Event getEvent (long id)
   {
      return mBoardDelegate.find (Event.class, id);
   }
   public Link getLink (long id)
   {
      return mBoardDelegate.find (Link.class, id);
   }
   
   
   public Forum getForumForTopic (long id)
   {
      return mBoardDelegate.getForumForTopic (id);
   }
   public Topic getTopicForPost (long id)
   {
      return mBoardDelegate.getTopicForPost (id);
   }
   public List<Topic> getTopicsForForum (Long id, int offset, int maxposts)
   {
      return  mBoardDelegate.getTopicsForForum (id, offset, maxposts);
   }
   public List<Post> getPostsForTopic (Long id, int offset, int maxposts)
   {
      return mBoardDelegate.getPostsForTopic (id, offset, maxposts);
   }
   public List<Post> getPostsForUser (String name, Date from)
   {
      return mBoardDelegate.getPostsForUser (name, from);
   }
   public List<Event> getEventsForUser (String name)
   {
      return mBoardDelegate.getEventsForUser (name);
   }
   public Post getLastPostForTopic (long id)
   {
      return mBoardDelegate.getLastPostForTopic (id);
   }
   public int getNumberOfPosts (String user)
   {
      return mMemberDelegate.getNumberOfPosts (user);
   }
   
   public void addPost (long topicId, String text)
   {
      if (!hasPostRights ())
         return;
      Topic topic = getTopic (topicId);
      mBoardDelegate.addPost (topic, mLoggedOnAs, text);
   }
   public void addTopic (long forumId, Topic topic, String text)
   {
      if (!hasPostRights ())
         return;
      Forum forum = getForum (forumId);
      mBoardDelegate.addTopic (forum, topic, mLoggedOnAs, text);
   }
   public void approvePost (long post_id)
   {
      Post post = getPost (post_id);
      mBoardDelegate.approvePost (post, mLoggedOnAs);
   }
   public void reportPost (long post_id, String reason)
   {
      Topic topic = getTopicForPost (post_id);
      Category category = getCategoryForTopic (topic.getId ());
      Set<Member> recipients = new HashSet<Member> (getAdmins());
      recipients.addAll (getMembers (category.getModerators ()));
      
      mBoardDelegate.sendPrivateMessage (mLoggedOnAs, recipients, reason, "report post " + post_id);
   }
   public void postPublicMessage (String message)
   {
      log.debug ("Post public message from " + mLoggedOnAs.getName() + " : «" + message + "»");
      mBoardDelegate.postPublicMessage (mLoggedOnAs, message);
   }
   public void sendPrivateMessage (List<String> users, String message)
   {
      Set<Member> recipients = new HashSet<Member> ();
      recipients.addAll (getMembers (users));
      log.debug ("Send private message to " + users.size () + " recipients: «" + message + "»");
      mBoardDelegate.sendPrivateMessage (mLoggedOnAs, recipients, message, "PM");
   }
   public void sendSystemMessage (String name, String msgText, String eventText)
   {
      Member member = getUser(name);
      if (member != null)
      {
         log.debug ("Send system message to " + name + " : «" + msgText + "»");
         mBoardDelegate.sendSystemMessage (mLoggedOnAs, member, msgText, eventText);
      }
      else
      {
         log.error ("Attempt to send system message to non-existent user " + name);
      }
   }
   public Set<Member> getMembers (List<String> names)
   {
      Set<Member> members = new HashSet<Member> ();
      Iterator<String> iterator = names.iterator ();
      while (iterator.hasNext ())
      {
         members.add (getUser (iterator.next ()));
      }
      return members;
   }
   public void setLoggedOnUser (String user)
   {
      Member member = getUser (user);
      if (SettingsDelegate.loginContains (member.getState ()))
      {
         mLoggedOnAs = member;
      }
   }
   public void commit () throws Exception
   {
      try
      {
         mBoardDelegate.commit ();
      }
      catch (Exception e)
      {
         e.printStackTrace();
         throw e;
      }
   }
   public void flush ()
   {
      mBoardDelegate.flush ();
   }
   public void close ()
   {
      mMemberDelegate.close ();
      mBoardDelegate.close ();
   }
   public void beginTx ()
   {
      // Doesn't actually matter which delegate, because the work is performed by the 
      // same EntityManager.
      mBoardDelegate.beginTx (); 
   }
   public void remove (Object o)
   {
      if (o instanceof Member)
      {
         Member m = (Member)o;
         if ("root".equalsIgnoreCase (m.getName()) && getUser ("root") != null)
         {
            log.error ("attempt to delete root");
            throw new RuntimeException ("Root user exists and is immutable");
         }
         if (mLoggedOnAs != null && !("root".equals (mLoggedOnAs.getName ()) || mLoggedOnAs.isAdmin ()))
         {
            if (m.getCreatedBy () != null && !m.getCreatedBy ().equalsIgnoreCase (mLoggedOnAs.getName ()))
            {
               log.error ("attempt to delete a user by a non admin");
               throw new RuntimeException ("Only an admin can delete this user");
            }
         }
      }
//      if (((DomEntity)o).isLocked ())
//      {
//         
//      }
      // Doesn't actually matter which delegate, because the work is performed by the same EntityManager.
      mBoardDelegate.beginTx (); 
      mBoardDelegate.remove (o);
   }
   public void persist (Member m)
   {
      // root is only used by scripts and is immutable from the UI
      if ("root".equalsIgnoreCase (m.getName()))
      {
         throw new RuntimeException ("Root user exists and is immutable");
      }
      if (mLoggedOnAs != null && !(mLoggedOnAs.isAdmin ()))
      {
         if (m.getCreatedBy () != null && !m.getCreatedBy ().equalsIgnoreCase (mLoggedOnAs.getName ()))
         {
            throw new RuntimeException ("Only an admin can add or modify this user");
         }
      }
      persist ((DomEntity) m);
   }
   public void persist (DomEntity e)
   {
      if (e.isLocked () && !mLoggedOnAs.isAdmin ())
      {
         throw new RuntimeException ("The object is locked and requires admin privileges to unlock");
      }
      persist ((Object) e);
   }
   public void persist (Object o)
   {
      // Doesn't actually matter which delegate, because the work is performed by the same EntityManager.
      mBoardDelegate.beginTx (); 
      mBoardDelegate.persist (o);
   }
   

}
