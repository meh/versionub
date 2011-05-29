Gem::Specification.new {|s|
    s.name         = 'versionub'
    s.version      = '0.0.2.3'
    s.author       = 'meh.'
    s.email        = 'meh@paranoici.org'
    s.homepage     = 'http://github.com/meh/versionub'
    s.platform     = Gem::Platform::RUBY
    s.summary      = 'A library to manage version strings.'
    s.files        = Dir.glob('lib/**/*.rb')
    s.require_path = 'lib'

    s.add_dependency('parslet')
}
