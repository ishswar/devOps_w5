# helloworld.py

from nameko.rpc import rpc
import sys
import os

class BackEndService:
	name = "backEnd_service"

	@rpc
	def getFileContents(self, name):
			print(sys.version) 
			try:
				file = open(os.path.join("files",name), "r")
				filetext = file.read()
			except:
				 filetext = "~Error-File: "+name+" NotFound"
			
			return filetext
