#!/usr/bin/env bash
# Vérifie que tous les front matters YAML des Markdown suivis par Git sont valides.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

ruby - "$ROOT" <<'RUBY'
require "yaml"

root = ARGV.fetch(0)
paths = Dir.chdir(root) { `git ls-files -z -- '*.md'`.split("\0") }
errors = []

paths.each do |path|
  content = File.binread(File.join(root, path))
  next unless content.start_with?("---\n")

  closing = content.index("\n---\n", 4)
  if closing.nil?
    errors << "#{path}: front matter non terminé"
    next
  end

  YAML.safe_load(content[4...closing], aliases: true)
rescue Psych::SyntaxError => error
  errors << "#{path}: #{error.message.lines.first.strip}"
end

if errors.empty?
  puts "✓ front matters YAML Markdown valides (#{paths.length} fichiers suivis)"
else
  warn errors.join("\n")
  exit 1
end
RUBY
