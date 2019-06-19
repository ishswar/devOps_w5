# helloworld.py

from nameko.rpc import rpc

class BackEndService:
    name = "backEnd_service"

    @rpc
    def getFile(self, name):
            file = open(name, "r")
            return file.read()

#	    return "Hello, {}!".format("START:"+file.read()+":END")
