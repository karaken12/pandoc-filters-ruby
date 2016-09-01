# coding: utf-8
require_relative 'test_helper'

class ExamplesTest < Minitest::Test
  include PandocHelper

  def test_caps
    doc = <<-EOF
      This is the caps sample with Äüö.
    EOF

    expected_result = strip_whitespace <<-EOF
      THIS IS THE CAPS SAMPLE WITH Äüö.
    EOF

    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/caps.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/caps_object.rb", __FILE__)))
  end

  def test_comments
    doc = <<-EOF
      Regular text with Äüö.

      <!-- BEGIN COMMENT -->

      This is a comment with Äüö

      <!-- END COMMENT -->

      This is regular text again.
    EOF

    expected_result = strip_whitespace <<-EOF
      Regular text with Äüö.

      This is regular text again.
    EOF

    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/comments.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/comments_object.rb", __FILE__)))
  end

  def test_deflists
    doc = <<-EOF
      Some Definitions

      Term 1

      :   Definition 1

      Term 2 with *inline markup*

      :   Definition 2

              { some code, part of Definition 2 }

          Third paragraph of definition 2.

      Term with Äüö

      : Definition with Äüö


      Regular Text.
    EOF

    expected_result = strip_whitespace <<-EOF
      Some Definitions

      -   **Term 1**

          Definition 1

      -   **Term 2 with *inline markup***

          Definition 2

              { some code, part of Definition 2 }

          Third paragraph of definition 2.

      -   **Term with Äüö**

          Definition with Äüö

      Regular Text.
    EOF

    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/deflists.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/deflists_object.rb", __FILE__)))
  end
end
