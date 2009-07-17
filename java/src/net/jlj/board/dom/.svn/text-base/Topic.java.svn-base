package net.jlj.board.dom;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.Table;

@Entity
@NamedQueries({
   @NamedQuery(name="topics_for_forum", query="select topic from Forum forum, IN (forum.mTopics) topic WHERE forum.mId = ?1 and topic.mState <> 'hidden' ORDER BY topic.mLocked DESC,topic.mLastPostDate DESC"),
   @NamedQuery(name="topic_for_post", query="select topic from Topic topic, IN (topic.mPosts) post where post.mId = ?1")
})
/*
select distinct p.id as post_id, tp.topic_id, p.created 
from jrubyapp.POST p, jrubyapp.topic_post tp
where (select MAX(p.created) from jrubyapp.post p, jrubyapp.topic_post tp where tp.mposts_id = p.id) = p.created 
   and tp.topic_id = 7;

 */
@Table(name="topic")
public class Topic extends DomEntity
{
   @OneToMany(cascade=CascadeType.ALL,fetch=FetchType.LAZY)
   @OrderBy
	private List<Post> mPosts;
   
   private String mLastPostAuthor;
   private Date   mLastPostDate;
   private long   mLastPostId;
   private int    mNumReplies;

   public void addPost (Post post)
   {
      if (mPosts == null)
      {
         mPosts = new ArrayList<Post> ();
      }
      mPosts.add (post);
      updateLastPost (post);
   }
   public void removePost (Post post)
   {
      if (mPosts == null || !mPosts.contains (post))
      {
         return;
      }
      mPosts.remove (post);
      Post last = null;
      if (mPosts.size () > 0)
      {
         last = mPosts.get (mPosts.size() - 1);
      }
      updateLastPost (last);
   }
   public void setPosts (List <Post> posts)
   {
      mPosts = posts;
   }

   public List<Post> getPosts ()
   {
      return mPosts;
   }

   public String getLastPostAuthor ()
   {
      return mLastPostAuthor;
   }

   public void setLastPostAuthor (String lastPostAuthor)
   {
      mLastPostAuthor = lastPostAuthor;
   }

   public Date getLastPostDate ()
   {
      return mLastPostDate;
   }

   public void setLastPostDate (Date lastPostDate)
   {
      mLastPostDate = lastPostDate;
   }

   public void setNumReplies (int numReplies)
   {
      mNumReplies = numReplies;
   }

   public int getNumReplies ()
   {
      return mNumReplies;
   }

   public long getLastPostId ()
   {
      return mLastPostId;
   }

   public void setLastPostId (long lastPostId)
   {
      mLastPostId = lastPostId;
   }
   public void updateLastPost (Post post)
   {
      if (post == null)
      {
         mLastPostAuthor = null;
         mLastPostDate = null;
         mLastPostId = 0;
         mNumReplies =  0;
      }
      else
      {
         mLastPostAuthor = post.getCreatedBy ();
         mLastPostDate = post.getCreated () == null ? new Date () : post.getCreated ();
         mLastPostId = post.getId ();
         mNumReplies =  mPosts.size () - 1;
      }
   }
}
