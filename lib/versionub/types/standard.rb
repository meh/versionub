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

    rule(:separator) { match['.-_\s'] }

    rule(:version) {
      part.as(:major) >> separator.maybe >>
      part.maybe.as(:minor) >> separator.maybe >>
      part.maybe.as(:bugfix) >> separator.maybe >> (
        ((str('d') | str('development') | str('dev')) >>
         (part.as(:development) | any.as(:development))) |

        ((str('a') | str('alpha') | str('alfa')) >>
         (part.as(:alpha) | any.as(:alpha))) |

        ((str('b') | str('beta')) >>
         (part.as(:beta) | any.as(:beta))) |

        ((str('rc')) >>
         (part.as(:rc) | any.as(:rc)))
      ).maybe
    }
    
    root :version
  end

  callbacks do
    def major
      @data[:major].to_s if @data[:major]
    end

    def minor
      @data[:minor].to_s if @data[:minor]
    end

    def bugfix
      @data[:bugfix].to_s if @data[:bugfix]
    end

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

    def release_candidate?
      !!@data[:rc]
    end

    def development?
      !!@data[:development]
    end

    def alpha?
      !!@data[:alpha]
    end

    def beta?
      !!@data[:beta]
    end

    include Comparable

    def <=> (value)
      value = Versionub.parse(value)

      if release_candidate? && value.release_candidate? && (tmp = (rc <=> value.rc))
        return tmp
      end

      if development? && value.development? && (tmp = (development <=> value.development))
        return tmp
      end

      if alpha? && value.alpha? && (tmp = (alpha <=> value.alpha))
        return tmp
      end

      if beta? && value.beta? && (tmp = (beta <=> value.beta))
        return tmp
      end

      if (tmp = (bugfix <=> value.bugfix)) != 0
        return tmp
      end

      if (tmp = (minor <=> value.minor)) != 0
        return tmp
      end

      if (tmp = (major <=> value.major)) != 0
        return tmp
      end

      0
    end
  end
end
