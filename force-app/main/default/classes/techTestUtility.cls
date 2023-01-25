@isTest
public with sharing class techTestUtility {
    public techTestUtility() {

    }

    public static WorkType createWorktype(String worktypeName, Double estDuration, String durationType){

        WorkType testWorkType = new WorkType(Name = worktypeName,
                                            EstimatedDuration = estDuration,
                                            DurationType = durationType);

        insert testWorkType;                            
        return testWorkType;

    }


    public static OperatingHours createOperatingHours(String ohName){

        OperatingHours testOperatingHours = new OperatingHours(Name = ohName);
        
        insert testOperatingHours;
        return testOperatingHours;

    }

    public static OperatingHours createOperatingHours(String ohName, String tz){

        OperatingHours testOperatingHours = new OperatingHours(Name = ohName, 
                                                               TimeZone = tz);
        
        insert testOperatingHours;
        return testOperatingHours;

    }


    public static ServiceTerritory createServiceTerritory(String territoryName,Boolean active, String opHoursId){

        ServiceTerritory testServiceTerritory = new ServiceTerritory(Name = territoryName,
                                                                     IsActive = active,
                                                                     OperatingHoursId = opHoursId);

        insert testServiceTerritory;
        return testServiceTerritory;

    }


    public static ServiceResource createServiceResource(String resourceName, Boolean active, String relatedRecord, String resourceType){

        ServiceResource testServiceResource = new ServiceResource(Name = resourceName,
                                                                  IsActive = active,
                                                                  relatedRecordId = relatedRecord,
                                                                  ResourceType = resourceType);

        insert testServiceResource;
        return testServiceResource;

    }


    public static ServiceTerritoryMember createServiceTerritoryMember(String resourceId, String territoryId, Datetime startDate){

        ServiceTerritoryMember testStm = new ServiceTerritoryMember(ServiceResourceid = resourceId,
                                                                    ServiceTerritoryId = territoryId,
                                                                    EffectiveStartDate = startDate);

        insert testStm;
        return testStm;

    }
    public static Account createAccount(String aname){

        Account testAct = new Account(Name = aname);

        insert testAct;
        return testAct;

    }
    public static Opportunity createOpportunity(String oname, String stage, Date closeDate, String accountId){

        Opportunity testOpty = new Opportunity(Name = oname,
                                                AccountId = accountId,
                                               CloseDate = closeDate,
                                               StageName = stage);

        insert testOpty;
        return testOpty;

    }

    public static TimeSheet createTimeSheet(String resourceId, Datetime startDate){

        TimeSheet testTS = new TimeSheet(ServiceResourceid = resourceId,
                                        StartDate=startDate.date(),
                                        EndDate = startDate.date().addDays(6));

        insert testTS;
        list<TimeSheetEntry> listTSE = new list<TimeSheetEntry>();
        listTSE.add( new TimeSheetEntry(TimeSheetId=testTS.id,
                                            StartTime=startDate,
                                            Endtime=startDate.addhours(1),
                                            Type='Direct'
                                            ));
        listTSE.add( new TimeSheetEntry(TimeSheetId=testTS.id,
                                            StartTime=startDate,
                                            Endtime=startDate.addhours(1),
                                            Type='Overtime'
                                            ));        
        listTSE.add( new TimeSheetEntry(TimeSheetId=testTS.id,
                                            StartTime=startDate,
                                            Endtime=startDate.addhours(1),
                                            Type='Indirect'
                                            ));
        insert listTSE;                                    
        return testTS;

    }


    public static Map<String,SObject> createSingleTestResource(String userId){

        String objectName = '';
        Map<String, SObject> testResourceObjectMap = new Map<String, SObject>();
        String testName = 'test' + String.valueOf(Crypto.getRandomInteger());

        WorkType testWorkType = createWorkType(testName, 1, 'hours');
        objectName = 'WorkType';
        testResourceObjectMap.put(objectName, testWorkType);

        OperatingHours testOh = createOperatingHours(testName);
        objectName = 'OperatingHours';
        testResourceObjectMap.put(objectName, testOh);

        ServiceTerritory testTerritory = createServiceTerritory(testName, true, testOh.Id);
        objectName = 'ServiceTerritory';
        testResourceObjectMap.put(objectName, testTerritory);

        ServiceResource testResource = createServiceResource(testName, true, userId, 'T');
        objectName = 'ServiceResource';
        testResourceObjectMap.put(objectName, testResource);

        ServiceTerritoryMember testSTM = createServiceTerritoryMember(testResource.Id, testTerritory.Id, datetime.now());
        objectName = 'ServiceTerritoryMember';        
        testResourceObjectMap.put(objectName, testSTM);

        TimeSheet testST = createTimeSheet(testResource.Id, datetime.now());
        objectName = 'TimeSheet';        
        testResourceObjectMap.put(objectName, testST);        

        Opportunity testOpty = createOpportunity('test', 'Qualification', date.today()+30, createAccount('test').Id);
        objectName = 'Opportunity';        
        testResourceObjectMap.put(objectName, testOpty);   
        
        return testResourceObjectMap;

    }


    public static WorkOrder createWorkOrder(){

        WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;
        return testWorkOrder;

    }


    public static WorkOrder createWorkOrder(String subject, String workTypeId, String serviceTerritoryId){

        WorkOrder testWorkOrder = new WorkOrder(Subject = subject,
                                                WorkTypeId = workTypeId,
                                                ServiceTerritoryId = serviceTerritoryId);

        insert testWorkOrder;
        return testWorkOrder;

    }


    public static ServiceAppointment createServiceAppointment(String mrServiceResourceID, String parentRecordId, Datetime earlyStart, Datetime dueDate, Datetime schedStart, Datetime schedEnd){

        ServiceAppointment testServiceAppointment = new ServiceAppointment(
                                                                           ParentRecordId = parentRecordId,
                                                                           EarliestStartTime = earlyStart,
                                                                           DueDate = dueDate,
                                                                           SchedStartTime = schedStart,
                                                                           SchedEndTime = schedEnd);
        
        insert testServiceAppointment;
        return testServiceAppointment;

    }


    public static ServiceAppointment createServiceAppointment(String mrServiceResourceID, String parentRecordId, Datetime earlyStart, Datetime dueDate, Datetime schedStart, Datetime schedEnd, String status){

        ServiceAppointment testServiceAppointment = new ServiceAppointment(
                                                                           ParentRecordId = parentRecordId,
                                                                           EarliestStartTime = earlyStart,
                                                                           DueDate = dueDate,
                                                                           SchedStartTime = schedStart,
                                                                           SchedEndTime = schedEnd,
                                                                           Status = status);
        
        insert testServiceAppointment;
        return testServiceAppointment;

    }


    public static ServiceAppointment createServiceAppointment(String mrServiceResourceID, String parentRecordId, Datetime earlyStart, Datetime dueDate, Datetime schedStart, Datetime schedEnd, String status, String territoryId){

        ServiceAppointment testServiceAppointment = new ServiceAppointment(
                                                                           ParentRecordId = parentRecordId,
                                                                           EarliestStartTime = earlyStart,
                                                                           DueDate = dueDate,
                                                                           SchedStartTime = schedStart,
                                                                           SchedEndTime = schedEnd,
                                                                           Status = status,
                                                                           ServiceTerritoryId = territoryId);
        
        insert testServiceAppointment;
        return testServiceAppointment;

    }


    public static ResourceAbsence createResourceAbsence(String resourceId, Datetime startDate, Datetime endDate){

        final Id NONAVAILABILITY_RECORDTYPE = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
        ResourceAbsence testAbsence = new ResourceAbsence(ResourceId = resourceId,
                                                           Start = startDate,
                                                           End = endDate,
                                                           RecordTypeId = NONAVAILABILITY_RECORDTYPE);

        insert testAbsence;
        return testAbsence;

    }


    public static AssignedResource createAssignedResource(String serviceAppointmentId, String serviceResourceId){

        AssignedResource testAssignedResource = new AssignedResource(ServiceResourceId = serviceResourceId, 
                                                                     ServiceAppointmentId = serviceAppointmentId);

        insert testAssignedResource;
        return testAssignedResource;

    }


    public static List<User> createUser(Integer numberOfUsersToCreate){

        List<User> testUserList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Integer i = 0;

        while(i < numberOfUsersToCreate){

            User u = new User(Alias = 'standt' + i, 
                          Email='standarduser' + i + '@example.com', 
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser' + i + '@MRDTReassignTechs.com');

            testUserList.add(u);

            i++;

        }

        insert testUserList;
        return testUserList;

    }

}