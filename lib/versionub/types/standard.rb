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
  parser do
    rule(:part) { match['0-9'].repeat }

    rule(:separator) { match['.\-_\s'] }

    rule(:version) {
      part.as(:major) >>
      
      (separator >> part.as(:minor)).maybe >>
      (separator >> part.as(:tiny)).maybe >>

      (separator.maybe >> (match['a-z'] >> match['0-9a-z'].absent? | part).as(:bugfix)).maybe >>

      (separator.maybe >> (
        ((str('patch') | str('p')) >>
         (part.as(:patch) | any.as(:patch))) |

        ((str('development') | str('dev') | str('d')) >>
         (part.as(:development) | any.as(:development))) |

        ((str('alpha') | str('alfa') | str('a')) >>
         (part.as(:alpha) | any.as(:alpha))) |

        ((str('beta') | str('b')) >>
         (part.as(:beta) | any.as(:beta))) |

        ((str('rc')) >>
         (part.as(:rc) | any.as(:rc)))
      ).maybe)
    }
    
    root :version
  end

  def major
    @data[:major].to_s if @data[:major] && !@data[:major].is_a?(Array)
  end

  def minor
    @data[:minor].to_s if @data[:minor] && !@data[:minor].is_a?(Array)
  end

  def tiny
    @data[:tiny].to_s if @data[:tiny] && !@data[:tiny].is_a?(Array)
  end

  def bugfix
    @data[:bugfix].to_s if @data[:bugfix] && !@data[:bugfix].is_a?(Array)
  end; alias tiny2 bugfix

  def patch
    @data[:patch].to_s if @data[:patch] && !@data[:patch].is_a?(Array)
  end; alias p patch

  def release_candidate
    @data[:rc].is_a?(Array) ? '0' : @data[:rc].to_s
  end; alias rc release_candidate

  def development
    @data[:development].is_a?(Array) ? '0' : @data[:development].to_s
  end; alias d development; alias dev development;

  def alpha
    @data[:alpha].is_a?(Array) ? '0' : @data[:alpha].to_s
  end; alias a alpha; alias alfa alpha

  def beta
    @data[:beta].is_a?(Array) ? '0' : @data[:beta].to_s
  end; alias b beta

  def major?;             !!major;       end
  def minor?;             !!minor;       end
  def tiny?;              !!tiny;        end
  def bugfix?;            !!bugfix;      end
  def patch?;             !!patch;       end
  def release_candidate?; !!rc;          end
  def development?;       !!development; end
  def alpha?;             !!alpha;       end
  def beta?;              !!beta;        end

  include Comparable

  def <=> (value)
    value = Versionub.parse(value)

    if bugfix?
      if value.bugfix?
        return bugfix.to_i <=> value.bugfix.to_i
      else
        return 1
      end
    elsif value.bugfix?
      return -1
    end

    if tiny?
      if value.tiny? && (tmp = tiny.to_i <=> value.tiny.to_i) != 0
        return tmp
      end
    elsif value.tiny?
      return -1
    end

    if minor?
      if value.minor? && (tmp = minor.to_i <=> value.minor.to_i) != 0
        return tmp
      end
    elsif value.minor?
      return -1
    end

    if major?
      if value.major? && (tmp = major.to_i <=> value.major.to_i) != 0
        return tmp
      end
    end

    if patch?
      if value.patch?
        return patch.to_i <=> value.patch.to_i
      else
        return 1
      end
    end

    if release_candidate?
      if value.release_candidate?
        return release_candidate.to_i <=> value.release_candidate.to_i
      else
        return -1
      end
    end

    if beta?
      if value.beta?
        return beta.to_i <=> value.beta.to_i
      else
        return -1
      end
    end

    if alpha?
      if value.alpha?
        return alpha.to_i <=> value.alpha.to_i
      else
        return -1
      end
    end

    0
  end
end
