require 'rubygems'
require 'crypt/rijndael'
require 'base64'

module Encrypt
   @@SECRET_KEY = "Ci defaid Mam iw Sew, ci annwyl sydd yn gweld eisiau ei meistres yr un faint a gweddill y teulu."[0..31]

   def encrypt text
      rijndael = Crypt::Rijndael.new( @@SECRET_KEY, 256, 256 )
      Base64.encode64( rijndael.encrypt_block( text.ljust(32) ) ).chop #remove unwanted (benign) new line character
   end

   def decrypt text
      rijndael = Crypt::Rijndael.new( @@SECRET_KEY, 256, 256 )
      rijndael.decrypt_block( Base64.decode64( text ) ).strip
   end
end