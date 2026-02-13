Pod::Spec.new do |s|
  s.name     = 'ShapeReducer'
  s.version  = '2.0.0'
  s.license  = { :type => "BSD", :file => "LICENSE" }
  s.summary  = 'Path optimization using the Douglas-Peucker Line Approximation Algorithm.'
  s.homepage = 'https://github.com/tomislav/ShapeReducer-objc'
  s.authors  = { 'Tomislav Filipcic' => 'tomislav@me.com' }
  s.source   = { :git => 'https://github.com/tomislav/ShapeReducer-objc.git', :tag => "2.0.0" }
  s.requires_arc = false
  s.source_files = 'ShapeReducer/*.{h,m}'
  s.ios.deployment_target = '12.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{h,m}'
  end
end
