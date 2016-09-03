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

  def test_metavars
    doc = <<-EOF
      ---
      author: Caleb Hyde
      ---

      # %{author}

      This was written by %{author}
    EOF

    expected_result = strip_whitespace <<-EOF
      ---
      author: Caleb Hyde
      ...

      <span class="interpolated" field="author">Caleb Hyde</span> {#author}
      ===========================================================

      This was written by <span class="interpolated" field="author">Caleb
      Hyde</span>
    EOF

    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/metavars.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/metavars_object.rb", __FILE__)))
  end

  def test_metavars_with_meta_string
    doc = <<-EOF
      ---
      author: 42
      ---

      # %{author}

      This was written by %{author}
    EOF

    expected_result = strip_whitespace <<-EOF
      ---
      author: 42
      ...

      42 {#author}
      ==

      This was written by 42
    EOF

    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/metavars.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/metavars_object.rb", __FILE__)))
  end

  def test_format_to_markdown
    doc = <<-EOF
      This document was converted to %{format}
    EOF

    expected_result = strip_whitespace <<-EOF
      This document was converted to markdown
    EOF

    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/format.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, filter: File.expand_path("../../examples/format_object.rb", __FILE__)))
  end

  def test_format_to_markdown_github
    doc = <<-EOF
      This document was converted to %{format}
    EOF

    expected_result = strip_whitespace <<-EOF
      This document was converted to markdown\\_github
    EOF

    assert_equal(expected_result, pandoc(doc, to: "markdown_github", filter: File.expand_path("../../examples/format.rb", __FILE__)))
    assert_equal(expected_result, pandoc(doc, to: "markdown_github", filter: File.expand_path("../../examples/format_object.rb", __FILE__)))
  end
end
