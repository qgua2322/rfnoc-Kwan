
import csv
temp = []
with open('Payload_8_100M') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        a = row[8]
        if(a == ''or a =='Time'):
            temp.append (a)
        else:
            temp.append ( hex(int(a)))
            

with open('hex','w') as wcsvfile:
    writer = csv.writer(wcsvfile)
    for row in temp: 
        writer.writerow(row)
        