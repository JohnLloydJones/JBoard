package net.jlj.board.dom;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.PrePersist;
import javax.persistence.Table;

@Entity
@Table(name="message")
public class Message
{
   public Message ()
   {
      
   }
   public Message (String user, String text)
   {
      mCreatedBy = user;
      mBody = text;
   }
   @Column(name="id")
   @Id
//   @GeneratedValue(strategy=GenerationType.TABLE, generator="EntitySeq") 
   @GeneratedValue(strategy=GenerationType.AUTO) 
   long mId;

   @Column(name="created")
   private Date mCreated;
   
   @Column(name="created_by", length=32, nullable=false)
   private String mCreatedBy;
   
   @Column(name="body", nullable=false)
   @Lob
   private String mBody;

   public long getId ()
   {
      return mId;
   }

   public void setId (long id)
   {
      mId = id;
   }

   public Date getCreated ()
   {
      return mCreated;
   }

   public void setCreated (Date created)
   {
      mCreated = created;
   }

   public String getCreatedBy ()
   {
      return mCreatedBy;
   }

   public void setCreatedBy (String createdBy)
   {
      mCreatedBy = createdBy;
   }
   @PrePersist
   public void autoSetCreated ()
   {
      if (mCreated == null)
      {
         mCreated = new Date ();
      }
   }

   public String getBody ()
   {
      return mBody;
   }

   public void setBody (String body)
   {
      mBody = body;
   }
   
}
