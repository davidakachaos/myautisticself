require "bundler/setup"
require "jekyll/task/i18n"

Jekyll::Task::I18n.define do |task|
  # Set translate target locales.
  task.locales = ["en"]
  # Set all *.md texts as translate target contents.
  task.files = Rake::FileList["**/*.md"]
  # Remove internal files from target contents.
  task.files -= Rake::FileList["_drafts/**/*.md"]
  task.files -= Rake::FileList["_site/**/*.md"]
  # Remove translated files from target contents.
  task.locales.each do |locale|
    task.files -= Rake::FileList["#{locale}/**/*.md"]
  end
end