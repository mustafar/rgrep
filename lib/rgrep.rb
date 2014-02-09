require 'rgrep/version'
require 'rgrep/grep_engine'
require 'find'

module RGrep

  def self.find(query, path = '.', exts = '', do_pretty_print = false)
    run_find([query], path, exts, do_pretty_print)
  end

  def self.find_all(query_file, path = '.', exts = '', do_pretty_print = false)
    query_terms = []
    File.open(query_file).each do |line|
      line.strip!
      query_terms.push(line) if line.length > 0
    end
    run_find(query_terms, path, exts, do_pretty_print)
  end

  private

  def self.run_find(query, path = '.', exts = '', do_pretty_print = false)
    grep = GrepEngine.new
    matches = grep.find(query, path, exts.split(',').map(&:strip))
    pretty_print(matches) if do_pretty_print
    matches = nil if do_pretty_print
    matches
  end

  def self.pretty_print(map = Hash.new { |hash, key| hash[key] = Array.new })
    no_matches = []
    seen_first_match = false
    map.each do |key, value|
      if value.empty?
        no_matches.push(key)
      else
        #print section title
        unless seen_first_match
          puts
          puts 'MATCHES'
          puts '==========='
        end
        seen_first_match = true

        puts '--- ' + key + ' ---'
        puts value.each { |l| puts l }
        puts
      end
    end
    unless no_matches.empty?
      puts
      puts 'NO MATCHES'
      puts '==========='
      no_matches.each { |nm| puts nm }
      puts
    end
  end

end
