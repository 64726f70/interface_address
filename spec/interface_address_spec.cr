require "./spec_helper.cr"

describe InterfaceAddress do
  it "works" do
    interfaces = InterfaceAddress.get!
    interfaces.size.should be > 0_i32
  end

  it "has important properties" do
    interfaces = InterfaceAddress.get!
    result = interfaces.first

    result.interface_name.should be_a String
    result.ip_address.should be_a Socket::IPAddress
    result.netmask.should be_a Socket::IPAddress
  end
end
