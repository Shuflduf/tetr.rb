# frozen_string_literal: true

# 7 bag
class Bag
  def initialize
    @bag = new_shuffled
    @upcoming = new_shuffled
  end

  def next
    @bag = new_shuffled if @bag.empty?
    @upcoming << @bag.pop
    @upcoming.shift
  end

  def new_shuffled
    [*0..6].shuffle
  end

  attr_reader :upcoming
end
