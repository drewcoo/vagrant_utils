#
# Dumb class to deol with chunks of buffered IO. This seemed better
# than peppering all of the offset math through other code.
#
class Chunk
  attr_reader :offset, :size, :total

  def initialize(size:)
    @size = 4096
    @offset = 0
    @total = size
  end

  def next
    @offset += @size
    @offset = @total if @offset > @total
  end
end
