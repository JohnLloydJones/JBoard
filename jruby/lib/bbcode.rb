#! /usr/bin/env ruby
module BBCode
   @@imageformats = 'png|bmp|jpg|gif'
   @@tags = {
      # tag name => [regex, replace, description, example, symbol]
      'Bold' => [
         /\[b\](.*?)\[\/b\]/mi,
         '<strong>\1</strong>',
         'Embolden text',
         'Look [b]here[/b]',
         :bold],
      'Italics' => [
         /\[i\](.*?)\[\/i\]/mi,
         '<em>\1</em>',
         'Italicize or emphasize text',
         'Even my [i]cat[/i] was chasing the mailman!',
         :italics],
      'Underline' => [
         /\[u\](.*?)\[\/u\]/mi,
         '<u>\1</u>',
         'Underline',
         'Use it for [u]important[/u] things or something',
         :underline],
      'Strikeout' => [
         /\[s\](.*?)\[\/s\]/mi,
         '<s>\1</s>',
         'Strikeout',
         '[s]nevermind[/s]',
         :strikeout],

      'Delete' => [
         /\[del\](.*?)\[\/del\]/mi,
         '<del>\1</del>',
         'Deleted text',
         '[del]deleted text[/del]',
         :delete],
      'Insert' => [
         /\[ins\](.*?)\[\/ins\]/mi,
         '<ins>\1</ins>',
         'Inserted Text',
         '[ins]inserted text[/del]',
         :insert],
       'Hlight' => [
           /\[hlight\](.*?)\[\/hlight\]/mi,
          '<span style="background-color:#ff8">\1</span>',
           'Highlighted text',
          '[hlight]highlighted text[/hlight]',
          :hlight],
       'Code' => [
          /\[code(:.+)?\](.*?)\[\/code\1?\]/mi,
                  '<fieldset class="quote"><legend>Code</legend><blockquote><code>\2</code></blockquote></fieldset>',
          'Code Text',
          '[code]some code[/code]',
          :code],
      'Size' => [
         /\[size=['"]?(.*?)['"]?\](.*?)\[\/size\]/im,
         '<span style="font-size: \1px;">\2</span>',
        'Change text size',
        '[size=20]Here is some larger text[/size]',
        :size],
      'Color' => [
         /\[color=['"]?(\w+|\#\w{6})['"]?(:.+)?\](.*?)\[\/color\2?\]/im,
         '<span style="color: \1;">\3</span>',
         'Change text color',
         '[color=red]This is red text[/color]',
         :color],
      'Ordered List' => [
         /\[ol\](.*?)\[\/ol\]/mi,
         '<ol>\1</ol>',
         'Ordered list',
         'My favorite people (alphabetical order): [ol][li]Jenny[/li][li]Alex[/li][li]Beth[/li][/ol]',
         :orderedlist],
      'Unordered List' => [
         /\[(ul|list)\](.*?)\[\/\1\]/mi,
         '<ul>\2</ul>',
         'Unordered list',
         'My favorite people (order of importance): [ul][li]Jenny[/li][li]Alex[/li][li]Beth[/li][/ul]',
         :unorderedlist],
      'List Item' => [
         /\[li\](.*?)\[\/li\]/mi,
         '<li>\1</li>',
         'List item',
         'See ol or ul',
         :listitem],
      'List Item (alternative)' => [
         /\[\*\](.*?)$/mi,
         '<li>\1</li>',
         'List item',
         'See ol or ul',
         :listitem],

      'Definition List' => [
         /\[dl\](.*?)\[\/dl\]/mi,
         '<dl>\1</dl>',
         'List of terms/items and their definitions',
         '[dl][dt]Fusion Reactor[/dt][dd]Chamber that provides power to your... nerd stuff[/dd][dt]Mass Cannon[/dt][dd]A gun of some sort[/dd][/dl]',
         :definelist],
      'Definition Term' => [
         /\[dt\](.*?)\[\/dt\]/mi,
         '<dt>\1</dt>',
         nil, nil,
         :defineterm],
      'Definition Definition' => [
         /\[dd\](.*?)\[\/dd\]/mi,
         '<dd>\1</dd>',
         nil, nil,
         :definition],
      'Quote' => [
        /\[quote(:.*)?="?(.*?)"?\](.*?)\[\/quote\1?\]/mi,
        '<fieldset class="quote"><legend>\2</legend><blockquote>\3</blockquote></fieldset>',
        'Quote with citation',
         nil,
         :quote],
      'Quote (Sourceless)' => [
        /\[quote(:.*)?\](.*?)\[\/quote\1?\]/mi,
        '<fieldset class="quote"><blockquote>\2</blockquote></fieldset>',
        'Quote (sourceless)',
         nil,
        :quote],
      'Link' => [
         /\[url=(.*?)\](.*?)\[\/url\]/mi,
         '<a href="\1">\2</a>',
         'Hyperlink to somewhere else',
         'Maybe try looking on [url=http://google.com]Google[/url]?',
         :link],

      'Link (Implied)' => [
         /\[url\](.*?)\[\/url\]/mi,
         '<a href="\1">\1</a>',
         nil, nil,
         :link],

      'Link (Automatic)' => [
         /([\s\(\[])(https?:\/\/.*?(?=[\s\)\]]))/i,
         '\1<a href="\2">\2</a>',
         nil, nil,
         :link],

      'Image' => [
         /\[img\]([^\[\]].*?)\.(#{@@imageformats})\[\/img\]/i,
         '<img src="\1.\2" alt="" />',
         'Display an image',
         'Check out this crazy cat: [img]http://catsweekly.com/crazycat.jpg[/img]',
         :image],
      'Image (Alternative)' => [
         /\[img=([^\[\]].*?)\.(#{@@imageformats})\]/i,
         '<img src="\1.\2" alt="" />',
         nil, nil,
         :image]
   }
   def self.to_html(text, method, tags)
      text.gsub!( '&', '&amp;' )
      text.gsub!( '<', '&lt;' )
      text.gsub!( '>', '&gt;' )
      
      level = maxlevel = 1
      while m = /(\[\/?quote(?=[^:]))/mi.match( text ) do
         endq = m[ 1 ][1..1] == '/'
         level -=1 if endq
         text = text[0,m.end(1)] +
                ":#{level.to_s}" +
                   text[m.end(1)..-1]

         level += 1 unless endq
         maxlevel = level if level > maxlevel
      end
      case method
         when :enable
            @@tags.each_value { |t|
               n = (t[4] == :quote) ? maxlevel : 1
               n.times{ text.gsub!(t[0], t[1]) } if tags.include?(t[4])
            }
         when :disable
            # this works nicely because the default is disable and the default set of tags is [] (so none disabled) :)
            @@tags.each_value { |t|
               n = (t[4] == :quote) ? maxlevel : 1
               n.times{ text.gsub!(t[0], t[1]) } unless tags.include?(t[4])
            }
      end
      text.gsub( /\r\n?/, "\n" ).gsub( /\n/, "<br />\n" )
   end
   def self.tags
      @@tags.each { |tn, ti|
         # yields the tag name, a description of it and example
         yield tn, ti[2], ti[3] if ti[2]
      }
   end
end

class String
   def bbcode_to_html(method = :disable, *tags)
      BBCode.to_html(self, method, tags)
   end
   def bbcode_to_html!(method = :disable, *tags)
      self.replace(BBCode.to_html(self, method, tags))
   end
end
