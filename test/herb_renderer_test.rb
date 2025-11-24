# frozen_string_literal: true

require 'minitest/autorun'
require 'nuhttp'
require 'nuhttp/herb_renderer'

class HerbRendererTest < Minitest::Test
  def setup
    @htmlerb_file = Tempfile.open("greeting.html.erb")
    @htmlerb_file.tap {|f| f.write("<p>hello, <%= name %></p>\n"); f.flush }
  end

  def teardown
    @htmlerb_file.close!
  end

  def test_renders_template
    html = NuHttp::HerbRenderer.new.render(@htmlerb_file.path, name: "world")
    assert_equal "<p>hello, world</p>\n", html
  end

  def test_context_render_sets_html_response
    app = NuHttp.app do |b|
      b.get '/' do |c|
        c.erb(@htmlerb_file.path, { name: "world" })
      end
    end

    req = NuHttp::Request.new(method: :get, path: '/', query: '', body: nil)
    res = app.dispatch(req)

    assert_equal "text/html; charset=utf-8", res.headers['Content-Type']
    assert_equal "<p>hello, world</p>\n", res.body
  end
end
