package net.jlj.board.delegate;

import java.util.Date;

import net.jlj.board.BoardApp;
import net.jlj.board.MockBoardApp;
import net.jlj.board.dom.Category;
import net.jlj.board.dom.Forum;
import net.jlj.board.dom.Member;
import net.jlj.board.dom.Message;
import net.jlj.board.dom.Post;
import net.jlj.board.dom.Topic;
import net.jlj.board.persistence.MockQuery;
import junit.framework.TestCase;

public class BoardDelegateTest extends TestCase
{
   private static final String TEST_USER1 = "testuser1";
   private static final String TEST_USER2 = "testuser2";
   private static final String LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exercitation ulliam corper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem veleum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel willum lunombro dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.";
   private long mSeqNum;
   private Member reg_user;
   private Member mod_user;
   private Member admin_user;
   
   protected void setUp () throws Exception
   {
      super.setUp ();
      MockBoardApp.createInstance (); // Setup for unit tests
      mSeqNum = 1000;
      reg_user = new Member ();
      reg_user.setCreated (new Date());
      reg_user.setCreatedBy ("root");
      reg_user.setName (TEST_USER1);
      reg_user.setGroup ("member");
      reg_user.setState ("registered");
      
      mod_user = new Member ();
      mod_user.setCreated (new Date());
      mod_user.setCreatedBy ("root");
      mod_user.setName (TEST_USER2);
      mod_user.setGroup ("member");
      mod_user.setState ("moderated");
      
      admin_user = new Member ();
      admin_user.setCreated (new Date());
      admin_user.setCreatedBy ("root");
      admin_user.setName ("admin");
      admin_user.setGroup ("admin");
      admin_user.setState ("registered");
      
   }

   protected void tearDown () throws Exception
   {
      super.tearDown ();
   }

   public void testMoveTo ()
   {
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      Topic from = createTopic (next_value(), "From topic");
      Topic to = createTopic (next_value(), "To topic");
      Message msg = createMessage ();
      Post post = createPost ();
      post.setBodyId (msg.getId());
      from.addPost (post);
      
      /* getLastPostForTopic (toTopic.getId ()) */
      MockQuery.Param param1 = new MockQuery.Param (1, to.getId());
      MockQuery.ExpectedResult result1 = new MockQuery.ExpectedResult (param1, post); // should have one after move 
      MockQuery.pushResult (result1);
      
      /* getLastPostForTopic (fromTopic.getId ()) */
      MockQuery.Param param2 = new MockQuery.Param (1, from.getId());
      MockQuery.ExpectedResult result2 = new MockQuery.ExpectedResult (param2, null); // would be empty after move
      MockQuery.pushResult (result2);
      
      MockQuery.Param param3 = new MockQuery.Param (1, post.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, from); 
      MockQuery.pushResult (result3);
      
      
      delegate.moveTo (to, post);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertEquals ("Expect the from topic to have zero posts", 0, from.getPosts ().size ());
      assertEquals ("Expect the to topic to have one posts", 1, to.getPosts ().size ());
      assertEquals ("Expect the from last post id to be zero", 0, from.getLastPostId ());
      assertEquals ("Expect the to last post id to be set", post.getId (), to.getLastPostId ());
      
   }

   public void testAddPendingPost ()
   {
      Topic topic = createTopic (next_value(), "Topic with new post");
      Category category = new Category ();
      category.setId (next_value ());
      category.setTitle ("Category with pending post");
      
      // getCategoryForTopic (id) 
      MockQuery.Param param3 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, category); 
      MockQuery.pushResult (result3);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      delegate.addPost (topic, mod_user, LOREM_IPSUM);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertEquals ("Expect the category pending list to have one entry", 1, category.getPendingPosts ().size());
      Post pending = category.getPendingPosts ().get (0);
      assertEquals ("Expect the post to have the 'topic_id' set", pending.getProperty ("topic_id"), String.valueOf (topic.getId()));
   }

   public void testAddPost ()
   {
      Topic topic = createTopic (next_value(), "Topic with new post");
      Forum forum = new Forum ();
      forum.setId (next_value ());
      forum.setTitle ("Forum with new");
      forum.addTopic (topic);
      
      long post_id = next_value();
      Post post = new Post ();
      post.setId (post_id);

      /* getLastPostForTopic (toTopic.getId ()) */
      MockQuery.Param param1 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result1 = new MockQuery.ExpectedResult (param1, post); // should have one after move 
      MockQuery.pushResult (result1);
      
      /* getForumForTopic (id) */
      MockQuery.Param param3 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, forum); 
      MockQuery.pushResult (result3);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      delegate.addPost (topic, reg_user, LOREM_IPSUM);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertEquals ("Expect the topic posts list to have one entry", 1, topic.getPosts ().size());
      Post added_post = topic.getPosts ().get (0);
      assertEquals ("Expect the last post id to be the one added", added_post.getId (), topic.getLastPostId ());
   //   assertEquals ("Expect the last topic updated to be the topic the post was added to", topic.getId(), forum.getLastTopicUpdated ());
   }

   public void testAddTopic ()
   {
      Topic topic = createTopic (next_value(), "New topic with new post");
      
      Forum forum = new Forum ();
      forum.setId (next_value ());
      forum.setTitle ("Forum with new topic and post");

      /* getForumForTopic (id) */
      MockQuery.Param param3 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, forum); 
      MockQuery.pushResult (result3);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      delegate.addTopic (forum, topic, reg_user, LOREM_IPSUM);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertEquals ("Expect the forum to have one topic", 1, forum.getTopics ().size());
      Topic added_topic = forum.getTopics ().get (0);
      assertEquals ("Expect this topic to be public", "public", added_topic.getState ());
      assertEquals ("Expect the topic to have one post", 1, added_topic.getPosts ().size());
//      assertEquals ("Expect the last topic updated to be the topic the post was added to", added_topic.getId(), forum.getLastTopicUpdated ());
   }

   public void testAddPendingTopic ()
   {
      Topic topic = createTopic (next_value(), "New topic with new post");
      
      Forum forum = new Forum ();
      forum.setId (next_value ());
      forum.setTitle ("Forum with new topic and post");
      
      
      Category category = new Category ();
      category.setId (next_value ());
      category.setTitle ("Category with pending post");
      
      /* getCategoryForTopic (forum.getId ()); */
      MockQuery.Param param3 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, category); 
      MockQuery.pushResult (result3);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      delegate.addTopic (forum, topic, mod_user, LOREM_IPSUM);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertEquals ("Expect the category pending list to have one entry", 1, category.getPendingPosts ().size());
      assertEquals ("Expect the forum to have one topic", 1, forum.getTopics ().size());
      Topic added_topic = forum.getTopics ().get (0);
      assertEquals ("Expect this topic to be hidden", "hidden", added_topic.getState ());
      
      assertEquals ("Expect the pending list to have one post", 1, category.getPendingPosts ().size());
      
      Post pending = category.getPendingPosts ().get (0);
      assertEquals ("Expect the post to have the 'topic_id' set", pending.getProperty ("topic_id"), String.valueOf (topic.getId()));
      assertEquals ("Expect this post to be hidden", "hidden", pending.getState ());
   }

   public void testApprovePostFail ()
   {
      Topic topic = createTopic (next_value(), "Topic with pending post");
      topic.setState ("hidden");
      Message msg = createMessage ();
      Post post = createPost ();
      post.setState ("hidden");
      post.setProperty ("topic_id", String.valueOf (topic.getId ()));
      post.setBodyId (msg.getId());
      
      Forum forum = new Forum ();
      forum.setId (next_value ());
      forum.setTitle ("Forum with pending post");
      forum.addTopic (topic);
      
      Category category = new Category ();
      category.setId (next_value ());
      category.setTitle ("Category with pending post");
      category.addForum (forum);
      category.addToPending (post);
      
      /* getCategoryForTopic (id) */
      MockQuery.Param param0 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result0 = new MockQuery.ExpectedResult (param0, category); 
      MockQuery.pushResult (result0);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      
      delegate.approvePost (post, reg_user);
      assertEquals ("Expect the topic to still be hidden", "hidden", topic.getState ());
      assertEquals ("Expect the post to still be hidden", "hidden", post.getState ());
      assertEquals ("Expect the post to still be in the category pending list", 1, category.getPendingPosts ().size());
   }
   
   public void testApprovePostAdmin ()
   {
      Topic topic = createTopic (next_value(), "Topic with pending post");
      topic.setState ("hidden");
      Message msg = createMessage ();
      Post post = createPost ();
      post.setState ("hidden");
      post.setProperty ("topic_id", String.valueOf (topic.getId ()));
      post.setBodyId (msg.getId());
      
      Forum forum = new Forum ();
      forum.setId (next_value ());
      forum.setTitle ("Forum with pending post");
      forum.addTopic (topic);
      
      Category category = new Category ();
      category.setId (next_value ());
      category.setTitle ("Category with pending post");
      category.addForum (forum);
      category.addToPending (post);
      
      /* getForumForTopic (id); */
      MockQuery.Param param1 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result1 = new MockQuery.ExpectedResult (param1, forum);  
      MockQuery.pushResult (result1);
      

      /* find (Topic.class, id); */
      MockQuery.ExpectedResult result2 = new MockQuery.ExpectedResult (null, topic); 
      MockQuery.pushResult (result2);
      
      
      /* getCategoryForTopic (id) */
      MockQuery.Param param3 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, category); 
      MockQuery.pushResult (result3);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      delegate.approvePost (post, admin_user);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertTrue ("Expect to find post in the topic", topic.getPosts ().contains (post));
      assertEquals ("Expect the topic to be public", "public", topic.getState ());
      assertEquals ("Expect the post to be public", "public", post.getState ());
      assertEquals ("Expect the category pending list to be empty", 0, category.getPendingPosts ().size());
      
   }
   public void testApprovePostModerator ()
   {
      Topic topic = createTopic (next_value(), "Topic with pending post");
      topic.setState ("hidden");
      Message msg = createMessage ();
      Post post = createPost ();
      post.setState ("hidden");
      post.setProperty ("topic_id", String.valueOf (topic.getId ()));
      post.setBodyId (msg.getId());
      
      Forum forum = new Forum ();
      forum.setId (next_value ());
      forum.setTitle ("Forum with pending post");
      forum.addTopic (topic);
      
      Category category = new Category ();
      category.setId (next_value ());
      category.setTitle ("Category with pending post");
      category.addForum (forum);
      category.addToPending (post);
      category.addModerator (reg_user); // Set as moderator for this category
      
      /* getForumForTopic (id); */
      MockQuery.Param param1 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result1 = new MockQuery.ExpectedResult (param1, forum);  
      MockQuery.pushResult (result1);
      

      /* find (Topic.class, id); */
      MockQuery.ExpectedResult result2 = new MockQuery.ExpectedResult (null, topic); 
      MockQuery.pushResult (result2);
      
      
      /* getCategoryForTopic (id) */
      MockQuery.Param param3 = new MockQuery.Param (1, topic.getId());
      MockQuery.ExpectedResult result3 = new MockQuery.ExpectedResult (param3, category); 
      MockQuery.pushResult (result3);
      
      BoardDelegate delegate = BoardApp.getComponent (BoardDelegate.class);
      delegate.approvePost (post, reg_user);
      
      assertTrue ("Expect a transaction to be active", delegate.isTxActive ());
      assertTrue ("Expect to find post in the topic", topic.getPosts ().contains (post));
      assertEquals ("Expect the topic to be public", "public", topic.getState ());
      assertEquals ("Expect the post to be public", "public", post.getState ());
      assertEquals ("Expect the category pending list to be empty", 0, category.getPendingPosts ().size());
      
   }
   
   
   private Topic createTopic (long id, String title)
   {
      Topic topic = new Topic ();
      topic.setId (id);
      topic.setTitle (title);
      topic.setCreatedBy (reg_user.getName ());
      topic.setCreated (new Date ());
      return topic;
   }
   private Post createPost ()
   {
      
      Post post = new Post ();
      post.setId (next_value ());
      post.setCreatedBy (reg_user.getName ());
      post.setCreated (new Date ());
      return post;
      
   }
   private Message createMessage ()
   {
      Message msg = new Message (reg_user.getName (), LOREM_IPSUM);
      msg.setId (next_value ());
      return msg;
   }
   private long next_value ()
   {
      return mSeqNum++;
   }
}
