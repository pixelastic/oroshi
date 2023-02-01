# Update dependencies (yarn, bundler) if needed
module DependencyHelper

  # Update dependencies if their list changed since we pulled
  def update_dependencies(old_commit)
    update_dependencies_node(old_commit)
    update_dependencies_ruby(old_commit)
  end

  # Run yarn install if yarn.lock.json changed
  def update_dependencies_node(old_commit)
    filepath = File.join(repo_root, 'yarn.lock')
    return unless File.exist?(filepath)
    return unless file_changed(old_commit, current_commit, filepath)

    lockfile = File.join(repo_root, '.git', 'yarn-install-in-progress')
    run_in_background('yarn install', lockfile)
  end
  
  # Run bundle install if Gemfile changed
  def update_dependencies_ruby(old_commit)
    filepath = File.join(repo_root, 'Gemfile')
    return unless File.exist?(filepath)
    return unless file_changed(old_commit, current_commit, filepath)
    puts "Gemfile has changed. Running bundle install"

    lockfile = File.join(repo_root, '.git', 'bundle-install-in-progress')
    run_in_background('bundle install', lockfile)
  end
end
