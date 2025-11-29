# frozen_string_literal: true

require 'minitest/autorun'
require 'nuhttp'

class ContextResponseTest < Minitest::Test
  def test_status
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.status(201)
        c.text("Created")
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal 201, res.status
    assert_equal "Created", res.body
  end

  def test_header
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.status(302)
        c.header('Location', 'https://example.com')
        c.text("Redirecting")
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal 302, res.status
    assert_equal 'https://example.com', res.headers['Location']
  end

  def test_html_helper
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.html("<!DOCTYPE html><html><body><h1>hello, world</h1></body></html>")
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal "text/html; charset=utf-8", res.headers['Content-Type']
    assert_equal "<!DOCTYPE html><html><body><h1>hello, world</h1></body></html>", res.body
  end

  def test_text_helper
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.text("hello, world")
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal "text/plain; charset=utf-8", res.headers['Content-Type']
    assert_equal "hello, world", res.body
  end

  def test_json_helper
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.json({hello: "world"})
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)
    assert_equal "application/json", res.headers['Content-Type']
    assert_equal '{"hello":"world"}', res.body
  end
end
