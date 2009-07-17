package net.jlj.board.dom;

import java.util.ArrayList;
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
@Table(name="forum")
@NamedQueries({
   @NamedQuery(name="forum_for_topic", query="select forum from Forum forum, IN (forum.mTopics) topic where topic.mId = ?1")
})
public class Forum extends DomEntity
{
   @OneToMany(cascade=CascadeType.ALL,fetch=FetchType.LAZY)
   @OrderBy
	private List<Topic> mTopics;
   
   @OneToMany(cascade=CascadeType.ALL)
   private List<Topic> mDeletedTopics;
   
   private long mLastTopicUpdated;
   
   public List <Topic> getTopics ()
   {
      return mTopics;
   }

   public void addTopic (Topic topic)
   {
      if (mTopics == null)
      {
         mTopics = new ArrayList <Topic> ();
      }
      mTopics.add (topic);
   }
   public void removeTopic (Topic topic)
   {
      if (mTopics == null || !mTopics.contains (topic))
      {
         return;
      }
      mTopics.remove (topic);
      
   }
   public void setTopics (List <Topic> topics)
   {
      mTopics = topics;
   }
/*
   public long getLastTopicUpdated ()
   {
      return mLastTopicUpdated;
   }

   public void setLastTopicUpdated (long lastTopicUpdated)
   {
      mLastTopicUpdated = lastTopicUpdated;
   }
*/   
   public void addToDeleted (Topic topic)
   {
      if (mDeletedTopics == null)
      {
         mDeletedTopics = new ArrayList<Topic>();
      }
      mDeletedTopics.add (topic);  
   }
   public void removeFromDeleted (Topic topic)
   {
      if (mDeletedTopics == null || !mDeletedTopics.contains (topic))
         return;
      mDeletedTopics.remove (topic);
   }

   public List <Topic> getDeletedTopics ()
   {
      return mDeletedTopics;
   }
}
