package net.jlj.board.dom;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

@Entity
@NamedQueries({
   @NamedQuery(name="board", query="select board from Board board where board.mTitle LIKE ?1")
})
@Table(name="board", uniqueConstraints={@UniqueConstraint(columnNames="title")})
public class Board extends DomEntity
{
   @OneToMany(cascade=CascadeType.ALL)
   @OrderBy
	private List<Category> mCategories;

	public void setCategories (List<Category> categories)
	{
		mCategories = categories;
	}

	public List<Category> getCategories ()
	{
		return mCategories;
	}

   public void addCategory (Category category)
   {
      List<Category> categories = getCategories ();
      if (categories == null)
      {
         categories = new ArrayList<Category> ();
      }
      categories.add (category);
      setCategories (categories);
   }
}
