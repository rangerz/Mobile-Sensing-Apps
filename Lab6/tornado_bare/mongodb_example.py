#!/usr/bin/python


from pymongo import MongoClient

client = MongoClient('mongodb://root:MobileSensing123@ds035747.mlab.com:35747/ms2018')

db=client.ms2018
collect1 = db.queries

for document in collect1.find():
	print(document)
