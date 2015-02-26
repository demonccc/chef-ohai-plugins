#
# Author:: Claudio César Sánchez Tejeda (<demonccc@gmail.com>)
# Copyright:: Copyright (c) 2015 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:Lxc) do
  provides "virtualization/lxc"

  depends "virtualization"

  collect_data(:linux) do
    lxc_host = (File.read("/proc/self/cgroup") =~ %r{\d:[^:]+:/.*$}) ? true : false
    unless virtualization.nil? || !(virtualization[:system].eql?("lxc") || lxc_host)  
      if lxc_host
	so = shell_out("lxc-ls -f -F name,state,ipv4,ipv6,autostart,pid,memory,ram,swap")
        if so.exitstatus === 0
          containers = so.stdout.split("\n")
          containers.delete_at(0)
          containers.delete_at(0)
          puts containers
          unless containers.empty?
            virtualization[:lxc] = Mash.new
            virtualization[:lxc][:role] = "host"
            virtualization[:lxc][:container] = Mash.new
            containers.each do |item|
              container = item.split(" ")
              virtualization[:lxc][:container][container[0]] = Mash.new
              virtualization[:lxc][:container][container[0]][:state] = container[1]
              virtualization[:lxc][:container][container[0]][:ipv4] = container[2]
              virtualization[:lxc][:container][container[0]][:ipv6] = container[3]
              virtualization[:lxc][:container][container[0]][:autostart] = container[4]
              virtualization[:lxc][:container][container[0]][:pid] = container[5]
              virtualization[:lxc][:container][container[0]][:memory] = container[6]
              virtualization[:lxc][:container][container[0]][:ram] = container[7]
              virtualization[:lxc][:container][container[0]][:swap] = container[8]
            end
          end
        end
      end
    end
  end

end
