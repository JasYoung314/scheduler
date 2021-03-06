import os
import csv
import glob
import random

def schedule():
    '''
    Short script to schedule tutorials for tutors. Takes in a csv of availabilty, names must be entered into the lists, as well as the tutoring slots
    The output must be less than 40 man hours of tutoring in total.
    sage: schedule()
    True
    '''

    files = [file for file in glob.glob('available3.csv')]

    for fle in files:
        #reads in data files
        f=open(fle,'r') 
        data = [[int(j) for j in row] for row in csv.reader(f)] 
        f.close() 
        for e in range(len(data)):
            for i in range(len(data[e])):
                if data[e][i] == 0:
                    data[e][i] = 20
        #data = [[1 for e in range(20)] for i in range(17)]
        M = Matrix(data)

        #Stores the names under a key and breaks them up by tutoring hours
        tutornames = ['jt','dafydd','paul','vince','jason','rhyd','james','hawa','long','carney','power','morgan','staden','lunn','pohl','thomson','awan']
        t1 = ['jt','dafydd','paul','rhyd','james','hawa','long','carney','power','morgan','staden','lunn','pohl','thomson','awan']
        t2 = ['vince','jason']
        tdict = {}
        for i in range(len(tutornames)):
            tdict[tutornames[i]] = i
        
        #Stores the tutorials under a key and breaks them up by time slot
        slotnames = ['s1','x1','t1','y1','p1','u1','r1','w1','v1','z1','s2','x2','t2','y2','p2','u2','r2','w2','v2','z2']
        sk = [['s1','x1'],['t1','y1'],['p1','u1'],['r1','w1'],['v1','z1'],['s2','x2'],['t2','y2'],['p2','u2'],['r2','w2'],['v2','z2']]
        sdict = {}
        for i in range(len(slotnames)):
            sdict[slotnames[i]] = i

        slots = len(slotnames) 
        Tutors = len(tutornames)

        #initialises the MLP
        p = MixedIntegerLinearProgram()  
        w = p.new_variable(binary=True)
        
        #sets the objective function
        p.set_objective(sum(w[(i,j)] for i in range(Tutors) for j in range(slots)))

        #adds the constraints described in the documentation
        for i in t1:
            p.add_constraint(sum( M[(tdict[i],j)]*w[(tdict[i],j)] for j in range(slots)) <= 2)
        for i in t2:
            p.add_constraint(sum( M[(tdict[i],j)]*w[(tdict[i],j)] for j in range(slots)) <=7 )

        for j in range(slots):
            p.add_constraint(sum( w[(i,j)] for i in range(Tutors)) <= 2)
        for j in range(slots):
            p.add_constraint(sum( w[(i,j)] for i in range(Tutors)) >= 1)
        for i in tutornames:
            for k in sk:
                p.add_constraint(sum( w[(tdict[i],sdict[k2])] for k2 in k) <= 1)
        
        #converts the keys to the names of the tutors and tutorials
        schedule = {}
        #print 'Objective Value:', p.solve()
        for i, v in p.get_values(w).iteritems():
            if tutornames[i[0]] in schedule and v == 1:
                schedule[tutornames[i[0]]].append(slotnames[i[1]])  
            if not tutornames[i[0]] in schedule and v == 1:
                schedule[tutornames[i[0]]] = [slotnames[i[1]]]  
        
#    for e in schedule:
#        print e, schedule[e]
#        used = []
#        notused = []
#        for slot in slotnames:
#            print slot
#            for e in schedule:
#                if slot in schedule[e]:
#                    print '\t %s' % e
#                    used.append(e)
#        notused = [e for e in tutornames if e not in used]
#        print 'Students not used: %s' % notused
        return p.solve()<=40
if __name__ == '__main__':
    schedule()
