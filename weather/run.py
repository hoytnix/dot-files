import requests, os, sys

from bs4 import BeautifulSoup

def download(url, file_path):
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (compatible; python:my-weather-plugin/1.0)',
        }

        r = requests.get(url, headers=headers)
        html = r.content

        with open(file_path, 'wb+') as f:
            f.write(html)

        return file_path
    except:
        print("Unexpected error: %s" % sys.exc_info()[0])
        return False

def data(soup, variable):

    data_set = soup.find_all('span', {'data-variable': variable})

    if data_set.__len__() < 1:
        data_set = soup.find_all('div', {'data-variable': variable})
        if data_set.__len__() < 1:
            return 'NAN -1'

    data = data_set[0]
    variable_set = data.find_all('span', {'class': 'wx-value'})

    if variable_set.__len__() != 1:
        return 'NAN -2'

    variable_value = variable_set[0]

    return variable_value.text

def main():
    
    #
    # D O W N L O A D
    #

    url = 'http://www.wunderground.com/us/mi/allegan'

    base_path = os.path.dirname(os.path.realpath(__file__))
    cache_path = os.path.join(base_path, 'cached.html')
    msg_path   = os.path.join(base_path, 'msg.txt')

    status = download(url = url, file_path = cache_path)
    if not status:
        with open(msg_path, 'w+') as f:
            f.write('NAN -3')
        return None

    #
    # B E A U T I F U L  S O U P
    #

    with open(cache_path, 'rb') as f:
        html = f.read()
        
    soup = BeautifulSoup(html, 'html5lib')
    
    # 
    # V A R I A B L E S
    #
    
    temperature = data(soup=soup, variable='temperature')
    humidity    = data(soup=soup, variable='humidity')
    condition   = data(soup=soup, variable='condition')

    #
    # O U T P U T
    #

    msg = '%s F - %s%% H - %s' % (
        temperature, 
        humidity, 
        condition
    )

    with open(msg_path, 'w+') as f:
        f.write(msg)

if __name__ == '__main__':
    main()