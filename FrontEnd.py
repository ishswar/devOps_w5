from nameko.standalone.rpc import ClusterRpcProxy

config = {
    'AMQP_URI': "amqp://guest:guest@192.168.33.76:7600//"  # e.g. "pyamqp://guest:guest@localhost"
}

#n.rpc.greeting_service.hello

with ClusterRpcProxy(config) as cluster_rpc:
    rest = cluster_rpc.backEnd_service.getFile("testfile.text")
    print("File Content of file testfile.text: \n####################################################\n"+ rest + "\n####################################################")
