#
# Cookbook Name:: couchbase
# Recipe:: setup_cluster
#

#cluster_name = node["cluster_name"]
cluster_name = "west_cluster"
prefix = "ns_1@"
separator=","
known_nodes=prefix+self.node["ipaddress"]

case node['couchbase']['server']['security_source']
when 'node_attr'
  username = node['couchbase']['server']['username']
  password = node['couchbase']['server']['password']
when 'citadel'
  sec_conf = JSON.parse(citadel[node['couchbase']['server']['citadel']['key']])
  username = sec_conf['username']
  password = sec_conf['password']
else
  username = node['couchbase']['server']['username']
  password = node['couchbase']['server']['password']
end

cluster = search(:node, "role:#{cluster_name}")
cluster.each do |node|
  if node["ipaddress"] != self.node["ipaddress"]
    log " Adding new nodes"
    known_nodes=known_nodes+separator+prefix+"#{node["ipaddress"]}"
    add_node "#{cluster_name}" do
      hostname node["ipaddress"]
      username username
      password password
    end
  end
end

ejected_nodes = ""
cluster_rebal "Rebalance-In Nodes to form a cluster  " do
  ejectedNodes ejected_nodes
  knownNodes known_nodes
  username username
  password password
end

ruby_block "wait for rebalance completion " do
  block do
    sleep 5
  end
end

#couchbase_bucket "#{cluster_name}" do
#  memory_quota_mb 100

#  username node['couchbase']['server']['username']
#  password node['couchbase']['server']['password']
#end
