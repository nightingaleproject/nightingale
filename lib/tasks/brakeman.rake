desc %('Brakeman security check')
task :brakeman do
  if system('brakeman -Az')
    exit 0
  else
    exit 1
  end
end
