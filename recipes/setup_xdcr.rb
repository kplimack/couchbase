#
# Cookbook Name:: couchbase
# Recipe:: xdcr
#
remote_cluster_name = "west_cluster"
src_cluster_name ="east_cluster"

src_cluster = search(:node, "role:#{src_cluster_name}")
src_node=src_cluster[0]["ipaddress"]

remote_cluster = search(:node, "role:#{remote_cluster_name}")
remote_node=remote_cluster[0]["ipaddress"]

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

Chef::Log.info "Get uuid information of the remote cluster"
s_uuid = `curl 'http://#{username}:#{password}@#{remote_node}:8091/pools' | python -mjson.tool |sed -e 's/[","]/''/g' | awk -F "uuid: " '{print $2}'`
uuid= s_uuid.strip

xdcr_ref "Create XDCR Replication reference  " do
  uuid uuid
  remote_name "remote_link"
  remote_node remote_node
  username username
  password password
end

xdcr_start "Setting up replication from bucket default to default" do
  uuid uuid
  to_cluster "remote_link"
  from_bucket "default"
  to_bucket "default"
  replication_type "continuous"
  username username
  password password
end
