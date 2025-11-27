# frozen_string_literal: true

require 'minitest/autorun'
require 'nuhttp'
require 'nuhttp/rack_port'

class RackPortTest < Minitest::Test
  def test_env_to_request_bare_request
    env = {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/',
      'QUERY_STRING' => ''
    }
    req = NuHttp::RackPort.new(env).send(:env_to_request, env)

    assert_equal 'GET', req.method
    assert_equal '/', req.path
    assert_equal '', req.query
    assert_equal({}, req.headers)
  end

  def test_env_to_request_with_headers
    env = {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/',
      'QUERY_STRING' => '',
      'CONTENT_LENGTH' => '42',
      'CONTENT_TYPE' => 'text/plain',
      'HTTP_HOST' => 'example.com',
      'HTTP_X_CUSTOM_HEADER' => 'CustomValue'
    }
    req = NuHttp::RackPort.new(env).send(:env_to_request, env)

    assert_equal 'GET', req.method
    assert_equal '/', req.path
    assert_equal '', req.query
    assert_equal({
      'Content-Length' => 42,
      'Content-Type' => 'text/plain',
      'Host' => 'example.com',
      'X-Custom-Header' => 'CustomValue'
    }, req.headers)
  end

  def test_env_to_request_with_body
    env = {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/',
      'QUERY_STRING' => ''
    }
    req = NuHttp::RackPort.new(env).send(:env_to_request, env)

    assert_equal 'GET', req.method
    assert_equal '/', req.path
    assert_equal '', req.query
    assert_equal({}, req.headers)
  end
end
