package net.jlj.board.dom;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.PrePersist;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import org.apache.openjpa.persistence.PersistentCollection;
import org.apache.openjpa.persistence.jdbc.Unique;

@Entity
@NamedQueries({
         @NamedQuery(name="admins", query="select distinct admin from Member admin where admin.mGroup = 'admin'"),
         @NamedQuery(name="user", query="select user from Member user where user.mName = ?1"),
         @NamedQuery(name="user_by_email", query="select user from Member user where user.mEmail = ?1"),
         @NamedQuery(name="all_users", query="select user from Member user where user.mName LIKE ?1 AND user.mGroup not in ('system','hide','guest')")})

@Table(name="member", uniqueConstraints={@UniqueConstraint(columnNames="login_name"), 
                                         @UniqueConstraint(columnNames="email")})
public class Member extends DomEntity
{
   @Unique
   @Column(name="login_name", length=32, nullable=false)
   private String mName; /* board login name */
   
   @Column(name="passwrd", length=64, nullable=false)
   private String mPassword;
   
   @Column(name="first_name", length=32)
   private String mFirst;
   
   @Column(name="middle_name", length=32)
   private String mMiddle;
   
   @Column(name="last_name", length=32)
   private String mLast;

   @Unique
   @Column(name="email", length=256, nullable=false)
   private String mEmail;
   
   @Basic
   @Column(name="sig", length=256)
   private String mSig;
   
   @Basic
   @Column(name="avatar", length=128)
   private String mAvatar;
   
   @Basic
   @Column(name="photo", length=128)
   private String mPhoto;
   
   @Basic
   @Column(name="usr_grp", length=128)
   private String mGroup;
   
   @Basic
   @Column(name="tzone", length=64)
   private String mTimezone;
   
   @Column(name="reg_code", length=64)
   private String mRegCode;

   @OneToMany
   @OrderBy(value="mName")
   private List<Member> mFriends;
   
   @OneToMany(cascade=CascadeType.ALL)
   @OrderBy(value="mText")
   private List<Link> mLinks;
   
   
   public String getName ()
   {
      return mName;
   }

   public void setName (String name)
   {
      mName = name;
   }

   public String getFirst ()
   {
      return mFirst;
   }

   public void setFirst (String first)
   {
      mFirst = first;
   }

   public String getMiddle ()
   {
      return mMiddle;
   }

   public void setMiddle (String middle)
   {
      mMiddle = middle;
   }

   public String getLast ()
   {
      return mLast;
   }

   public void setLast (String last)
   {
      mLast = last;
   }

   public String getEmail ()
   {
      return mEmail;
   }

   public void setEmail (String email)
   {
      mEmail = email;
   }

   public String getSig ()
   {
      return mSig;
   }

   public void setSig (String sig)
   {
      mSig = sig;
   }

   public String getAvatar ()
   {
      return mAvatar;
   }

   public void setAvatar (String avatar)
   {
      mAvatar = avatar;
   }

   public String getPhoto ()
   {
      return mPhoto;
   }

   public void setPhoto (String photo)
   {
      mPhoto = photo;
   }

   public String getGroup ()
   {
      return mGroup;
   }

   public void setGroup (String group)
   {
      mGroup = group;
   }

   public String getTimezone ()
   {
      return mTimezone;
   }

   public void setTimezone (String timezone)
   {
      mTimezone = timezone;
   }

   /**
    * Password can be set and checked, but never accessed publicly.
    * @return
    */
   private String getPassword ()
   {
      return mPassword;
   }

   public void setPassword (String password)
   {
      System.out.println ("Updating password for user " + mName + " to " + password);
      mPassword = password;
   }
   public boolean checkPassword (String password)
   {
      String pass = getPassword ();
      return pass != null && pass.equals (password);
   }
   
   public boolean isAdmin ()
   {
      return "admin".equals (mGroup);
   }
   
   @PrePersist
   public void autSetCreatedBy ()
   {
      if (getCreatedBy () == null)
      {
         setCreatedBy (mName);
      }
   }

   public String getRegCode ()
   {
      return mRegCode;
   }

   public void setRegCode (String regCode)
   {
      mRegCode = regCode;
   }

   public void addFriend (Member friend)
   {
      if (mFriends == null)
      {
         mFriends = new ArrayList<Member> ();
      }
      mFriends.add (friend);
   }
   
   public void removeFriend (Member friend)
   {
      if (mFriends != null && mFriends.contains (friend))
      {
         mFriends.remove (friend);
      }
   }

   public List<Member> getFriends ()
   {
      return mFriends;
   }
   
   public void addLink (Link link)
   {
      if (mLinks == null)
      {
         mLinks = new ArrayList<Link> ();
      }
      mLinks.add (link);
   }
   
   public void removeLink (Link link)
   {
      if (mLinks == null || !mLinks.contains (link))
         return;
      mLinks.remove (link);
   }
   
   public List <Link> getLinks ()
   {
      return mLinks;
   }
   
}
