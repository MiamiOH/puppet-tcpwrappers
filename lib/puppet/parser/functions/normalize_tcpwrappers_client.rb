require 'ipaddr'

#
module Puppet::Parser::Functions
  newfunction(:normalize_tcpwrappers_client, type: :rvalue, doc: 'Converts the argument into a TCP Wrappers-friendly client specification') do |args|
    unless args.length == 1
      raise Puppet::ParseError, 'normalize_tcpwrappers_client: excepting 1 argument'
    end
    client = args[0]
    unless client.is_a? String
      raise Puppet::ParseError, 'normalize_tcpwrappers_client: argument must be a String'
    end

    case client
    when %r{^(\d+\.)(\d+\.\d+\.\d+/(8|255\.0\.0\.0))?$}
      Regexp.last_match(1)
    when %r{^(\d+\.\d+\.)(\d+\.\d+/(16|255\.255\.0\.0))?$}
      Regexp.last_match(1)
    when %r{^(\d+\.\d+\.\d+\.)(\d+/(24|255\.255\.255\.0))?$}
      Regexp.last_match(1)
    when %r{^(\d+\.\d+\.\d+\.\d+)(/(32|255\.255\.255\.255))?$}
      Regexp.last_match(1)
    when %r{^(\d+\.\d+\.\d+\.\d+)/(\d+)$}
      ip      = Regexp.last_match(1)
      masklen = Regexp.last_match(2)
      ip      = IPAddr.new(ip).mask(masklen).to_s
      netmask = IPAddr.new('255.255.255.255').mask(masklen).to_s
      "#{ip}/#{netmask}"
    when %r{^\.?[a-z\d_\-.]+$}, %r{^/[^ \n\t,:#]+$}, 'ALL', 'LOCAL', 'PARANOID'
      # Hostname, FQDN, suffix, filename, keyword, etc.
      client
    else
      raise Puppet::ParseError, "normalize_tcpwrappers_client: invalid spec: #{client}"
    end
  end
end
