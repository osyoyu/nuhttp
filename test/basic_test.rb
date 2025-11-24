# frozen_string_literal: true

require 'minitest/autorun'
require 'nuhttp'

class BasicTest < Minitest::Test
  def test_basic_test
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.res.body = "Hello, World!\n"
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal "Hello, World!\n", res.body
  end
end
