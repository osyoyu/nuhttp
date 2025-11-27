# frozen_string_literal: true

require 'minitest/autorun'
require 'nuhttp'

class AppTest < Minitest::Test
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

  def test_subapp_mounting
    subapp = NuHttp.app do |b|
      b.get '/' do |c|
        c.text "subapp root"
      end

      b.get '/details' do |c|
        c.text "subapp details"
      end
    end

    app = NuHttp.app do |b|
      b.mount '/subapp', subapp
    end

    req = NuHttp::Request.new(method: :get, path: '/subapp/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal "subapp root", res.body

    req = NuHttp::Request.new(method: :get, path: '/subapp/details', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal "subapp details", res.body
  end
end
