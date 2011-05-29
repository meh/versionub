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

    rule(:separator) { match['.-_'] }

    rule(:version) {
      part.as(:major) >> separator.maybe >>
      part.maybe.as(:minor) >> separator.maybe >>
      part.maybe.as(:bugfix)
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

    extend Comparable

    def <=> (value)
      # TODO: itself
    end
  end
end
