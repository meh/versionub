#--
# Copyleft meh. [http://meh.paranoid.pk | meh@paranoici.org]
#
# This file is part of versionub.
#
# versionub is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# versionub is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with versionub. If not, see <http://www.gnu.org/licenses/>.
#++

Versionub.register :standard do
  parse do
    rule(:part) { match['0-9'].repeat }

    rule(:dot) { str('.') }
    rule(:separator) { match['.\-_\s'] }

    rule(:version) {
      part.as(:major) >>
      
      (dot >> part.as(:minor)).maybe >>
      (dot >> part.as(:tiny)).maybe >>

      (dot.maybe >> (match['a-z'] >> match['0-9a-z'].absent? | part).as(:bugfix)).maybe >>

      (separator.maybe >> (
        ((str('development') | str('dev') | str('d')) >>
         (part.as(:development) | any.as(:development))) |

        ((str('alpha') | str('alfa') | str('a')) >>
         (part.as(:alpha) | any.as(:alpha))) |

        ((str('beta') | str('b')) >>
         (part.as(:beta) | any.as(:beta))) |

        ((str('pre')) >>
          (part.as(:pre) | any.as(:pre))) |

        ((str('rc')) >>
         (part.as(:rc) | any.as(:rc))) |

        ((str('patch') | str('p')).maybe >>
         (part.as(:patch) | any.as(:patch)))
      ).maybe)
    }

    rule(:whole) {
      version.as(:version)
    }

    root :whole
  end

  transform do
    rule(:version => subtree(:version)) {
      version.delete(:bugfix) if version[:bugfix].is_a?(Array)

      version.dup.each {|name, value|
        version[name] = case value
          when Array          then 0
          when Parslet::Slice then value.to_s
          else                     value
        end

        version.delete(name) unless version[name]
      }

      version
    }
  end

  [:major, :minor, :tiny, [:patch, :p, :patchlevel]].each {|part|
    part = [part].flatten
    name = part.shift

    define_method name do
      @data[name].to_i
    end

    part.each {|synonym|
      alias_method synonym, name
    }
  }

  def bugfix
    if @data[:bugfix] && @data[:bugfix].match(/[^0-9]/)
      @data[:bugfix]
    else
      @data[:bugfix].to_i
    end
  end; alias tiny2 bugfix

  [:patch, [:release_candidate, :rc], :pre, [:beta, :b, :beta_version], [:alpha, :a, :alpha_version], [:development, :d, :dev]].each {|part|
    part = [part].flatten
    name = part.shift

    define_method "#{name}?" do
      !!@data[name]
    end

    define_method name do
      @data[name].to_i if send "#{name}?"
    end unless respond_to?(name)

    part.each {|synonym|
      alias_method synonym, name
    }
  }

  def release_type
    return :alpha             if alpha?
    return :beta              if beta?
    return :development       if development?
    return :pre               if pre?
    return :release_candidate if release_candidate?
    return :patch             if patch?
    return :final
  end

  def <=> (value)
    value = Versionub.parse(value, type)

    [:major, :minor, :tiny, :bugfix].each {|name|
      if (tmp = send(name) <=> value.send(name)) != 0
        return tmp
      end
    }

    if patch?
      if value.patch?
        return patch <=> value.patch
      else
        return 1
      end
    elsif value.patch?
      return -1
    end

    parts = [:release_candidate, :pre, :beta, :alpha, :development]
    
    parts.each_with_index {|name, index|
      if send("#{name}?")
        if value.send("#{name}?")
          return send(name) <=> value.send(name)
        elsif parts[(index + 1) .. -1].any? { |n| value.send("#{n}?") }
          return 1
        else
          return -1
        end
      elsif value.send("#{name}?")
        return -1
      end
    }

    0
  end

  def to_s
    return super unless empty?

    "#{major}.#{minor}.#{tiny}"
  end
end
