def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines

dns_raw = Array.new
dns_records = Hash.new
block = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
$re = /\A#{block}\.#{block}\.#{block}\.#{block}\z/
dns_raw = File.readlines("zone")
dns_raw = dns_raw.reject { |line| line.empty? || line[0] == "#" }
dns_raw = dns_raw.map { |line| line.strip.split(", ") }

def parse_dns(iteratableData)
  hash_records = Hash.new
  iteratableData.each do |item|
    hash_records[item[1]] = item[2]
  end
  return hash_records
end

def resolve(dns_records, lookup_chain, domain)
  if (dns_records.has_key?(domain))
    hash_value = dns_records[domain]
    lookup_chain.push(hash_value)
    if ($re =~ hash_value)
      return lookup_chain
    else
      domain = hash_value
      return resolve(dns_records, lookup_chain, domain)
    end
  else
    lookup_chain = ["Error: record not found for " + "#{domain}"]
  end

  return lookup_chain
end

# ..
# ..
# FILL YOUR CODE HERE
# ..
# ..

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
