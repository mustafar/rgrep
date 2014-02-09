class GrepEngine

  def get_all_filenames(path = '.', exts)
    all_files = []
    Find.find(path) do |e|
      all_files.push(e) if !is_directory(e) and is_valid_file_path(e, exts)
    end
    all_files
  end

  def find_in_file(query_terms, file_name)
    matched_lines = Hash.new { |hash, key| hash[key] = Array.new }
    line_num = 0
    File.open(file_name).each do |line|
      query_terms.each do |q|
        if line.include? q
          matched_lines[q].push("#{file_name} | #{line_num += 1}: #{line}")
        end
      end
    end
    matched_lines
  end

  def find(query_terms, path = '.', exts = [])
    # init master match hash
    matches = Hash.new
    query_terms.each { |q| matches[q] = Array.new }

    # get all filenames
    file_names = get_all_filenames(path, exts)

    # iterate over each file and collect matches
    file_names.each { |f|
      matched_lines = find_in_file(query_terms, f)
      matches.merge(matched_lines) { |_, old_vals, new_vals| old_vals.concat(new_vals) }
    }
    matches
  end

  private

  def is_valid_file_path(file_path, exts)
    (is_in_hidden_folder(file_path) or !(exts.empty? or exts.include? File.extname(file_path))) ? false : true
  end

  def is_directory(file_path)
    File.directory?(file_path)
  end

  def is_in_hidden_folder(file_path)
    return file_path =~ /[\\\/]\.[0-9a-zA-Z]+[\\\/]/
  end

end