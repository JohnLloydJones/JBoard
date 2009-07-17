package net.jlj.board.dom;


import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.PostPersist;
import javax.persistence.Table;

@Entity
@NamedQueries({
   @NamedQuery(name="posts_for_topic", query="select post from Topic topic, IN (topic.mPosts) post WHERE topic.mId = ?1 and post.mState <> 'hidden' order by post.mCreated"),
   @NamedQuery(name="posts_for_user", query="select post from Post post WHERE post.mCreatedBy = ?1 and post.mCreated > ?2 order by post.mCreated DESC"),
   @NamedQuery(name="num_posts_for_user", query="select count(post.mId) from Post post where post.mCreatedBy = ?1")
})
@Table(name="post")
public class Post extends DomEntity
{
   @Column(name="version")
   private long mVersion;
   
   @Column(name="previous_id")
   private long mPreviousId; 
   
   @Column(name="body_id")
   private long mBodyId; /* of type Message */

   public Post ()
   {
     // required default constructor  
   }
   public Post (String user, long bodyId)
   {
      super (user);
      mBodyId = bodyId;
   }
   public long getVersion ()
   {
      return mVersion;
   }

   public void setVersion (long version)
   {
      mVersion = version;
   }

   public long getBodyId ()
   {
      return mBodyId;
   }

   public void setBodyId (long bodyId)
   {
      mBodyId = bodyId;
   }

   public long getPreviousId ()
   {
      return mPreviousId;
   }

   public void setPrevious (long previousId)
   {
      mPreviousId = previousId;
   }
   @PostPersist
   public void autoSetTitle ()
   {
      if (getTitle () == null)
      {
         setTitle ("p" + getId());
      }
   }
   
}
