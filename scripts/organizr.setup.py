#Copied from @Roxedus#1337 on Discord, one of the Mods on the Organizr Discord

import requests
import pprint


org_url = "https://localhost/organizr"

head = {
    'content-type': 'application/x-www-form-urlencoded',
    'charset': 'UTF-8',
    'Content-Encoding': 'gzip',
}

path_data = {
    'data[path]': '/srv/organizer_db',
    'data[formKey]': ''
}

r_path = requests.post(url=org_url + "api/?v1/wizard_path", headers=head, data=path_data, auth=('test', 'test'), verify=False)
print(r_path.status_code)

pprint.pprint(r_path.json())

config_data = {
    'data[0][name]': 'license', 'data[0][value]': 'personal',
    'data[1][name]': 'username', 'data[1][value]': 'test',
    'data[2][name]': 'email', 'data[2][value]': 'ja@nei.com',
    'data[3][name]': 'password', 'data[3][value]': 'test123',
    'data[4][name]': 'hashKey', 'data[4][value]': 'hash',
    'data[5][name]': 'registrationPassword', 'data[5][value]': 'reg',
    'data[6][name]': 'api', 'data[6][value]': 'ewmv12hdpsjn3cydi1r0',
    'data[7][name]': 'dbName', 'data[7][value]': 'db',
    'data[8][name]': 'location', 'data[8][value]': '/srv/organizer_db'
}

r_config = requests.post(url=org_url + "api/?v1/wizard_config", headers=head, data=config_data, auth=('test', 'test'), verify=False)
print(r_config.status_code)
pprint.pprint(r_config.json())