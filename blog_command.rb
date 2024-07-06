require "blog_command"

require 'thor'
require 'open3'

BLOG_REPOSITORY_DIR = File.join(ENV["HOME"], "Documents/blog")

class Main < Thor
  desc "new PATH", "Create a new blog post with PATH"
  method_option :title, type: :string
  method_option :draft, type: :boolean
  def new(path)
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      opts = []
      opts << "--title=\"#{options[:title]}\"" if options[:title]
      opts << "--draft" if options[:draft]
      system("blogsync post --custom-path #{path } #{opts.join(" ")} ongaeshi.hatenablog.com")
      system("git add ongaeshi.hatenablog.com/entry/#{path}.md")
      system("git commit -m \"Add #{path}\"") 
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
