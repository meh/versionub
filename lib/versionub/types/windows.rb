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

Versionub.register :windows do
  parser do
    rule(:part) { match['0-9'].repeat }

    rule(:separator) { match['.-_\s'] }

    rule(:version) {
      part.as(:major) >> separator.maybe >>
      str('SP').maybe >> part.as(:minor)
    }
  end

  def major
    @data[:major] if @data[:major]
  end

  def minor
    @data[:minor] if @data[:minor]
  end

  include Comparable

  def <=> (value)
    value = Versionub.parse(value)

    if (tmp = (minor <=> value.minor)) != 0
      return tmp
    end

    if (tmp = (major <=> value.major)) != 0
      return tmp
    end

    0
  end
end
