# frozen_string_literal: true

require 'csv'
require 'net/http'
require 'uri'
require 'json'
require 'optparse'

# Default settings
options = {
  input_file: nil,
  output_format: 'csv',
  sleep_between_requests: 1,
  sleep_between_retries: 3,
  max_retries: 3,
  timeout_seconds: 10
}

# Parse command-line options
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby check_redirects.rb [options]'

  opts.on('-i', '--input FILE', 'Input file path (required)') do |v|
    options[:input_file] = v
  end

  opts.on('-o', '--output FORMAT', 'Output format (csv or json, default: csv)') do |v|
    options[:output_format] = v.downcase
  end

  opts.on('--sleep SECONDS', Integer, 'Sleep seconds between requests (default: 1)') do |v|
    options[:sleep_between_requests] = v
  end

  opts.on('--retry-sleep SECONDS', Integer, 'Sleep seconds between retries (default: 3)') do |v|
    options[:sleep_between_retries] = v
  end

  opts.on('--max-retries N', Integer, 'Maximum retries on error (default: 3)') do |v|
    options[:max_retries] = v
  end

  opts.on('--timeout SECONDS', Integer, 'Request timeout seconds (default: 10)') do |v|
    options[:timeout_seconds] = v
  end

  opts.on('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end.parse!

# Validate required options
unless options[:input_file]
  puts 'Error: Input file is required. Use -i or --input to specify.'
  exit 1
end

unless %w[csv json].include?(options[:output_format])
  puts 'Error: Output format must be csv or json.'
  exit 1
end

# Read input file
lines = File.readlines(options[:input_file], chomp: true)

# Create URL list
urls = []
first_line = lines.first

if first_line.include?(',')
  csv_data = CSV.parse(lines.join("\n"))
  urls = if first_line.match?(%r{\Ahttps?://})
           csv_data.map { |row| row[0] } # No header
         else
           csv_data.drop(1).map { |row| row[0] } # Skip header
         end
else
  urls = lines # Simple text list
end

# Store results
results = []
start_time = Time.now

urls.each_with_index do |url, index|
  retries = 0
  begin
    puts "[#{index + 1}/#{urls.size}] Checking: #{url}"

    uri = URI.parse(url)
    initial_status = nil
    final_url = nil

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', read_timeout: options[:timeout_seconds], open_timeout: options[:timeout_seconds]) do |http|
      response = http.head(uri.request_uri)

      initial_status = response.code

      while response.is_a?(Net::HTTPRedirection)
        location = response['location']
        uri = URI.join(uri, location)
        response = Net::HTTP.get_response(uri)
      end

      final_url = uri.to_s
    end

    results << { old_url: url, final_url: final_url, status_code: initial_status }

  rescue => e
    retries += 1
    if retries <= options[:max_retries]
      puts "Retrying (attempt #{retries}): #{url} Reason: #{e.message}"
      sleep options[:sleep_between_retries]
      retry
    else
      puts "Failed: #{url} Error: #{e.message}"
      results << { old_url: url, final_url: 'Error', status_code: e.message }
    end
  end

  sleep options[:sleep_between_requests]
end

# Output results
base_name = File.basename(options[:input_file], File.extname(options[:input_file]))
output_file = "#{base_name}_results.#{options[:output_format]}"

if options[:output_format] == 'csv'
  CSV.open(output_file, 'w') do |csv|
    csv << ['Old URL', 'Final URL', 'Redirect Status Code / Error']
    results.each do |r|
      csv << [r[:old_url], r[:final_url], r[:status_code]]
    end
  end
elsif options[:output_format] == 'json'
  File.open(output_file, 'w') do |file|
    file.write(JSON.pretty_generate(results))
  end
end

end_time = Time.now
elapsed_time = end_time - start_time

puts "Done! Output saved to #{output_file}."
puts "Elapsed time: #{elapsed_time.round(2)} seconds"
