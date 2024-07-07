require "blog_command"

require 'thor'
require 'open3'

BLOG_REPOSITORY_DIR = File.join(ENV["HOME"], "Documents/blog")

class Main < Thor
  desc "new PATH", "Create a new blog post with PATH"
  method_option :title, type: :string
  def new(path)
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      opts = []
      opts << "--title=\"#{options[:title]}\"" if options[:title]
      system("blogsync post --custom-path #{path} --draft #{opts.join(" ")} ongaeshi.hatenablog.com", in: IO::NULL)
    end
  end

  desc "edit", "Open blog folder in editor"
  def edit
    system("code #{BLOG_REPOSITORY_DIR}")
  end

  desc "commit", "Push blog changes and git commit"
  method_option :message, type: :string, aliases: '-m'
  def commit
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      list = `git status --porcelain`.split("\n").map { |s| s.split[1] }
      list += `git diff --name-only`.split("\n")
      list += `git diff --name-only origin/main..HEAD`.split("\n")
      list.each do |path|
        system("blogsync push #{path}")
      end

      system("git add .")
      message = options[:message] || "Commit blog changes"
      system("git commit -m \"#{message}\"") 
    end
  end

  desc "pull", "Pull blog changes"
  def pull
    Dir.chdir(BLOG_REPOSITORY_DIR) do
      system("blogsync pull ongaeshi.hatenablog.com")

      system("git add .")
      system("git commit -m \"#{Pull blog changes}\"") 
    end
  end

  desc "open", "Open the blog page"
  def open
    system("explorer https://ongaeshi.hatenablog.com")
  end

  desc "manage", "Open the entries management screen"
  def manage
    system("explorer https://blog.hatena.ne.jp/tuto0621/ongaeshi.hatenablog.com/entries")
  end
end

Main.start(ARGV)
