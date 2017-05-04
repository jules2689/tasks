require_relative 'constants'

# Pulled from  
# The following methods is taken from rubygems/rubygems
#
# https://github.com/rubygems/rubygems/blob/0749715e4bd9e7f0fb631a352ddc649574da91c1/lib/rubygems/util.rb#L20
#
# All credit for this method goes to the original authors.
# The code is used under the MIT license.
#
# Gunzips a data string
#
class Gunzip
  def self.gunzip(data)
    require 'zlib'
    require 'stringio'
    data = StringIO.new(data, 'r')

    unzipped = Zlib::GzipReader.new(data).read
    unzipped.force_encoding Encoding::BINARY if Object.const_defined? :Encoding
    unzipped
  end
end

module Unicode
  module DisplayWidth
    INDEX = Marshal.load(Gunzip.gunzip(File.binread(INDEX_FILENAME)))
  end
end
