package net.jlj.board.tools;

import java.util.Date;
import java.util.HashMap;

import net.jlj.board.BoardApp;
import net.jlj.board.Facade;
import net.jlj.board.dom.Board;
import net.jlj.board.dom.Category;
import net.jlj.board.dom.Forum;
import net.jlj.board.dom.Member;
import net.jlj.board.dom.Message;
import net.jlj.board.dom.Post;
import net.jlj.board.dom.Topic;

public class Install
{
   private static final String ROOT = "root";  /* Do not change this */
   private static final String ADMIN_NAME = "admin";
   private static final String ROOT_PASSWORD  = "qCew4lAGe5nFzm1bKBtAOgGMfErzFj9reMw+nzsGRDU=";
   private static final String ADMIN_PASSWORD = "Zq2t2jHbIpNl3YQBrtyo1awZGLQpoTIvg03O8Mok9KQ=";
   private static final String GUEST_PASSWORD = "yTQragNe4STclJsGoH7NbZ6fmyP0fEdSnIt4pEwkyCg=";
   Facade facade;
   public void createAdmin ()
   {
      Member root = facade.getUser (ROOT);
      if (root != null)
      {
         throw new RuntimeException ("You must drop the existing board to run the installation.");
      }
      /* Create three users:
       * root: Only used by install/maintenance tools; login from UI is blocked.
       * admin: The administrator user; pre-registered.
       * guest: The default user for unregistered access.
       */
      root = new Member ();
      root.setName (ROOT);
      root.setPassword (ROOT_PASSWORD);
      root.setFirst ("Board");
      root.setLast ("System");
      root.setDescription ("System user");
      root.setState ("unregistered");
      root.setGroup ("system");
      root.setEmail ("board.system@nomail.com");
      root.setCreatedBy ("root");
      root.setLocked (true);
      
      facade.validateUser (ROOT, ROOT_PASSWORD);
      Member admin = new Member ();
      admin.setName (ADMIN_NAME);
      admin.setPassword (ADMIN_PASSWORD);
      admin.setFirst ("Board");
      admin.setLast ("Admin");
      admin.setDescription ("Board administrator");
      admin.setState ("registered");
      admin.setGroup ("admin");
      admin.setCreatedBy ("root");
      admin.setEmail ("board.admin@nomail.com");
      
      Member guest = new Member ();
      guest.setName ("guest");
      guest.setPassword (GUEST_PASSWORD);
      guest.setFirst ("Guest");
      guest.setLast ("User");
      guest.setDescription ("Guest user");
      guest.setState ("unregistered");
      guest.setGroup ("guest");
      guest.setLocked (true);
      guest.setCreatedBy ("root");
      guest.setEmail ("guest.user@nomail.com");
      
      facade.persist (root);
      facade.persist (admin);
      facade.persist (guest);
      
   }
   public void createBoard ()
   {
      facade.validateUser (ROOT, ROOT_PASSWORD);
      
      Board board = new Board ();
      board.setTitle ("main");
      board.setState ("active");
      board.setLocked (false);
      board.setDescription ("Openjpa board");
      board.setCreatedBy ("root");

      Category category = new Category ();
      category.setTitle ("Introduction");
      category.setState ("active");
      category.setLocked (true);
      category.setCreatedBy ("root");
      HashMap<String, String> props = new HashMap<String, String> ();
      props.put ("deleteable", "false");
      category.setProperties (props);
      
      Forum forum = new Forum ();
      forum.setTitle ("Read first");
      forum.setLocked (false);
      forum.setState ("active");
      forum.setDescription ("Topics defining the Forum");
      forum.setCreatedBy ("root");
      category.addForum (forum);
      board.addCategory (category);
      
      Topic topic = new Topic ();
      topic.setTitle ("How to use this board");
      topic.setState ("locked");
      topic.setCreatedBy ("root");
      Post post = new Post ();
      
      Message msg = new Message ();
      msg.setCreatedBy ("root");
      msg.setBody ("This text will describe how to use this board and explain the rules of good etiquette to new users.");
      facade.persist (msg);
      
      post.setLocked (true);
      post.setBodyId (msg.getId ());
      post.setCreatedBy ("root");
      topic.addPost (post);
      topic.setLastPostAuthor (post.getCreatedBy ());
      topic.setLastPostDate (new Date ());
      topic.setNumReplies (0);
      forum.addTopic (topic);
      
      facade.persist (board);
  }
   
   public static void main(String[] args) 
   {
      Install app = new Install ();
      app.facade = BoardApp.getComponent (Facade.class);

      app.createAdmin ();
//      app.createBoard ();
      
//      app.facade.commit ();
      app.facade.close ();
       
   }

}
