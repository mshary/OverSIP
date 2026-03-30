#!/usr/bin/env ruby

lines = File.readlines('Rakefile')
lines.each_with_index do |line, i|
  if line.strip == 'OVERSIP_COMPILE_ITEMS = OVERSIP_EXTENSIONS.map {|e| e[:lib]} << "bin/oversip_stud"'
    lines[i] = 'OVERSIP_COMPILE_ITEMS = OVERSIP_EXTENSIONS.map {|e| e[:lib]}'
    break
  end
end

File.write('Rakefile', lines.join)
puts "Patched Rakefile"