public with sharing class techDashboard {
    static integer rowLimit = 200;
    //getSRInfo - returns Service Resource Info for the tech
    @AuraEnabled(cacheable=true)
    public static ServiceResource getSRInfo(string userId) {
    return [select Id,Name,LastKnownLocationDate from serviceresource where relatedrecordid = :userId limit 1];
    }
    //getOpptyInfo - returns open or won opportunities that the tech has created
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpptyInfo(string userId) {
        return [SELECT ID, Name, StageName, IsWon,IsClosed,Amount from Opportunity where CreatedById = :userId and (IsClosed = False OR IsWon = True) LIMIT :rowLimit];
    }
    //getSAInfo - returns a list of SAs assigned to the tech and is scheduled, dispatched or in progress
    @AuraEnabled(cacheable=true)
    public static List<ServiceAppointment> getSAInfo(string userId) {
        string serviceResourceId = [select id from serviceresource where relatedrecordid = :userId].id;
        return [SELECT ID, Subject, AppointmentNumber, Status, ParentRecordId,SchedStartTime,SchedEndTime,Duration from ServiceAppointment where StatusCategory in ('Scheduled','Dispatched','InProgress') and Id in (select serviceappointmentid from assignedresource where serviceresourceid = :serviceResourceId) LIMIT :rowLimit];
    } 
    //getWOInfo - returns list of work orders and associated worktype for the assigned SA
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getWOInfo(string userId) {
        set<id> setParentRecordId = new set<id>();
        for(serviceappointment sa : getSAInfo(userId)) setParentRecordId.add(sa.ParentRecordId);
        return [select id,workordernumber,worktypeid,worktype.name, startdate, enddate, subject from workorder where id in :setParentRecordId];
    } 
    //getTSHeader - returns Time Sheet Header for the current week
    @AuraEnabled(cacheable=true)
    public static TimeSheet getTSHeader(string userId) {
        Boolean errorFound = false;
        //** this datetime should be a parameter 
        Date thisWeeksDate = Date.today();
        TimeSheet TS = new TimeSheet();
        try {
            TS = [select id,timesheetnumber,startdate,enddate from TimeSheet where ServiceResourceId = :getSRInfo(userId).Id and StartDate <= :thisWeeksDate and EndDate >= :thisWeeksDate limit 1];
        }
        catch (Exception e) {
            errorFound=true;
            system.debug(e.getMessage());

        }
        //** return the TS. If there is none or an error was found it will just be empty
        return TS;
    }  
}