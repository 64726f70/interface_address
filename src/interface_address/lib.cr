lib C
  struct Ifaddrs
    ifa_next : Ifaddrs*
    ifa_name : LibC::Char*
    ifa_flags : LibC::UInt
    ifa_addr : LibC::Sockaddr*
    ifa_netmask : LibC::Sockaddr*
    ifa_destaddr : LibC::Sockaddr*
    ifa_data : Void*
  end

  fun getifaddrs(ifap : Ifaddrs**) : LibC::Int
  fun freeifaddrs(ifa : Ifaddrs*) : Void*
end
