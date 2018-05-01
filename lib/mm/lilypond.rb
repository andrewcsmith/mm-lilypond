require 'mm'
require 'erb'

class MM::Lilypond
  VERSION = "1.1.0"

  attr_accessor :offset, :basenames, :prime_limit, :prime_steps
  attr_writer :template

  def initialize prime_limit: nil
    # offset is around the circle of fifths
    @offset = 2 
    @basenames = ["c", "g", "d", "a", "e", "b", 
                  "fsharp", "csharp", "gsharp", "dsharp", "asharp", "esharp", "bsharp", 
                  "fdoublesharp", "cdoublesharp", "gdoublesharp", "ddoublesharp", "adoublesharp", "edoublesharp", "bdoublesharp", 
                  "fdoubleflat", "cdoubleflat", "gdoubleflat", "ddoubleflat", "adoubleflat", "edoubleflat", "bdoubleflat",
                  "fflat", "cflat", "gflat", "dflat", "aflat", "eflat", "bflat", "f"]
    @prime_limit = prime_limit
    @prime_steps = [1, 4, -2, -1, 3]
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
    ratio.factors.reject {|f| @prime_limit && f[0] > @prime_limit}.map {|f|
      case f[0]
      when 5
        collect_string f[1], "f"
      when 7
        collect_string f[1], "s"
      when 11
        collect_string f[1] * -1, "e"
      when 13
        collect_string f[1], "t"
      end
    }.join("")
  end

  def get_octave ratio
    offset = (@offset * 4) % 7
    degrees = ratio.factors.inject(0) {|d, f|
      d + case f[0]
      when 2
        f[1] * 7
      when 3
        f[1] * 11
      when 5
        f[1] * 16
      when 7
        f[1] * 20
      when 11
        f[1] * 24
      when 13
        f[1] * 26
      else
        0
      end
    } + offset
    if degrees > 0
      (degrees / 7.0).floor.times.map {"'"}.join("")
    else
      (degrees / -7.0).ceil.times.map {","}.join("")
    end
  end

  def get_duration ratio
    "1*#{ratio.reciprocal.to_s}"
  end

  # Gets the cents deviation from the unaltered pitch (i.e., from the equal
  # tempered pitch of sharps, flats, naturals).
  def cents_deviation ratio
    unaltered = cents_of_unaltered ratio
    deviation = (ratio.cents % 1200) - unaltered
    if deviation < 0
      "#{deviation.round}"
    else
      "+#{deviation.round}"
    end
  end

  def cents_of_unaltered ratio
    (get_steps(ratio) * 7) % 12 * 100.0
  end

  def full_note ratio
    get_pitch(ratio) + get_duration(ratio)
  end

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
        f[1] * @prime_steps[0]
      when 5
        f[1] * @prime_steps[1]
      when 7
        f[1] * @prime_steps[2]
      when 11
        f[1] * @prime_steps[3]
      when 13
        f[1] * @prime_steps[4]
      else
        0
      end
    }
  end
end

