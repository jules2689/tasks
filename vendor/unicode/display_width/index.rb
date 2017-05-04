require_relative 'constants'

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
