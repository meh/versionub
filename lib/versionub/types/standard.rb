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
    rule(version: subtree(:version)) {
      version.dup.each {|name, value|
        version[name] = case value
          when Array          then nil
          when Parslet::Slice then value.to_s
          else                     value
        end

        if !version[name]
          version.delete(name)
        end
      }

      version
    }
  end

  def major
    @data[:major].to_i
  end

  def minor
    @data[:minor].to_i
  end

  def tiny
    @data[:tiny].to_i
  end

  def bugfix
    if @data[:bugfix] && @data[:bugfix].match(/[^0-9]/)
      @data[:bugfix]
    else
      @data[:bugfix].to_i
    end
  end; alias tiny2 bugfix

  def patch
    @data[:patch].to_i
  end; alias p patch; alias patchlevel patch

  def release_candidate
    @data[:release_candidate].to_i if @data[:release_candidate]
  end; alias rc release_candidate

  def development
    @data[:development].to_i if @data[:development]
  end; alias d development; alias dev development;

  def alpha
    @data[:alpha].to_i if @data[:alpha]
  end; alias a alpha; alias alfa alpha; alias alpha_version alpha

  def beta
    @data[:beta].to_i if @data[:beta]
  end; alias b beta; alias beta_version beta

  def patch?;             !!@data[:patch];       end
  def release_candidate?; !!@data[:rc];          end
  def development?;       !!@data[:development]; end
  def alpha?;             !!@data[:alpha];       end
  def beta?;              !!@data[:beta];        end

  def release_type
    return :alpha             if alpha?
    return :beta              if beta?
    return :patch             if patch?
    return :development       if development?
    return :release_candidate if release_candidate?
    return :final
  end

  include Comparable

  def <=> (value)
    value = Versionub.parse(value, type)

    if (tmp = bugfix <=> value.bugfix) != 0
      return tmp
    end

    if (tmp = tiny <=> value.tiny) != 0
      return tmp
    end

    if (tmp = minor <=> value.minor) != 0
      return tmp
    end

    if (tmp = major <=> value.major) != 0
      return tmp
    end

    if patch?
      if value.patch?
        return patch <=> value.patch
      else
        return 1
      end
    elsif value.patch?
      return -1
    end

    if release_candidate?
      if value.release_candidate?
        return release_candidate <=> value.release_candidate
      else
        return -1
      end
    elsif value.release_candidate?
      return 1
    end

    if beta?
      if value.beta?
        return beta <=> value.beta
      else
        return -1
      end
    elsif value.beta?
      return 1
    end

    if alpha?
      if value.alpha?
        return alpha <=> value.alpha
      else
        return -1
      end
    elsif value.alpha?
      return 1
    end

    0
  end

  def to_s
    return super if @text

    "#{major}.#{minor}.#{tiny}"
  end
end
