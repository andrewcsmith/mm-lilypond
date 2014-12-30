require "minitest/autorun"
require "mm/lilypond"

module TestMM; end

class TestMM::TestLilypond < Minitest::Test
  def setup
    @lily_parser = MM::Lilypond.new
  end

  def test_get_duration
    assert_equal "1*2/3", @lily_parser.get_duration(MM::Ratio.new(3,2))
  end

  def test_get_basename
    assert_equal "e", @lily_parser.get_basename(MM::Ratio.new(9,8))
    assert_equal "fsharp", @lily_parser.get_basename(MM::Ratio.new(5,4))
    assert_equal "c", @lily_parser.get_basename(MM::Ratio.new(7,4))
    assert_equal "g", @lily_parser.get_basename(MM::Ratio.new(11,8))
  end

  def test_get_alteration
    assert_equal "Df", @lily_parser.get_alteration(MM::Ratio.new(5,4))
    assert_equal "Ds", @lily_parser.get_alteration(MM::Ratio.new(7,4))
  end

  def test_get_octave
    assert_equal ",,", @lily_parser.get_octave(MM::Ratio.new(1,4))
    assert_equal "'", @lily_parser.get_octave(MM::Ratio.new(9,4))
    assert_equal "", @lily_parser.get_octave(MM::Ratio.new(7,4))
  end

  def test_get_pitch
    assert_equal "a", @lily_parser.get_pitch(MM::Ratio.new(3,2))
    assert_equal "fsharpDf", @lily_parser.get_pitch(MM::Ratio.new(5,4))
    assert_equal "cDs", @lily_parser.get_pitch(MM::Ratio.new(7,4))
    assert_equal "cDs,", @lily_parser.get_pitch(MM::Ratio.new(7,8))
    assert_equal "d'", @lily_parser.get_pitch(MM::Ratio.new(2,1))
    assert_equal "d,", @lily_parser.get_pitch(MM::Ratio.new(1,2))
  end

  def test_get_full_note
    assert_equal "d'1*1/2", @lily_parser.full_note(MM::Ratio.new(2,1))
    assert_equal "aflatUfDs1*5/7", @lily_parser.full_note(MM::Ratio.new(7,5))
  end

  def test_render
    @lily_parser.template = File.read("test/test_template.ly.erb")
    exp = "music = { a1*2/3 cDs1*4/7 }\n"
    result = @lily_parser.render([MM::Ratio.new(3,2), MM::Ratio.new(7,4)])
    assert_equal exp, result
  end

  def test_offset
    @lily_parser.offset = 0
    assert_equal "c", @lily_parser.get_pitch(MM::Ratio.new(1,1))
    assert_equal "eDf", @lily_parser.get_pitch(MM::Ratio.new(5,4))
  end
end

