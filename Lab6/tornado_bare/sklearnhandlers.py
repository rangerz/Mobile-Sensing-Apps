#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

from sklearn.neighbors import KNeighborsClassifier
from sklearn.linear_model import SGDClassifier
from sklearn.ensemble import RandomForestClassifier

import pickle
from bson.binary import Binary
import json
import numpy as np
import functools

cookie_secret = "61oETzKXQAGaYdkL5gEmGeJJFuYh7EQnp2XdTP1o"

def require_login(method):
    @functools.wraps(method)
    def wrapped(self, *args, **kwargs):
        cookie = self.get_cookie("eric_cookie")
        if cookie_secret != cookie:
            self.redirect('GoAway')
            return
        return method(self, *args, **kwargs)
    return wrapped

def initModel(self, params={}):
    if None == self.clf["KNN"]:
        self.clf["KNN"] = KNeighborsClassifier(n_neighbors=3)

    if None == self.clf["SVM"]:
        self.clf["SVM"] = SGDClassifier(loss='log', alpha=.001)

    if None == self.clf["RF"]:
        self.clf["RF"] = RandomForestClassifier(n_estimators=100, max_depth=2, random_state=0)

class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),','),\n'))

class UploadLabeledDatapointHandler(BaseHandler):
    @require_login
    def post(self):
        '''Save data point and class label to database
        '''
        data = json.loads(self.request.body.decode("utf-8"))

        vals = data['feature']
        fvals = [float(val) for val in vals]
        label = data['label']
        sess  = data['dsid']

        dbid = self.db.labeledinstances.insert(
            {"feature":fvals,"label":label,"dsid":sess}
            )
        self.write_json({"id":str(dbid),"feature":fvals,"label":label})

class RequestNewDatasetId(BaseHandler):
    @require_login
    def get(self):
        '''Get a new dataset ID for building a new dataset
        '''
        a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
        if a == None:
            newSessionId = 1
        else:
            newSessionId = float(a['dsid'])+1
        self.write_json({"dsid":newSessionId})

class UpdateModelForDatasetId(BaseHandler):
    @require_login
    def get(self):
        '''Train a new model (or update) for given dataset ID
        '''
        initModel(self)
        dsid = self.get_int_arg("dsid", default=0)
        clf_type = self.get_str_arg("type")

        if clf_type in self.clf:
            self.clf_type = clf_type
        else:
            print('Unknown type')

        # create feature vectors from database
        f=[];
        for a in self.db.labeledinstances.find({"dsid":dsid}): 
            f.append([float(val) for val in a['feature']])

        # create label vector from database
        l=[];
        for a in self.db.labeledinstances.find({"dsid":dsid}): 
            l.append(a['label'])

        # fit the model to the data
        c1 = self.clf[self.clf_type]
        acc = -1;
        if l:
            c1.fit(f,l) # training
            lstar = c1.predict(f)
            self.clf[dsid] = c1
            acc = sum(lstar==l)/float(len(l))
            bytes = pickle.dumps(c1)
            self.db.models.update(
                {"type": self.clf_type},
                {"$set": {"model":Binary(bytes)}},
                upsert=True)

        # send back the resubstitution accuracy
        # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"resubAccuracy":acc})

class PredictOneFromDatasetId(BaseHandler):
    @require_login
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        initModel(self)
        data = json.loads(self.request.body.decode("utf-8"))    

        vals = data['feature'];
        fvals = [float(val) for val in vals];
        fvals = np.array(fvals).reshape(1, -1)
        dsid  = data['dsid']

        # load the model from the database (using pickle)
        # we are blocking tornado!! no!!
        print('Loading Model From DB')
        tmp = self.db.models.find_one({"type": self.clf_type})
        if tmp:
            self.clf[self.clf_type] = pickle.loads(tmp['model'])
            predLabel = self.clf[self.clf_type].predict(fvals);
        else:
            print("Model is not tranined yet")
            predLabel = 'Unknown'

        self.write_json({"prediction":str(predLabel)})

class GoAway(BaseHandler):
    def get(self):
        self.write('Go Away Please')
