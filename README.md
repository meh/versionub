Versionub, the version parser for nubs
======================================

Versionub is a simple library to manage versions, somewhat like [Versionomy](https://github.com/dazuma/versionomy)
but a lot easier to implement another version type and far more shorter in code (which usually is better with equal
functionality).

The only feature that's missing right now is #bump, I don't really need it but it wouldn't be hard to implement,
if someone wants to implement it I'll gladly merge the changes, the file to change is `lib/versionub/types/standard.rb`.

It uses Parslet for parsing capabilities.

``` ruby
require 'versionub'

# Create version numbers that understand their own semantics
v1 = Versionub.create(major: 1, minor: 3, tiny: 2)
v1.major                                 # => 1
v1.minor                                 # => 3
v1.tiny                                  # => 2
v1.release_type                          # => :final
v1.patchlevel                            # => 0

# Parse version numbers, including common prerelease syntax
v2 = Versionub.parse('1.4a3')
v2.major                                 # => 1
v2.minor                                 # => 4
v2.tiny                                  # => 0
v2.release_type                          # => :alpha
v2.alpha_version                         # => 3
v2 > v1                                  # => true
v2.to_s                                  # => '1.4a3'

# Version numbers are semantically self-adjusting.
v3 = Versionub.parse('1.4.0b2')
v3.major                                 # => 1
v3.minor                                 # => 4
v3.tiny                                  # => 0
v3.release_type                          # => :beta
v3.alpha_version                         # raises NoMethodError
v3.beta_version                          # => 2
v3 > v2                                  # => true
v3.to_s                                  # => '1.4.0b2'

# Comparisons are semantic, so will behave as expected even if the
# formatting is set up differently.
v9 = Versionub.parse('2.0.0.0')
v9.to_s                                  # => '2.0.0.0'
v9 == Versionub.parse('2')              # => true

# Patchlevels are supported when the release type is :final
v10 = Versionub.parse('2.0-1')
v10.patchlevel                           # => 1
v10.to_s                                 # => '2.0.0-1'
v11 = Versionub.parse('2.0p1')
v11.patchlevel                           # => 1
v11.to_s                                 # => '2.0p1'
v11 == v10                               # => true

# You can create your own format from scratch
Versionub.register :windows do
  parse do
    rule(:part) { match['0-9'].repeat }

    rule(:separator) { match['.-_\s'] }

    rule(:version) {
      part.as(:major) >> separator.maybe >>
      str('SP').maybe >> part.as(:minor)
    }

    root :version
  end

  def major
    @data[:major].to_s if @data[:major]
  end

  def minor
    @data[:minor].to_s if @data[:minor]
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

v12 = Versionub.parse('2008 SP2', :windows)
v12.major                                  # => 2008
v12.minor                                  # => 2
v12.to_s                                   # => '2008 SP2'
v12 == Versionub.parse('2008.2', :windows) # => true

# You can also use String#to_version and Hash#to_version to parse or create a version
v13 = '1.3'.to_version
v13.major                 # => 1
v13.minor                 # => 3

v14 = { major: 1, minor: 3 }.to_version
v13.major                 # => 1
v13.minor                 # => 3
```
