namespace :nightingale do
  namespace :utils do
    task :pretty_erb do
      sh 'find . -type f -name "*.erb" -exec htmlbeautifier {} \;'
    end

    task :pretty_jsx do
      sh 'find . -type f -name "*.jsx" -exec prettier --single-quote --write {} \;'
    end
  end
end
