require 'bundler'
Bundler.require

configure :development do
  set :database, {
    adapter: 'postgresql',
    encoding: 'unicode',
    database: 'abc_123',
    pool: 2
  }
end

configure :production do
  set :database, {
    adapter: 'postgresql',
    encoding: 'unicode',
    database: 'abc_123',
    pool: 2
  }
end

require_all 'app'
