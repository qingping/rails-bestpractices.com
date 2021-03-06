set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'capistrano_colors'
require 'bundler/capistrano'
require 'thinking_sphinx/deploy/capistrano'

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.3-p125@rails-bestpractices.com'
set :rvm_type, :user

set :application, "rails-bestpractices"
set :repository,  "git@github.com:railsbp/rails-bestpractices.com.git"

set :scm, :git
set :user, 'huangzhi'

set :rake, "bundle exec rake"

role :web, "app.rails-bestpractices.com"
role :app, "app.rails-bestpractices.com"
role :db,  "db.rails-bestpractices.com", :primary => true

before "deploy:assets:precompile", "config:init"
before "deploy:assets:precompile", "asset:init"
after "deploy:update_code", "asset:revision"

namespace :asset do
  task :init, :roles => :app do
    run "cd #{release_path}; #{rake} RAILS_ENV=#{rails_env} css_sprite:build"
  end

  task :revision, :roles => :app do
    run "cd #{release_path}; git ls-remote origin master | awk '{print $1}' > #{release_path}/public/REVISION"
  end
end

namespace :config do
  task :init do
    run "ln -nfs #{shared_path}/config/bitly.yml #{release_path}/config/bitly.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/mailers.yml #{release_path}/config/mailers.yml"
    run "ln -nfs #{shared_path}/config/omniauth.yml #{release_path}/config/omniauth.yml"
    run "ln -nfs #{shared_path}/config/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -nfs #{shared_path}/config/memcache.yml #{release_path}/config/memcache.yml"
    run "ln -nfs #{shared_path}/config/initializers/action_mailer.rb #{release_path}/config/initializers/action_mailer.rb"
    run "ln -nfs #{shared_path}/config/initializers/sphinx.rb #{release_path}/config/initializers/sphinx.rb"
  end
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    migrate
    cleanup
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
