from nameko.standalone.rpc import ClusterRpcProxy
from nameko.web.handlers import http

config = {
    'AMQP_URI': "amqp://guest:guest@192.168.33.76:7600//"  # e.g. "pyamqp://guest:guest@localhost"
}

#n.rpc.greeting_service.hello

class HttpService:
	name = "http_service"

	@http('GET', '/get/<string:value>')
	def get_method(self, request, value):
		print("Input is "+ value)
		with ClusterRpcProxy(config) as cluster_rpc:
			rest = cluster_rpc.backEnd_service.getFileContents(value)
			print("File Content of file testfile1.text: \n@@@@@@@@@@@@@@@@@##############################\n"+ rest + "\n####################################################")
			if rest.startswith( '~' ):
			 return 404, "File "+ value + " NOT_FOUND"
			else:
			 return rest

# with ClusterRpcProxy(config) as cluster_rpc:
#     rest = cluster_rpc.backEnd_service.getFile("testfile.text")
#     print("File Content of file testfile.text: \n####################################################\n"+ rest + "\n####################################################")
