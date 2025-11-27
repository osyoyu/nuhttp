# frozen_string_literal: true

require 'minitest/autorun'
require 'nuhttp'

class RouterTest < Minitest::Test
  def test_root_path_routing
    router = NuHttp::Router.new
    router.register_route(:get, '/')

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    resolved = router.resolve(req)[0]
    assert_equal :get, resolved.method
    assert_equal '/', resolved.pattern
  end

  def test_toplevel_path_routing
    router = NuHttp::Router.new
    router.register_route(:get, '/top')

    req = NuHttp::Request.new(method: :get, path: '/top', query: '', body: nil)
    resolved = router.resolve(req)[0]
    assert_equal :get, resolved.method
    assert_equal '/top', resolved.pattern
  end

  def test_notfound_path_routing
    router = NuHttp::Router.new

    req = NuHttp::Request.new(method: :get, path: '/nonexistent', query: '', body: nil)
    resolved = router.resolve(req)[0]
    assert_equal :internal, resolved.method
    assert_nil resolved.pattern
  end
end
