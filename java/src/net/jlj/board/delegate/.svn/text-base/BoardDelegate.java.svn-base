package net.jlj.board.delegate;

import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.persistence.EntityManagerFactory;
import javax.persistence.Query;

import org.apache.log4j.Logger;

import net.jlj.board.dom.Board;
import net.jlj.board.dom.Category;
import net.jlj.board.dom.Event;
import net.jlj.board.dom.Forum;
import net.jlj.board.dom.Member;
import net.jlj.board.dom.Message;
import net.jlj.board.dom.Post;
import net.jlj.board.dom.Topic;

public class BoardDelegate extends AbstractDelegate
{
   private static Logger log = Logger.getLogger (BoardDelegate.class.getName ());
   
   public static final String LAST_POST_FOR_TOPIC = "select distinct p.id, p.title, p.description, p.locked, p.state, " +
   		"p.created, p.created_by, p.body_id, p.previous_id, p.version from post p, topic_post tp " +
   		"where (select MAX(p.created) from post p, topic_post tp where tp.topic_id = ?1 and tp.mposts_id = p.id) = p.created " +
   		"and tp.topic_id = ?1";
   public static final String CATEGORY_FOR_TOPIC = "select distinct c.id, c.title, c.description, c.locked, c.state, c.created, c.created_by from " +
   "category c, category_forum cf, forum_topic ft " +
   "where c.id = cf.category_id and cf.mforums_id = ft.forum_id and ft.mtopics_id = ?1";

   public static final String CATEGORY_FOR_FORUM = "select distinct c.id, c.title, c.description, c.locked, c.state, c.created, c.created_by from " +
   "category c, category_forum cf " +
   "where c.id = cf.category_id and cf.mforums_id = ?1";
   
   public BoardDelegate (EntityManagerFactory emf)
   {
      super(emf);
   }
   public void moveTo (Topic toTopic, Post post)
   {
      beginTx();
      Topic fromTopic = getTopicForPost (post.getId ());
      fromTopic.removePost (post);
      fromTopic.updateLastPost (getLastPostForTopic (fromTopic.getId ()));
      toTopic.addPost (post);
      toTopic.updateLastPost (getLastPostForTopic (toTopic.getId ()));
   }
   public List<Category> getCategories ()
   {
      return getBoard ("%").getCategories ();
   }
   public Category getCategoryForForum (long id)
   {
      Query q = createNativeQuery(CATEGORY_FOR_FORUM, Category.class);
      q.setParameter (1, id);
      Category result = (Category)q.getSingleResult ();
      return result;
   }
   public Category getCategoryForTopic (long id)
   {
      Query q = createNativeQuery(CATEGORY_FOR_TOPIC, Category.class);
      q.setParameter (1, id);
      Category result = (Category)q.getSingleResult ();
      return result;
   }
   public Topic getTopicForPost (long id)
   {
      Query q = createNamedQuery("topic_for_post");
      q.setParameter (1, id);
      Topic result = (Topic)q.getSingleResult ();
      return result;
   }
   
   public Forum getForumForTopic (long id)
   {
      Query q = createNamedQuery("forum_for_topic");
      q.setParameter (1, id);
      Forum result = (Forum)q.getSingleResult ();
      return result;
   }      
   public Post getLastPostForTopic (long id)
   {
      Query q = createNativeQuery(LAST_POST_FOR_TOPIC, Post.class);
      q.setParameter (1, id);
      Post result = (Post)q.getSingleResult ();
      return result;
   }
   @SuppressWarnings("unchecked")
   public List<Topic> getTopicsForForum (Long id, int offset, int maxposts)
   {
      Query q = createNamedQuery("topics_for_forum");
      q.setParameter (1, id);
      q.setFirstResult (offset);
      q.setMaxResults (maxposts);
      List<Topic> results = q.getResultList (); 
      return results;
   }
   @SuppressWarnings("unchecked")
   public List<Post> getPostsForTopic (Long id, int offset, int maxposts)
   {
      Query q = createNamedQuery("posts_for_topic");
      q.setParameter (1, id);
      q.setFirstResult (offset);
      q.setMaxResults (maxposts);
      List<Post> results = q.getResultList (); 
      return results;
   }
   @SuppressWarnings ("unchecked")
   public List<Post> getPostsForUser (String name, Date from)
   {
      Query q = createNamedQuery("posts_for_user");
      q.setParameter (1, name);
      q.setParameter (2, from);
      q.setMaxResults (10);
      List<Post> results = q.getResultList (); 
      return results;
   }
   @SuppressWarnings ("unchecked")
   public List<Event> getEventsForUser (String name)
   {
      Query q = createNamedQuery("events_for_user");
      q.setParameter (1, name);
      q.setMaxResults (15);
      List<Event> results = q.getResultList (); 
      return results;
   }
   public Category getCategory (String name)
   {
      Query q = createNamedQuery("category");
      q.setParameter (1, name);
      Category result = (Category) q.getSingleResult();
      return result;
   }
   
   @SuppressWarnings("unchecked")
   public Board getBoard (String name)
   {
      List <Board> results;
      try
      {
         Query q = createNamedQuery("board");
         q.setParameter (1, name);
         results = q.getResultList();
      }
      catch (Exception e)
      {
         log.error (e);
         throw new RuntimeException (e);
      }
      /* There must be one primary board; leave open possibility to have secondary board(s) */
      return results.size () > 0 ? results.get (0) : null;
   }
   
   public void addPost (Topic topic, Member user, String text)
   {
      beginTx();
      boolean moderated = "moderated".equals (user.getState ());
      
      Message message = new Message (user.getName (), text);
      persist (message);
      flush ();
      
      Post post = new Post ();
      post.setCreatedBy (user.getName ());
      post.setBodyId (message.getId ());
      post.setState (moderated ? "hidden" : "public");
      persist (post);
      
      if ("moderated".equals (user.getState ()))
      {
         post.setProperty ("topic_id", String.valueOf (topic.getId()));
         Category category = getCategoryForTopic (topic.getId());
         category.addToPending (post);
         
         Message msg = new Message (user.getName (), "Thanks! Your post has been place in the moderation queue and will show in the forum once a moderator has approved it.");
         msg.setCreatedBy ("root");
         persist (msg);
         flush ();
         Event event = new Event ();
         event.setCreatedBy ("root");
         event.setPrivateMessage (msg, user);
         persist (event);
      }
      else
      {
         topic.addPost (post);
//         Forum forum = getForumForTopic (topic.getId ());
//         forum.setLastTopicUpdated (topic.getId ());
      }
   }

   public void addTopic (Forum forum, Topic topic, Member user, String text)
   {
      beginTx();
      boolean moderated = "moderated".equals (user.getState ());
      topic.setState (moderated? "hidden" : "public");
      topic.setCreatedBy (user.getName ());
      persist (topic);
      flush ();
      
      forum.addTopic (topic);
      addPost (topic, user, text);
      flush ();
      
      if (!moderated)
      {
//         forum.setLastTopicUpdated (topic.getId ());
      }
   }
   public void postPublicMessage (Member from, String msgText)
   {
      beginTx();
      Message message = new Message (from.getName (), msgText);
      persist (message);
      log.debug ("Sending public message from " + from.getName ());
      flush ();
      Event event = new Event (from.getName ());
      event.setPublicMessage (message);
      event.setText ("public msg");
      persist (event);
   }
   public void sendPrivateMessage (Member from, Set<Member> recipients, String msgText, String eventText)
   {
      beginTx();
      Message message = new Message (from.getName (), msgText);
      persist (message);
      log.debug ("Sending private message from " + from.getName ());
      flush ();
      Iterator<Member> iterator = recipients.iterator ();
      while (iterator.hasNext ())
      {
         Member member = iterator.next ();
         if (member == null)
            continue;
         Event event = new Event (from.getName ());
         event.setPrivateMessage (message, member);
         event.setText (eventText);
         persist (event);
      }
   }
   public void sendSystemMessage (Member from, Member recipient, String msgText, String eventText)
   {
      beginTx();
      Message message = new Message (from.getName (), msgText);
      persist (message);
      log.debug ("Sending system message from " + from.getName ());
      flush ();
      
      Event event = new Event (from.getName ());
      event.setSystemMessage (message, recipient, eventText);
      persist (event);
   }
   public void approvePost (Post post, Member user)
   {
      beginTx();
      
      long topic_id = 0;
      try
      {
         topic_id = Long.parseLong (post.getProperty ("topic_id"));
      }
      catch (NumberFormatException e)
      {
         // Swallow. 
      }
      Category category = getCategoryForTopic (topic_id);
      if (category == null)
         return;
      if (user.isAdmin () || category.isModerator (user.getName ()))
      {
         post.setState ("public");
         Topic topic = find (Topic.class, topic_id);
         topic.setState ("public");
         category.removeFromPending (post);
         topic.addPost (post);
         topic.updateLastPost (post);
         
//         Forum forum = getForumForTopic (topic_id);
//         forum.setLastTopicUpdated (topic.getId ());
      }
   }
}
