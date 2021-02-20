require "./interface_address/*"
require "socket"

module InterfaceAddress
  def self.get! : Set(IfAddr)
    if_addr_list = Set(IfAddr).new
    if_addrs = C.getifaddrs out pointer_if_addrs
    return if_addr_list unless if_addrs.zero?

    while pointer_if_addrs
      begin
        if_addr = IfAddr.new String.new(pointer_if_addrs.value.ifa_name), Socket::IPAddress.from(pointer_if_addrs.value.ifa_addr, sizeof(LibC::Sockaddr)), Socket::IPAddress.from(pointer_if_addrs.value.ifa_netmask, sizeof(LibC::Sockaddr))
        if_addr_list << if_addr
      rescue ex : Exception
        message = ex.message

        if message
          # Ignore errors from Socket::Address
          raise ex unless message.starts_with? "Unsupported family type"
        end
      end

      pointer_if_addrs = pointer_if_addrs.value.ifa_next
    end

    if_addr_list
  end

  def self.get_ipaddresses! : Set(Socket::IPAddress)
    get!.map(&.ip_address).to_set
  end

  def self.get_ipaddresses!(port : Int32) : Set(Socket::IPAddress)
    if_addrs = get!.map { |if_addr| Socket::IPAddress.new address: if_addr.ip_address.address, port: port }
    if_addrs.to_set
  end

  def self.includes?(ip_address : Socket::IPAddress, interface_port : Int32) : Bool
    ipaddresses = get_ipaddresses! port: interface_port
    ipaddresses.includes? ip_address
  end
end
