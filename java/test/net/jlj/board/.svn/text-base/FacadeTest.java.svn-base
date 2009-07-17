package net.jlj.board;

import java.util.ArrayList;
import java.util.List;

import net.jlj.board.dom.Board;
import net.jlj.board.dom.Member;
import net.jlj.board.metadata.Metadata;
import net.jlj.board.persistence.MockQuery;
import junit.framework.TestCase;

public class FacadeTest extends TestCase
{
   private static final String ADMIN_PASSWORD = "Zq2t2jHbIpNl3YQBrtyo1awZGLQpoTIvg03O8Mok9KQ=";

   protected void setUp () throws Exception
   {
      super.setUp ();
      MockBoardApp.createInstance (); // Setup for unit tests
   }

   protected void tearDown () throws Exception
   {
      super.tearDown ();
   }

   public void testGetInstance ()
   {
      Facade facade = Facade.getInstance ();
      assertNotNull ("Expect to create an instance", facade);
   }

   public void testGetUser ()
   {
      MockQuery.Param param = new MockQuery.Param (1, "admin");
      MockQuery.ExpectedResult result = new MockQuery.ExpectedResult (param, createAdmin ());
      MockQuery.pushResult (result);
      
      
      Facade facade = BoardApp.getComponent (Facade.class);
      Member admin = facade.getUser ("admin");
      assertEquals ("Expect user name to be admin", "admin", admin.getName ());
   }

   public void testValidateUser ()
   {
      MockQuery.Param param = new MockQuery.Param (1, "LOGIN");
      MockQuery.ExpectedResult result = new MockQuery.ExpectedResult (param, createMetadata ("LOGIN"));
      MockQuery.pushResult (result);
      
      param = new MockQuery.Param (1, "STATE");
      result = new MockQuery.ExpectedResult (param, createMetadata ("STATE"));
      MockQuery.pushResult (result);
      
      param = new MockQuery.Param (1, "admin");
      result = new MockQuery.ExpectedResult (param, createAdmin ());
      MockQuery.pushResult (result);
      
      Facade facade = BoardApp.getComponent (Facade.class);
      assertTrue ("Expect user Admin to validate", facade.validateUser ("admin", ADMIN_PASSWORD));
   }

   public void testGetBoard ()
   {
      MockQuery.Param param = new MockQuery.Param (1, "main");
      ArrayList<Board> list = new ArrayList<Board> ();
      list.add (createTestBoard ());
      MockQuery.ExpectedResult results = new MockQuery.ExpectedResult (param, list);
      MockQuery.pushResult (results);
      
      Facade facade = BoardApp.getComponent (Facade.class);
      Board board = facade.getBoard ();
      assertNotNull ("Expect to fetch the board", board);
      assertEquals ("Expect to fetch the 'main' board", "main", board.getTitle ());
   }

   Board createTestBoard ()
   {
      
      Board board = new Board ();
      board.setTitle ("main");
      board.setState ("active");
      board.setLocked (false);
      board.setDescription ("Open JPA Board");

      return board;
   }
   
   Member createAdmin ()
   {
      Member admin = new Member ();
      admin.setName ("admin");
      admin.setPassword (ADMIN_PASSWORD);
      admin.setState ("registered");
      admin.setFirst ("Board");
      admin.setLast ("Administrator");
      admin.setGroup ("admin");
      admin.setEmail ("board.admin@nomail.com");
      
      return admin;
   }
   
   List<Metadata> createMetadata (String type)
   {
      List<Metadata> list = new ArrayList<Metadata> ();
      if ("STATE".equals (type))
      {
         list.add (new Metadata("STATE", "MODERATED", "moderated", "Member is registered, but posts require moderating"));
         list.add (new Metadata("STATE", "REGISTERED", "registered", "Member has registered"));
      }
      else
      {
      list.add (new Metadata("LOGIN", "MODERATED", "moderated", "Member is registered, but posts require moderating"));
      list.add (new Metadata("LOGIN", "REGISTERED", "registered", "Member has registered"));
      }
      return list;
   }
}
