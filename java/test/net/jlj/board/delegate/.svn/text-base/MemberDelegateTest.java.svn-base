package net.jlj.board.delegate;

import java.util.ArrayList;
import java.util.List;

import net.jlj.board.BoardApp;
import net.jlj.board.MockBoardApp;
import net.jlj.board.dom.Board;
import net.jlj.board.dom.Member;
import net.jlj.board.persistence.MockQuery;
import junit.framework.TestCase;

public class MemberDelegateTest extends TestCase
{

   protected void setUp () throws Exception
   {
      super.setUp ();
      MockBoardApp.createInstance (); // Setup for unit tests
   }

   protected void tearDown () throws Exception
   {
      super.tearDown ();
   }

   public void testGetAdmins ()
   {
      List<Member> list = new ArrayList<Member> ();
      list.add (createAdmin ());
      MockQuery.ExpectedResult result = new MockQuery.ExpectedResult (null, list); 
      MockQuery.pushResult (result);
      
      
      MemberDelegate delegate = BoardApp.getComponent (MemberDelegate.class);
      
      List<Member> users = delegate.getAdmins ();
      assertEquals ("Expect one user", 1, users.size ());
      assertEquals ("Expect user name to be 'Admin'", "Admin", users.get (0).getName ());
      
   }

   public void testGetUser ()
   {
      MockQuery.Param param = new MockQuery.Param (1, "Admin");
      MockQuery.ExpectedResult result = new MockQuery.ExpectedResult (param, createAdmin ());
      MockQuery.pushResult (result);
      
      
      MemberDelegate delegate = BoardApp.getComponent (MemberDelegate.class);
      Member admin = delegate.getUser ("Admin");
      assertEquals ("Expect user name to be Admin", "Admin", admin.getName ());
   }

   public void testValidateUser ()
   {
      MockQuery.Param param = new MockQuery.Param (1, "Admin");
      MockQuery.ExpectedResult result = new MockQuery.ExpectedResult (param, createAdmin ());
      MockQuery.pushResult (result);
      
      
      MemberDelegate delegate = BoardApp.getComponent (MemberDelegate.class);
      assertTrue ("Expect user to validate", delegate.validateUser ("Admin", "password"));
   }

   Board createTestBoard ()
   {
      
      Board board = new Board ();
      board.setTitle ("Open JPA Board");
      board.setState ("active");
      board.setLocked (false);
      board.setDescription ("Test of openjpa board");

      return board;
   }
   
   Member createAdmin ()
   {
      Member admin = new Member ();
      admin.setName ("Admin");
      admin.setPassword ("password");
      admin.setFirst ("Board");
      admin.setLast ("Administrator");
      admin.setGroup ("admin");
      admin.setEmail ("board.admin@nomail.com");
      
      return admin;
      
   }
}
