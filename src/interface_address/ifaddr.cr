struct IfAddr
  property interface_name : String
  property ip_address : Socket::IPAddress
  property netmask : Socket::IPAddress

  def initialize(@interface_name : String, @ip_address : Socket::IPAddress, @netmask : Socket::IPAddress)
  end
end
