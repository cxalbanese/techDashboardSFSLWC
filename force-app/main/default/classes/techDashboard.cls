public with sharing class techDashboard {
    static integer rowLimit = 1000;
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
    //getTSInfo - returns map of time sheet entries by day of week as well as summary of regular, ot and burden
    @AuraEnabled(cacheable=true)
    public static Map<String,Decimal> getTSInfo(string userId) {
        Boolean errorFound = false;
        //** this datetime should be a parameter 
        Date thisWeeksDate = Date.today();
        TimeSheet TS = new TimeSheet();
        List<TimeSheetEntry> listTSE = new list<TimeSheetEntry>();
        Map<String,Decimal> mapTSE = new Map<String,Decimal>();
        List<String> daysOfWeek = new List<String>{'Sun','Mon','Tue','Wed','Thu','Fri','Sat','Straight','Overtime','Burden'};
        for (String thisDOW : daysOfWeek) {
            decimal x = 0;
            mapTSE.put(thisDOW,x);            
        }
        try {
            TS = [select id from TimeSheet where ServiceResourceId = :getSRInfo(userId).Id and StartDate <= :thisWeeksDate and EndDate >= :thisWeeksDate limit 1];
            listTSE = [select id,timesheetentrynumber,starttime,endtime,status,subject,type,durationinminutes from timesheetentry where TimeSheetId = :TS.id];
        }
        catch (Exception e) {
            errorFound=true;
            system.debug(e.getMessage());

        }
        //** found an error? just exit and return a map with all zeroes
        if(errorFound) return mapTSE;
        //** loop through the timesheet entries and place the values in the map
        for(TimeSheetEntry thisTSE : listTSE){
            string thisDOW = thisTSE.starttime.format('EEE');
            mapTSE.put(thisDOW,mapTSE.get(thisDOW)+thisTSE.durationinminutes);
        }
        //** calculate straight, overtime and burden totals 
        //** using TSE.Type field to bucket the values
        //** Overtime = Overtime, Indirect = Burden, everything else = Straight
        decimal straight=0;
        decimal overtime=0;
        decimal burden=0;
        for(timesheetentry thisTSE : listTSE)
            if(thisTSE.Type=='Indirect') 
                mapTSE.put('Burden',mapTSE.get('Burden')+thisTSE.durationinminutes);
            else 
                if(thisTSE.Type=='Overtime') 
                    mapTSE.put('Overtime',mapTSE.get('Overtime')+thisTSE.durationinminutes);
                else mapTSE.put('Straight',mapTSE.get('Straight')+thisTSE.durationinminutes);
                system.debug('***********');
                system.debug(mapTSE);
        return mapTSE;
    }  
    //getTSList - returns list of time sheet entries 
    @AuraEnabled(cacheable=true)
    public static list<TimeSheetEntry> getTSList(string userId) {
        Boolean errorFound = false;
        //** this datetime should be a parameter 
        Date thisWeeksDate = Date.today();
        TimeSheet TS = new TimeSheet();
        List<TimeSheetEntry> listTSE = new list<TimeSheetEntry>();

        try {
           listTSE = [select id,timesheetentrynumber,timesheet.timesheetnumber, starttime,endtime,status,subject,type,durationinminutes from timesheetentry where TimeSheetId in (select id from TimeSheet where ServiceResourceId = :getSRInfo(userId).Id and StartDate <= :thisWeeksDate and EndDate >= :thisWeeksDate) order by starttime];
        }
        catch (Exception e) {
            errorFound=true;
            system.debug(e.getMessage());

        }
        //** found an error? just exit and return an empty list
        if(errorFound) return new list<timesheetentry>();
        return listTSE;
    }  
    //getTSHeader - returns Time Sheet Headerfor the current week
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