Citrus :: Parsing Expressions for Ruby

Citrus is a compact and powerful parsing library for
[Ruby](http://ruby-lang.org/) that combines the elegance and expressiveness of
the language with the simplicity and power of
[parsing expressions](http://en.wikipedia.org/wiki/Parsing_expression_grammar).


# Installation


Via [RubyGems](http://rubygems.org/):

    $ gem install citrus

From a local copy:

    $ git clone git://github.com/mjijackson/citrus.git
    $ cd citrus
    $ rake package install


# Background


In order to be able to use Citrus effectively, you must first understand the
difference between syntax and semantics. Syntax is a set of rules that govern
the way letters and punctuation may be used in a language. For example, English
syntax dictates that proper nouns should start with a capital letter and that
sentences should end with a period.

Semantics are the rules by which meaning may be derived in a language. For
example, as you read a book you are able to make some sense of the particular
way in which words on a page are combined to form thoughts and express ideas
because you understand what the words themselves mean and you understand what
they mean collectively.

Computers use a similar process when interpreting code. First, the code must be
parsed into recognizable symbols or tokens. These tokens may then be passed to
an interpreter which is responsible for forming actual instructions from them.

Citrus is a pure Ruby library that allows you to perform both lexical analysis
and semantic interpretation quickly and easily. Using Citrus you can write
powerful parsers that are simple to understand and easy to create and maintain.

In Citrus, there are three main types of objects: rules, grammars, and matches.

## Rules

A [Rule](http://mjijackson.com/citrus/api/classes/Citrus/Rule.html) is an object
that specifies some matching behavior on a string. There are two types of rules:
terminals and non-terminals. Terminals can be either Ruby strings or regular
expressions that specify some input to match. For example, a terminal created
from the string "end" would match any sequence of the characters "e", "n", and
"d", in that order. Terminals created from regular expressions may match any
sequence of characters that can be generated from that expression.

Non-terminals are rules that may contain other rules but do not themselves match
directly on the input. For example, a Repeat is a non-terminal that may contain
one other rule that will try and match a certain number of times. Several other
types of non-terminals are available that will be discussed later.

Rule objects may also have semantic information associated with them in the form
of Ruby modules. Rules use these modules to extend the matches they create.

## Grammars

A [Grammar](http://mjijackson.com/citrus/api/classes/Citrus/Grammar.html) is a
container for rules. Usually the rules in a grammar collectively form a complete
specification for some language, or a well-defined subset thereof.

A Citrus grammar is really just a souped-up Ruby
[module](http://ruby-doc.org/core/classes/Module.html). These modules may be
included in other grammar modules in the same way that Ruby modules are normally
used. This property allows you to divide a complex grammar into more manageable,
reusable pieces that may be combined at runtime. Any rule with the same name as
a rule in an included grammar may access that rule with a mechanism similar to
Ruby's `super` keyword.

## Matches

A [Match](http://mjijackson.com/citrus/api/classes/Citrus/Match.html) object
represents a successful recognition of some piece of the input. Matches are
created by rule objects during a parse.

Matches are arranged in a tree structure where any match may contain any number
of other matches. Each match contains information about its own subtree. The
structure of the tree is determined by the way in which the rule that generated
each match is used in the grammar. For example, a match that is created from a
nonterminal rule that contains several other terminals will likewise contain
several matches, one for each terminal. However, this is an implementation
detail and should be relatively transparent to the user.

Match objects may be extended with semantic information in the form of methods.
These methods should provide various interpretations for the semantic value of a
match.


# Syntax


The most straightforward way to compose a Citrus grammar is to use Citrus' own
custom grammar syntax. This syntax borrows heavily from Ruby, so it should
already be familiar to Ruby programmers.

## Terminals

Terminals may be represented by a string or a regular expression. Both follow
the same rules as Ruby string and regular expression literals.

    'abc'         # match "abc"
    "abc\n"       # match "abc\n"
    /abc/i        # match "abc" in any case
    /\xFF/        # match "\xFF"

Character classes and the dot (match anything) symbol are supported as well for
compatibility with other parsing expression implementations.

    [a-z0-9]      # match any lowercase letter or digit
    [\x00-\xFF]   # match any octet
    .             # match any single character, including new lines

Also, strings may use backticks instead of quotes to indicate that they should
match in a case-insensitive manner.

    `abc`         # match "abc" in any case

Besides case sensitivity, case-insensitive strings have the same behavior as
double quoted strings.

See [Terminal](http://mjijackson.com/citrus/api/classes/Citrus/Terminal.html) and
[StringTerminal](http://mjijackson.com/citrus/api/classes/Citrus/StringTerminal.html)
for more information.

## Repetition

Quantifiers may be used after any expression to specify a number of times it
must match. The universal form of a quantifier is `N*M` where `N` is the minimum
and `M` is the maximum number of times the expression may match.

    'abc'1*2      # match "abc" a minimum of one, maximum of two times
    'abc'1*       # match "abc" at least once
    'abc'*2       # match "abc" a maximum of twice

Additionally, the minimum and maximum may be omitted entirely to specify that an
expression may match zero or more times.

    'abc'*        # match "abc" zero or more times

The `+` and `?` operators are supported as well for the common cases of `1*` and
`*1` respectively.

    'abc'+        # match "abc" one or more times
    'abc'?        # match "abc" zero or one time

See [Repeat](http://mjijackson.com/citrus/api/classes/Citrus/Repeat.html) for
more information.

## Lookahead

Both positive and negative lookahead are supported in Citrus. Use the `&` and
`!` operators to indicate that an expression either should or should not match.
In neither case is any input consumed.

    'a' &'b'      # match an "a" that is followed by a "b"
    'a' !'b'      # match an "a" that is not followed by a "b"
    !'a' .        # match any character except for "a"

A special form of lookahead is also supported which will match any character
that does not match a given expression.

    ~'a'          # match all characters until an "a"
    ~/xyz/        # match all characters until /xyz/ matches

When using this operator (the tilde), at least one character must be consumed
for the rule to succeed.

See [AndPredicate](http://mjijackson.com/citrus/api/classes/Citrus/AndPredicate.html),
[NotPredicate](http://mjijackson.com/citrus/api/classes/Citrus/NotPredicate.html),
and [ButPredicate](http://mjijackson.com/citrus/api/classes/Citrus/ButPredicate.html)
for more information.

## Sequences

Sequences of expressions may be separated by a space to indicate that the rules
should match in that order.

    'a' 'b' 'c'   # match "a", then "b", then "c"
    'a' [0-9]     # match "a", then a numeric digit

See [Sequence](http://mjijackson.com/citrus/api/classes/Citrus/Sequence.html)
for more information.

## Choices

Ordered choice is indicated by a vertical bar that separates two expressions.
When using choice, each expression is tried in order. When one matches, the
rule returns the match immediately without trying the remaining rules.

    'a' | 'b'       # match "a" or "b"
    'a' 'b' | 'c'   # match "a" then "b" (in sequence), or "c"

It is important to note when using ordered choice that any operator binds more
tightly than the vertical bar. A full chart of operators and their respective
levels of precedence is below.

See [Choice](http://mjijackson.com/citrus/api/classes/Citrus/Choice.html) for
more information.

## Labels

Match objects may be referred to by a different name than the rule that
originally generated them. Labels are added by placing the label and a colon
immediately preceding any expression.

    chars:/[a-z]+/  # the characters matched by the regular expression
                    # may be referred to as "chars" in an extension
                    # method

## Extensions

Extensions may be specified using either "module" or "block" syntax. When using
module syntax, specify the name of a module that is used to extend match objects
in between less than and greater than symbols.

    [a-z0-9]5*9 <CouponCode>  # match a string that consists of any lower
                              # cased letter or digit between 5 and 9
                              # times and extend the match with the
                              # CouponCode module

Additionally, extensions may be specified inline using curly braces. When using
this method, the code inside the curly braces may be invoked by calling the
`value` method on the match object.

    [0-9] { to_str.to_i }     # match any digit and return its integer value when
                              # calling the #value method on the match object

Note that when using the inline block method you may also specify arguments in
between vertical bars immediately following the opening curly brace, just like
in Ruby blocks.

## Super

When including a grammar inside another, all rules in the child that have the
same name as a rule in the parent also have access to the `super` keyword to
invoke the parent rule.

    grammar Number
      rule number
        [0-9]+
      end
    end

    grammar FloatingPoint
      include Number

      rule number
        super ('.' super)?
      end
    end

In the example above, the `FloatingPoint` grammar includes `Number`. Both have a
rule named `number`, so `FloatingPoint#number` has access to `Number#number` by
means of using `super`.

See [Super](http://mjijackson.com/citrus/api/classes/Citrus/Super.html) for more
information.

## Precedence

The following table contains a list of all Citrus symbols and operators and
their precedence. A higher precedence indicates tighter binding.

Operator                  | Name                      | Precedence
------------------------- | ------------------------- | ----------
`''`                      | String (single quoted)    | 7
`""`                      | String (double quoted)    | 7
<code>``</code>           | String (case insensitive) | 7
`[]`                      | Character class           | 7
`.`                       | Dot (any character)       | 7
`//`                      | Regular expression        | 7
`()`                      | Grouping                  | 7
`*`                       | Repetition (arbitrary)    | 6
`+`                       | Repetition (one or more)  | 6
`?`                       | Repetition (zero or one)  | 6
`&`                       | And predicate             | 5
`!`                       | Not predicate             | 5
`~`                       | But predicate             | 5
`<>`                      | Extension (module name)   | 4
`{}`                      | Extension (literal)       | 4
`:`                       | Label                     | 3
`e1 e2`                   | Sequence                  | 2
<code>e1 &#124; e2</code> | Ordered choice            | 1

## Grouping

As is common in many programming languages, parentheses may be used to override
the normal binding order of operators. In the following example parentheses are
used to make the vertical bar between `'b'` and `'c'` bind tighter than the
space between `'a'` and `'b'`.

    'a' ('b' | 'c')   # match "a", then "b" or "c"


# Example


Below is an example of a simple grammar that is able to parse strings of
integers separated by any amount of white space and a `+` symbol.

    grammar Addition
      rule additive
        number plus (additive | number)
      end

      rule number
        [0-9]+ space
      end

      rule plus
        '+' space
      end

      rule space
        [ \t]*
      end
    end

Several things to note about the above example:

* Grammar and rule declarations end with the `end` keyword
* A sequence of rules is created by separating expressions with a space
* Likewise, ordered choice is represented with a vertical bar
* Parentheses may be used to override the natural binding order
* Rules may refer to other rules in their own definitions simply by using the
  other rule's name
* Any expression may be followed by a quantifier

## Interpretation

The grammar above is able to parse simple mathematical expressions such as "1+2"
and "1 + 2+3", but it does not have enough semantic information to be able to
actually interpret these expressions.

At this point, when the grammar parses a string it generates a tree of
[Match](http://mjijackson.com/citrus/api/classes/Citrus/Match.html) objects.
Each match is created by a rule and may itself be comprised of any number of
submatches.

Submatches are created whenever a rule contains another rule. For example, in
the grammar above `number` matches a string of digits followed by white space.
Thus, a match generated by this rule will contain two submatches.

We can define a method inside a set of curly braces that will be used to extend
a particular rule's matches. This works in similar fashion to using Ruby's
blocks. Let's extend the `Addition` grammar using this technique.

    grammar Addition
      rule additive
        (number plus term:(additive | number)) {
          capture(:number).value + capture(:term).value
        }
      end

      rule number
        ([0-9]+ space) {
          to_str.to_i
        }
      end

      rule plus
        '+' space
      end

      rule space
        [ \t]*
      end
    end

In this version of the grammar we have added two semantic blocks, one each for
the `additive` and `number` rules. These blocks contain code that we can
execute by calling `value` on match objects that result from those rules. It's
easiest to explain what is going on here by starting with the lowest level
block, which is defined within `number`.

Inside this block we see a call to another method, namely `to_str`. When called
in the context of a match object, this method returns the match's internal
string object. Thus, the call to `to_str.to_i` should return the integer value
of the match.

Similarly, matches created by `additive` will also have a `value` method. Notice
the use of the `term` label within the rule definition. This label allows the
match that is created by the choice between `additive` and `number` to be
retrieved using `capture(:term)`. The value of an additive match is determined
to be the values of its `number` and `term` matches added together using Ruby's
addition operator. Note that the plural form `captures(:term)` can be used to
get an array of matches for a given label (e.g. when the label belongs to a
repetition).

Since `additive` is the first rule defined in the grammar, any match that
results from parsing a string with this grammar will have a `value` method that
can be used to recursively calculate the collective value of the entire match
tree.

To give it a try, save the code for the `Addition` grammar in a file called
addition.citrus. Next, assuming you have the Citrus
[gem](https://rubygems.org/gems/citrus) installed, try the following sequence of
commands in a terminal.

    $ irb
    > require 'citrus'
     => true
    > Citrus.load 'addition'
     => [Addition]
    > m = Addition.parse '1 + 2 + 3'
     => #<Citrus::Match ...
    > m.value
     => 6

Congratulations! You just ran your first piece of Citrus code.

One interesting thing to notice about the above sequence of commands is the
return value of [Citrus#load](http://mjijackson.com/citrus/api/classes/Citrus.html#M000003).
When you use `Citrus.load` to load a grammar file (and likewise
[Citrus#eval](http://mjijackson.com/citrus/api/classes/Citrus.html#M000004) to
evaluate a raw string of grammar code), the return value is an array of all the
grammars present in that file.

Take a look at
[calc.citrus](http://github.com/mjijackson/citrus/blob/master/lib/citrus/grammars/calc.citrus)
for an example of a calculator that is able to parse and evaluate more complex
mathematical expressions.

## Additional Methods

If you need more than just a `value` method on your match object, you can attach
additional methods as well. There are two ways to do this. The first lets you
define additional methods inline in your semantic block. This block will be used
to create a new Module using [Module#new](http://ruby-doc.org/core/classes/Module.html#M001682).
Using the `Addition` example above, we might refactor the `additive` rule to
look like this:

    rule additive
      (number plus term:(additive | number)) {
        def lhs
          capture(:number).value
        end

        def rhs
          capture(:term).value
        end

        def value
          lhs + rhs
        end
      }
    end

Now, in addition to having a `value` method, matches that result from the
`additive` rule will have a `lhs` and a `rhs` method as well. Although not
particularly useful in this example, this technique can be useful when unit
testing more complex rules. For example, using this method you might make the
following assertions in a unit test:

    match = Addition.parse('1 + 4')
    assert_equal(1, match.lhs)
    assert_equal(4, match.rhs)
    assert_equal(5, match.value)

If you would like to abstract away the code in a semantic block, simply create
a separate Ruby module (in another file) that contains the extension methods you
want and use the angle bracket notation to indicate that a rule should use that
module when extending matches.

To demonstrate this method with the above example, in a Ruby file you would
define the following module.

    module Additive
      def lhs
        capture(:number).value
      end

      def rhs
        capture(:term).value
      end

      def value
        lhs + rhs
      end
    end

Then, in your Citrus grammar file the rule definition would look like this:

      rule additive
        (number plus term:(additive | number)) <Additive>
      end

This method of defining extensions can help keep your grammar files cleaner.
However, you do need to make sure that your extension modules are already loaded
before using `Citrus.load` to load your grammar file.


# Testing


Citrus was designed to facilitate simple and powerful testing of grammars. To
demonstrate how this is to be done, we'll use the `Addition` grammar from our
previous [example](example.html). The following code demonstrates a simple test
case that could be used to test that our grammar works properly.

    class AdditionTest < Test::Unit::TestCase
      def test_additive
        match = Addition.parse('23 + 12', :root => :additive)
        assert(match)
        assert_equal('23 + 12', match)
        assert_equal(35, match.value)
      end

      def test_number
        match = Addition.parse('23', :root => :number)
        assert(match)
        assert_equal('23', match)
        assert_equal(23, match.value)
      end
    end

The key here is using the `:root` option when performing the parse to specify
the name of the rule at which the parse should start. In `test_number`, since
`:number` was given the parse will start at that rule as if it were the root
rule of the entire grammar. The ability to change the root rule on the fly like
this enables easy unit testing of the entire grammar.

Also note that because match objects are themselves strings, assertions may be
made to test equality of match objects with string values.

## Debugging

When a parse fails, a [ParseError](http://mjijackson.com/citrus/api/classes/Citrus/ParseError.html)
object is generated which provides a wealth of information about exactly where
the parse failed including the offset, line number, line text, and line offset.
Using this object, you could possibly provide some useful feedback to the user
about why the input was bad. The following code demonstrates one way to do this.

    def parse_some_stuff(stuff)
      match = StuffGrammar.parse(stuff)
    rescue Citrus::ParseError => e
      raise ArgumentError, "Invalid stuff on line %d, offset %d!" %
        [e.line_number, e.line_offset]
    end

In addition to useful error objects, Citrus also includes a means of visualizing
match trees in the console via `Match#dump`. This can help when determining
which rules are generating which matches and how they are organized in the
match tree.


# Extras


Several files are included in the Citrus repository that make it easier to work
with grammar files in various editors.

## TextMate

To install the Citrus [TextMate](http://macromates.com/) bundle, simply
double-click on the `Citrus.tmbundle` file in the `extras` directory.

## Vim

To install the [Vim](http://www.vim.org/) scripts, copy the files in
`extras/vim` to a directory in Vim's
[runtimepath](http://vimdoc.sourceforge.net/htmldoc/options.html#\'runtimepath\').


# Examples


The project source directory contains several example scripts that demonstrate
how grammars are to be constructed and used. Each Citrus file in the examples
directory has an accompanying Ruby file that contains a suite of tests for that
particular file.

The best way to run any of these examples is to pass the name of the Ruby file
directly to the Ruby interpreter on the command line, e.g.:

    $ ruby -Ilib examples/calc_test.rb

This particular invocation uses the `-I` flag to ensure that you are using the
version of Citrus that was bundled with that particular example file (i.e. the
version that is contained in the `lib` directory).


# Links


Discussion around Citrus happens on the [citrus-users Google group](http://groups.google.com/group/citrus-users).

The primary resource for all things to do with parsing expressions can be found
on the original [Packrat and Parsing Expression Grammars page](http://pdos.csail.mit.edu/~baford/packrat)
at MIT.

Also, a useful summary of parsing expression grammars can be found on
[Wikipedia](http://en.wikipedia.org/wiki/Parsing_expression_grammar).

Citrus draws inspiration from another Ruby library for writing parsing
expression grammars, Treetop. While Citrus' syntax is similar to that of
[Treetop](http://treetop.rubyforge.org), it's not identical. The link is
included here for those who may wish to explore an alternative implementation.


# License


Copyright 2010-2011 Michael Jackson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

The software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and non-infringement. In no event shall the
authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the software or the use or other dealings in
the software.
