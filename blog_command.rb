require "blog_command"

require 'thor'
require 'open3'

BLOG_REPOSITORY_DIR = File.join(ENV["HOME"], "Documents/blog")

class Main < Thor
  desc "new TITLE", "Create a new blog post with TITLE"
  def new(title)
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      system("blogsync post --draft --title=\"#{title}\" ongaeshi.hatenablog.com")
    end
  end

  desc "edit", "Open the blog folder in VSCode"
  def edit
    system("code #{BLOG_REPOSITORY_DIR}")
  end

  desc "push", "Push blog changes"
  def push
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      list = `git diff --name-only`.split("\n")
      list += `git diff --name-only origin/main..HEAD`.split("\n")
      list.each do |path|
        system("blogsync push #{path}")
      end
    end
  end

  desc "pull", "Pull blog changes"
  def pull
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      system("blogsync pull ongaeshi.hatenablog.com")
    end
  end

  desc "open", "Open the blog page"
  def open
    system("explorer https://ongaeshi.hatenablog.com")
  end
end

Main.start(ARGV)
