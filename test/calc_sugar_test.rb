require File.dirname(__FILE__) + '/helper'
require 'citrus/sugar'
require File.dirname(__FILE__) + '/../examples/calc_sugar'

class CalcSugarTest < Test::Unit::TestCase
  include CalcTests
end