require 'mm'
require 'erb'

class MM::Lilypond
  VERSION = "1.0.0"

  attr_accessor :offset, :basenames

  def initialize
    @offset = 2 
    @basenames = ["c", "g", "d", "a", "e", "b", "fsharp", "csharp", "gsharp", "dsharp", "asharp", "esharp", "bsharp", "fdoublesharp", "cdoublesharp", "gdoublesharp", "ddoublesharp", "adoublesharp", "edoublesharp", "bdoublesharp", "bdoubleflat", "edoubleflat", "adoubleflat", "ddoubleflat", "gdoubleflat", "cdoubleflat", "fdoubleflat", "fflat", "cflat", "gflat", "dflat", "aflat", "eflat", "bflat", "f"]
  end

  def get_pitch ratio
    basename = get_basename ratio
    alteration = get_alteration ratio
    octave = get_octave ratio
    basename + alteration + octave
  end

  def get_basename ratio
    @basenames[@offset + get_steps(ratio)].dup
  end

  def get_alteration ratio
    ratio.factors.map {|f|
      case f[0]
      when 5
        collect_string f[1], "f"
      when 7
        collect_string f[1], "s"
      when 11
        collect_string f[1], "e"
      when 13
        collect_string f[1], "t"
      end
    }.join("")
  end

  def get_octave ratio
    degrees = ratio.factors.inject(0) {|d, f|
      d + case f[0]
      when 2
        f[1] * 7
      when 3
        f[1] * 11
      when 5
        f[1] * 17
      when 7
        f[1] * 20
      when 11
        f[1] * 24
      else
        0
      end
    }
    if degrees > 0
      (degrees / 7.0).floor.times.map {"'"}.join("")
    else
      (degrees / -7.0).ceil.times.map {","}.join("")
    end
  end

  def get_duration ratio
    "1*#{ratio.reciprocal.to_s}"
  end

  def full_note ratio
    get_pitch(ratio) + get_duration(ratio)
  end

  attr_writer :template

  def render ratios
    my_music = ratios.map {|r| self.full_note r}.join(" ")
    output = ERB.new @template
    output.result(binding)
  end

  private

  def collect_string times, string
    if times > 0
      times.times.collect {"D#{string}"}
    else
      (times * -1).times.collect {"U#{string}"}
    end
  end

  def get_steps ratio
    ratio.factors.inject(0) {|memo, f|
      memo + case f[0]
      when 3
        f[1]
      when 5
        f[1] * 4
      when 7
        f[1] * -2
      when 11
        f[1] * -1
      else
        0
      end
    }
  end
end

