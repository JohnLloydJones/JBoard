package net.jlj.board.dom;

import java.net.URI;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name="link")
public class Link
{
   @Column(name="id")
   @Id
   @GeneratedValue(strategy=GenerationType.AUTO) 
   private long mId;
   
   @Column(name="link_url", length=256, nullable=false)
   private String mUrl;
   
   @Column(name="link_text", length=64, nullable=false)
   private String mText;
   
   @Column(name="description", length=128)
   private String mDescription;
   
   public Link ()
   {
      
   }
   public Link (String url, String text)
   {
      mUrl = url;
      mText = text;
   }

   public long getId ()
   {
      return mId;
   }

   public void setId (long id)
   {
      mId = id;
   }

   public String getUrl ()
   {
      return mUrl;
   }


   public void setUrl (String link)
   {
      mUrl = link;
   }

   public String getText ()
   {
      return mText;
   }

   public void setText (String text)
   {
      mText = text;
   }

   public String getDescription ()
   {
      return mDescription;
   }

   public void setDescription (String description)
   {
      mDescription = description;
   }
   
   
}
