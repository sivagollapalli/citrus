require File.dirname(__FILE__) + '/helper'

class GrammarTest < Test::Unit::TestCase

  def test_new
    Grammar.new do
      assert_kind_of(Module, self)
      assert(include?(Grammar))
    end
  end

  def test_non_module_fail
    assert_raise ArgumentError do
      ''.extend(GrammarMethods)
    end
  end

  def test_name
    assert_equal("Test::Unit::TestCase::TestGrammar", TestGrammar.name)
  end

  def test_no_name
    grammar = Grammar.new
    assert_equal('', grammar.name)
  end

  def test_rule_names
    assert_equal([:alpha, :num, :alphanum], TestGrammar.rule_names)
  end

  def test_has_name
    assert(TestGrammar.has_rule?('alpha'))
    assert(TestGrammar.has_rule?(:alpha))
  end

  def test_doesnt_have_name
    assert_equal(false, TestGrammar.has_rule?(:value))
  end

  def test_parse_fixed_width
    grammar = Grammar.new {
      rule(:abc) { 'abc' }
    }
    match = grammar.parse('abc')
    assert(match)
    assert_equal('abc', match.text)
    assert_equal(3, match.length)
  end

  def test_parse_expression
    grammar = Grammar.new {
      rule(:alpha) { /[a-z]+/i }
    }
    match = grammar.parse('abc')
    assert(match)
    assert_equal('abc', match.text)
    assert_equal(3, match.length)
  end

  def test_parse_sequence
    grammar = Grammar.new {
      rule(:num) { all(1, 2, 3) }
    }
    match = grammar.parse('123')
    assert(match)
    assert_equal('123', match.text)
    assert_equal(3, match.length)
  end

  def test_parse_sequence_long
    grammar = Grammar.new {
      rule(:num) { all(1, 2, 3) }
    }
    assert_raise ParseError do
      match = grammar.parse('1234')
    end
  end

  def test_parse_sequence_short
    grammar = Grammar.new {
      rule(:num) { all(1, 2, 3) }
    }
    assert_raise ParseError do
      match = grammar.parse('12')
    end
  end

  def test_parse_choice
    grammar = Grammar.new {
      rule(:alphanum) { any(/[a-z]/i, 0..9) }
    }

    match = grammar.parse('a')
    assert(match)
    assert_equal('a', match.text)
    assert_equal(1, match.length)

    match = grammar.parse('1')
    assert(match)
    assert_equal('1', match.text)
    assert_equal(1, match.length)
  end

  def test_parse_choice_miss
    grammar = Grammar.new {
      rule(:alphanum) { any(/[a-z]/, 0..9) }
    }
    assert_raise ParseError do
      match = grammar.parse('A')
    end
  end

  def test_parse_recurs
    grammar = Grammar.new {
      rule(:paren) { any(['(', :paren, ')'], /[a-z]/) }
    }

    match = grammar.parse('a')
    assert(match)
    assert_equal('a', match.text)
    assert_equal(1, match.length)

    match = grammar.parse('((a))')
    assert(match)
    assert('((a))', match.text)
    assert(5, match.length)

    str = ('(' * 200) + 'a' + (')' * 200)
    match = grammar.parse(str)
    assert(match)
    assert(str, match.text)
    assert(str.length, match.length)
  end

end