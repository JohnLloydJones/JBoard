package net.jlj.board.dom;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import org.apache.openjpa.persistence.PersistentCollection;

@Entity
@NamedQueries({
   @NamedQuery(name="category", query="select category from Category category where category.mTitle = ?1")
})
@Table(name="category")
public class Category extends DomEntity
{
   @OneToMany(cascade=CascadeType.ALL)
	private List<Forum> mForums;

   @OneToMany(cascade=CascadeType.ALL)
   private List<Post> mPendingPosts;
   
   @OneToMany(cascade=CascadeType.ALL)
   private List<Post> mDeletedPosts;
   
   @PersistentCollection(elementCascade=CascadeType.ALL)
   private List<String> mModerators;
   
   public void addForum (Forum forum)
   {
      if (mForums == null)
      {
         mForums = new ArrayList<Forum>();
      }
      mForums.add (forum);
   }
   public void setForums (List<Forum> forums)
   {
      mForums = forums;
   }

   public List<Forum> getForums ()
   {
      return mForums;
   }
   public void addToPending (Post post)
   {
      if (mPendingPosts == null)
      {
         mPendingPosts = new ArrayList<Post>();
      }
      mPendingPosts.add (post);  
   }
   public void removeFromPending (Post post)
   {
      if (mPendingPosts == null || !mPendingPosts.contains (post))
         return;
      mPendingPosts.remove (post);
   }
   public void addToDeleted (Post post)
   {
      if (mDeletedPosts == null)
      {
         mDeletedPosts = new ArrayList<Post>();
      }
      mDeletedPosts.add (post);  
   }
   public void removeFromDeleted (Post post)
   {
      if (mDeletedPosts == null || !mDeletedPosts.contains (post))
         return;
      mDeletedPosts.remove (post);
   }
   public List<Post> getPendingPosts ()
   {
      return mPendingPosts;
   }
   public List<Post> getDeletedPosts ()
   {
      return mDeletedPosts;
   }
   public boolean isModerator (String name)
   {
      return mModerators != null && mModerators.contains (name);
   }
   public void addModerator (Member moderator)
   {
      if (mModerators == null)
      {
         mModerators = new ArrayList<String> ();
      }
      mModerators.add (moderator.getName ());
   }
   public void removeModerator (Member moderator)
   {
      if (mModerators == null || !mModerators.contains (moderator.getName ()))
         return;
      mModerators.remove (moderator.getName ());
   }
   public List <String> getModerators ()
   {
      return mModerators;
   }
}
