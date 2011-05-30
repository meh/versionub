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

module Versionub
  Types = {}

  def self.parse (text, type=:standard)
    return text if text.is_a?(Versionub::Type::Instance)

    Types[type.to_sym].parse(text.to_s)
  end

  def self.create (data, type=:standard)
     Types[type.to_sym].create(data)
  end

  def self.register (type, &block)
    Types[type.to_sym] = Versionub::Type.new(type.to_sym, &block)
  end
end

require 'versionub/types'

class String
  def to_version (type=:standard)
    Versionub.parse(self, type)
  end
end

class Hash
  def to_version (type=:standard)
    Versionub.create(self, type)
  end
end
