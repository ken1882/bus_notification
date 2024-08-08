require 'mechanize'
require 'socksify'

# Randomly grabbed internet proxies that should treated unsafe
# Use this to bypass IP restrictions
module WildProxy
    ProxyCycle = (Rails.configuration.wild_proxies.dup << nil).cycle
    
    # Get or set a proxy
    def self.next_proxy(agent=nil)
        addr = ProxyCycle.next
        if addr.nil?
            agent.set_proxy(nil, nil) if agent
            TCPSocket::socks_server = nil
            TCPSocket::socks_port   = nil
            return 
        end
        loc, port = addr.split('://').last.split(':')
        if addr.start_with? 'socks5'
            TCPSocket::socks_server = loc
            TCPSocket::socks_port = port
        elsif agent
            agent.set_proxy(loc, port)
        end
        addr
    end
end