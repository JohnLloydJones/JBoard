package net.jlj.board.dom;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

@Entity
@NamedQueries({
   @NamedQuery(name="events_for_user", query="select event from Event event WHERE event.mForUser = ?1 or event.mType = 'public'")
})
@Table(name="event")
public class Event extends DomEntity
{
   public static final String POST = "post";
   public static final String PRIVATE_MSG = "private";
   public static final String PUBLIC_MSG = "public";
   
   public Event ()
   {
      
   }
   public Event (String user)
   {
      super (user);
   }
   @Column(name="type", length=16, nullable=false)
   private String mType; /* post, private, public, system */
   
   @Column(name="object_id")
   private long mObjectId;
   
   @Column(name="for_user", length=32, nullable=false)
   private String mForUser;
   
   @Column(name="text", length=128)
   private String mText;
   
   public String getType ()
   {
      return mType;
   }
   public long getObjectId ()
   {
      return mObjectId;
   }
   public void setPost (Post post)
   {
      mObjectId = post.getId();
      mType = POST;
      mForUser = " public ";
   }
   public void setPublicMessage (Message message)
   {
      mObjectId = message.getId ();
      mType = PUBLIC_MSG;
      mForUser = " public ";
      mText = null;
   }
   public void setPrivateMessage (Message message, Member forUser)
   {
      mObjectId = message.getId ();
      mType = PRIVATE_MSG;
      mForUser = forUser.getName ();
      mText = null;
   }
   public void setSystemMessage (Message message, Member forUser, String text)
   {
      mObjectId = message.getId ();
      mType = PRIVATE_MSG;
      mForUser = forUser.getName ();
      mText = text;
   }
   
   public String getForUser ()
   {
      return mForUser;
   }
   public String getText ()
   {
      return mText;
   }
   public void setText (String text)
   {
      mText = text;
   }
   
}
