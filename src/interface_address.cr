require "./interface_address/*"
require "socket"

module InterfaceAddress
  def self.get! : Set(IfAddr)
    if_addr_list = Set(IfAddr).new
    if_addrs = C.getifaddrs out pointer_if_addrs
    root_pointer = pointer_if_addrs

    unless if_addrs.zero?
      C.freeifaddrs ifa: root_pointer
      return if_addr_list
    end

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

    C.freeifaddrs ifa: root_pointer
    if_addr_list
  end

  def self.get_ip_addresses! : Set(Socket::IPAddress)
    set = get!.map(&.ip_address).to_set

    set << Socket::IPAddress.new Socket::IPAddress::UNSPECIFIED6, 0_i32
    set << Socket::IPAddress.new Socket::IPAddress::UNSPECIFIED, 0_i32

    set
  end

  def self.get_ip_addresses!(port : Int32) : Set(Socket::IPAddress)
    if_addrs = get!.map { |if_addr| Socket::IPAddress.new address: if_addr.ip_address.address, port: port }

    if_addrs << Socket::IPAddress.new Socket::IPAddress::UNSPECIFIED6, port
    if_addrs << Socket::IPAddress.new Socket::IPAddress::UNSPECIFIED, port

    if_addrs.to_set
  end

  def self.includes?(ip_address : Socket::IPAddress, interface_port : Int32) : Bool
    ip_addresses = get_ip_addresses! port: interface_port
    ip_addresses.includes? ip_address
  end
end
