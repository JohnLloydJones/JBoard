package net.jlj.board.metadata;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Persistence;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;


@Entity
@Table(name="meta_data", uniqueConstraints=@UniqueConstraint(columnNames={"data_type","data_key"}))
@NamedQueries({
   @NamedQuery(name="meta_by_type", query="select meta_data from Metadata meta_data where meta_data.mType = ?1")
})

public class Metadata
{
   
   @Column(name="id")
   @Id
//   @SequenceGenerator(name="EntitySeq", sequenceName="system")
//   @GeneratedValue(strategy=GenerationType.TABLE, generator="EntitySeq") 
   @GeneratedValue(strategy=GenerationType.AUTO) 
   private long mId;
   
   @Column(name="data_type", length=16)
   private String mType;
   
   @Column(name="data_key", length=32)
   private String mKey;
   
   @Column(name="data_value", length=256)
   private String mValue;
   
   
   @Column(name="description", length=128)
   private String mDescription;

   protected Metadata ()
   {

   }

   public Metadata (String type, String key, String value, String description)
   {
      mType = type;
      mKey = key;
      mValue = value;
      mDescription = description;
   }

   public long getId ()
   {
      return mId;
   }


   public void setId (long id)
   {
      mId = id;
   }

   public String getType ()
   {
      return mType;
   }

   public void setType (String type)
   {
      mType = type;
   }

   public String getKey ()
   {
      return mKey;
   }

   public void setKey (String key)
   {
      mKey = key;
   }   

   public String getValue ()
   {
      return mValue;
   }


   public void setValue (String value)
   {
      mValue = value;
   }


   public String getDescription ()
   {
      return mDescription;
   }


   public void setDescription (String description)
   {
      mDescription = description;
   }
   
   
   
   public static void main(String[] args) 
   {
      EntityManagerFactory factory = Persistence.createEntityManagerFactory("board", System.getProperties());
      EntityManager manager = factory.createEntityManager ();
      
      
      manager.getTransaction ().begin ();
      manager.persist (new Metadata("STATE", "UNREGISTERED", "unregistered", "Member has not registered"));
      manager.persist (new Metadata("STATE", "VALIDATING",   "validating", "Member has not completed registering"));
      manager.persist (new Metadata("STATE", "MODERATED", "moderated", "Member is registered, but posts require moderating"));
      manager.persist (new Metadata("STATE", "REGISTERED",   "registered", "Member has registered"));
      manager.persist (new Metadata("STATE", "BANNED", "banned", "Member has been banned"));
      manager.persist (new Metadata("STATE", "DELETED", "deleted", "Member has been deleted"));
      
      manager.persist (new Metadata("LOGIN", "VALIDATING",   "validating", "Member has not completed registering"));
      manager.persist (new Metadata("LOGIN", "MODERATED", "moderated", "Member is registered, but posts require moderating"));
      manager.persist (new Metadata("LOGIN", "REGISTERED", "registered", "Member has registered"));
      
      manager.persist (new Metadata("GROUP", "HIDE", "hide", "User may not view or participate"));
      manager.persist (new Metadata("GROUP", "GUEST", "guest", "User may view but not participate"));
      manager.persist (new Metadata("GROUP", "MEMBER", "member", "User may participate (post)"));
      manager.persist (new Metadata("GROUP", "PRIVILEGED", "privileged", "User can access private areas"));
      manager.persist (new Metadata("GROUP", "ADMIN", "admin", "User has administrator rights"));
      
      manager.getTransaction ().commit ();
      manager.close ();
      
   }

}
