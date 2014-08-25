name             "couchbase"
maintainer       "Julian C. Dunn"
maintainer_email "jdunn@opscode.com"
license          "MIT"
description      "Installs/Configures Couchbase"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "1.0.0"

%w{debian ubuntu centos redhat oracle amazon scientific windows citadel}.each do |os|
  supports os
end

%w{apt windows yum}.each do |d|
  depends d
end

recipe "couchbase::server", "Installs couchbase-server"
recipe "couchbase::client", "Installs libcouchbase"
recipe "couchbase::moxi", "Installs moxi-server"
