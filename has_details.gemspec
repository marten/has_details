spec = Gem::Specification.new do |s|
  s.name = 'has_details'
  s.version = '0.0.1'
  s.summary = "Attribute serialization for ActiveRecord."
  s.description = %{HasDetails is a Rails plugin to allow you to serialize an arbitrary amount of (optional) attributes into a column.}
  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_path = 'lib'
  s.authors = %w(Marten\ Veldthuis Jason\ Weathered)
  s.email = %w(marten@veldthuis.com jason@jasoncodes.com)
  s.homepage = "http://github.com/jasoncodes/has_details"
  s.add_runtime_dependency 'activerecord', %w(~>2.3.0)
end
