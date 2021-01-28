import json
import random
import copy
import pyrebase
from math import sin, cos, sqrt, atan2, radians


repetition = 50000
num_of_samples = 10
cities = []
with open("datafile.json") as f:
    data = json.load(f)

class City:
    def __init__(self, longitude, latitude, title):
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
    def distanceTo(self, nextCity):
        return ((self.latitude-nextCity.latitude)**2+(self.longitude-nextCity.longitude)**2)**(1/2)

for city in data["cities"]:
    current_city = City(city["longitude"], city["latitude"], city["title"])
    city["title"] = current_city
    cities.append(city["title"])

chromosomes = []
test = []
for i in range(num_of_samples):
    random.shuffle(cities)
    chromosomes.append(copy.deepcopy(cities))

def convert_to_english(index):
    test = []
    for i in chromosomes[index]:
        test.append(i.title)
    return test
def convert_all():
    for i in range(len(chromosomes)):
        print(f"{i}번쨰: {convert_to_english(i)}")

def eval(chromosomes):
    for i in range(len(chromosomes)):
        sum = 0
        for ii in range(len(chromosomes[i])):
            try:
                sum = sum+chromosomes[i][ii].distanceTo(chromosomes[i][ii+1])
            except:
                sum = sum
        chromosomes[i].append(sum)
    return chromosomes
def sort_chromosomes(chromosomes):
    ordered_chromosomes = []
    while len(chromosomes)!= 0:

        min = chromosomes[0][-1]
        for i in chromosomes:
            if i[-1]<=min:
                min = i[-1]
                min_parent = i


        chromosomes.remove(min_parent)
        ordered_chromosomes.append(min_parent)

    return ordered_chromosomes
chromosomes = eval(chromosomes)
ordered_chromosomes = sort_chromosomes(chromosomes)
for i in ordered_chromosomes:
    del i[-1]

parent1 = ordered_chromosomes[0]
parent2 = ordered_chromosomes[1]

chromosomes = copy.deepcopy(ordered_chromosomes)

for k in range(20000):
    new_chromosomes = []
    chromosomes = eval(chromosomes)
    ordered_chromosomes = sort_chromosomes(chromosomes)
    min_num = copy.deepcopy(ordered_chromosomes[0][-1])
    for i in ordered_chromosomes:
        del i[-1]
    parent1 = ordered_chromosomes[0]
    parent2 = ordered_chromosomes[1]

    new_chromosomes.append(parent1)
    for i in range(num_of_samples-1):
        if random.random()<0.3:
            random.shuffle(cities)
            new_chromosomes.append(copy.deepcopy(cities))
        else:
            parent1_copy = copy.deepcopy(parent1)
            Q = random.randrange(0, len(parent1))
            W = random.randrange(0, len(parent2))
            empty_list = []
            empty_list.append(Q)
            empty_list.append(W)
            start = min(empty_list)
            end = min(empty_list)

            if start == end:

                new_chromosomes.append(parent1_copy)
            else:
                temp_list = []
                temp_list = temp_list+copy.deepcopy(parent2[start:end+1])
                for i in parent1_copy:
                    for j in parent2:
                        if i.title == j.title:
                            parent1_copy.remove(i)
                new_chromosomes.append(parent1_copy+ temp_list)

    chromosomes = copy.deepcopy(new_chromosomes)
    print(min_num)

    test = []
    for i in parent1:
        test.append(i.title)
    print(test)

def calculate_distance(longitude1, latitude1, longitude2, latitude2):
    R = 6373.0

    lat1 = radians(latitude1)
    lon1 = radians(longitude1)
    lat2 = radians(latitude2)
    lon2 = radians(longitude2)

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    distance = R * c

    return distance

distance_list = []
for i in parent1:
    distance_list.append((i.longitude, i.latitude))

total_distance = 0
for i in range(len(distance_list)-1):
    longitude1, latitude1 = distance_list[i]
    longitude2, latitude2 = distance_list[i+1]

    total_distance = total_distance + calculate_distance(longitude1, latitude1, longitude2, latitude2)

print(total_distance)

new_data = {
    "cities":[



    ]
}
countcount = 1
for i in parent1:
    temptemp = {}
    temptemp["title"] = f"{i.title}"
    temptemp["latitude"] = i.latitude
    temptemp["longitude"] = i.longitude
    temptemp["total_distance"] = total_distance
    temptemp["id"] = copy.deepcopy(countcount)
    new_data["cities"].append(copy.deepcopy(temptemp))
    countcount = countcount+1

with open("new_datafile.json", "w") as f:
    json.dump(new_data, f)



config = {
    "apiKey": "AIzaSyDnBG9beC42VUzqnkw4wjB1JFa3kDiIHdY",
    "authDomain": "ccpmap-61789.firebaseapp.com",
    "databaseURL": "https://ccpmap-61789.firebaseio.com",
    "projectId": "ccpmap-61789",
    "storageBucket": "ccpmap-61789.appspot.com",
    "messagingSenderId": "101443781124",
    "appId": "1:101443781124:ios:520e5b92c66cb82db1eb51"
}

firebase = pyrebase.initialize_app(config)
db = firebase.database()

with open("new_datafile.json", "r") as f:
    data = json.load(f)
    db.child().update(data)

