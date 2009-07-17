package net.jlj.board.dom;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.MappedSuperclass;
import javax.persistence.PrePersist;
import javax.persistence.SequenceGenerator;

import org.apache.openjpa.persistence.PersistentMap;

/*
 */
@MappedSuperclass
@Inheritance(strategy=InheritanceType.TABLE_PER_CLASS)
public class DomEntity
{
   @Column(name="id")
   @Id
//   @SequenceGenerator(name="EntitySeq", sequenceName="system")
//   @GeneratedValue(strategy=GenerationType.TABLE, generator="EntitySeq") 
   @GeneratedValue(strategy=GenerationType.AUTO) 
   long mId;
   
   @Column(name="title", length=32)
   @Basic
   private String mTitle;
   
   
   @Column(name="description", length=128)
   @Basic
   private String mDescription;
   
   @Column(name="state", length=64)
   @Basic
   private String mState;
   
   @Column(name="locked")
   @Basic
   private boolean mLocked;
   
   @PersistentMap(fetch=FetchType.EAGER)
   private Map <String, String> mProperties;
   
   @Column(name="created")
   private Date mCreated;
   
   @Column(name="created_by", length=32, nullable=false)
   private String mCreatedBy;

   public DomEntity ()
   {
      
   }
   public DomEntity (String createdBy)
   {
      mCreatedBy = createdBy;
   }
   public long getId ()
   {
      return mId;
   }

   public void setId (long id)
   {
      mId = id;
   }

   public String getTitle ()
   {
      return mTitle;
   }

   public void setTitle (String title)
   {
      mTitle = title;
   }

   public String getDescription ()
   {
      return mDescription;
   }

   public void setDescription (String description)
   {
      mDescription = description;
   }

   public String getState ()
   {
      return mState;
   }

   public void setState (String state)
   {
      mState = state;
   }

   public boolean isLocked ()
   {
      return mLocked;
   }

   public void setLocked (boolean locked)
   {
      mLocked = locked;
   }
   public String getProperty (String key)
   {
      return mProperties == null ? null : mProperties.get (key);
   }
   public void setProperty (String key, String value)
   {
      if (mProperties == null)
      {
         mProperties = new HashMap <String, String> ();
      }
      mProperties.put (key, value);
   }
   public Map <String, String> getProperties ()
   {
      return mProperties;
   }

   public void setProperties (Map <String, String> properties)
   {
      mProperties = properties;
   }
   public Date getCreated ()
   {
      return mCreated;
   }

   public void setCreated (Date created)
   {
      mCreated = created;
   }
   
   @PrePersist
   public void autoSetCreated ()
   {
      if (mCreated == null)
      {
         mCreated = new Date ();
      }
   }

   public String getCreatedBy ()
   {
      return mCreatedBy;
   }

   public void setCreatedBy (String createdBy)
   {
      mCreatedBy = createdBy;
   }
}
