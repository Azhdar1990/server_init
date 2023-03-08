import os
import json
import requests
import hashlib

# ADD below lines to CSF csf.allow
#Include /etc/csf/allowed/bunnycdn.conf
#Include /etc/csf/allowed/cloudflare.conf

update = False
apis = [
	{
		'name'		: 'BunnyCDN',
		'enable'	: True,
		'json'		: True,
		'file'		: '/etc/csf/allowed/bunnycdn.conf',
		'url'		: [
			'https://bunnycdn.com/api/system/edgeserverlist'
		],
	},

	{
		'name'		: 'Cloudflare',
		'enable'	: True,
		'json'		: False,
		'file'		: '/etc/csf/allowed/cloudflare.conf',
		'url'		: [
			'https://www.cloudflare.com/ips-v4',
			'https://www.cloudflare.com/ips-v6',
		],
	},
]

for api in apis:

	# VARS
	name 		= api['name']
	last_file 	= name + ".last"
	ips 		= ""

	print("******************")
	print(name)
	print("******************")
	
	# GET IP LIST FROM API URL
	for url in api['url']:

		response = requests.get(url, verify=False)

		if response.status_code == 200:
			if (api['json']):
				ip_dict = json.loads(response.text)
				for ip in ip_dict:
					ips += ip + "\n"
			else:
				ips += response.text
		else:
			print('Error with URL:' + url)

	# IP LIST
	if len(ips) == 0:
		print("Error with IP list")
		continue

	# COMPARE AND SAVE
	current = hashlib.md5(ips.encode()).hexdigest()
	
	with open(last_file, "a+") as f:

		f.seek(0)

		last = f.read()

		#print("Last: " + last + ", Current: " + current)

		if last != current:

			f.seek(0)
			f.truncate()
			f.write(current)
			
			# CSF - UPDATE CONFIG FILES
			config = os.path.abspath(api['file'])
			folder = os.path.dirname(config)

			if not os.path.exists(folder):
				os.makedirs(folder)

			with open(config, "w") as c:
				c.write(ips)
			
			update = True


# CSF - RESTART
if update:
	os.system("csf -r")

