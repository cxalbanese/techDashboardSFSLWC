@isTest
public class techDashboardTestClass{

    @IsTest
    static void validateDashboard() {

        List<User> userList = techTestUtility.createUser(1);
        Map<String,SObject> testResource1 = techTestUtility.createSingleTestResource(userList[0].Id);

        WorkType wt = techTestUtility.createWorktype('test', 1, 'hours');
        WorkOrder wo = techTestUtility.createWorkOrder('test', wt.Id, testResource1.get('ServiceTerritory').Id);
        ServiceAppointment sa = techTestUtility.createServiceAppointment(testResource1.get('ServiceResource').Id, wo.Id, Datetime.now(), Datetime.now().addDays(7), Datetime.now(), Datetime.now().addHours(1));
        AssignedResource ar = techTestUtility.createAssignedResource(sa.Id, testResource1.get('ServiceResource').Id);
        TimeSheet ts = techTestUtility.createTimeSheet(testResource1.get('ServiceResource').Id,Datetime.now());
        Account ac = techTestUtility.createAccount('test');
        System.runAs(userList[0]) {
        Opportunity opty1 = techTestUtility.createOpportunity('test1', 'Prospecting', date.today().adddays(30), ac.Id);
        Opportunity opty2 = techTestUtility.createOpportunity('test2', 'Closed Won', date.today().adddays(30), ac.Id);
        }

        Test.startTest();
        ServiceResource results = techDashboard.getSRInfo(userList[0].Id);
        List<Opportunity> opptyResults = techDashboard.getOpptyInfo(userList[0].Id);
        List<ServiceAppointment> saResults = techDashboard.getSAInfo(userList[0].Id);
        list<WorkOrder> woResults = techDashboard.getWOInfo(userList[0].Id);
        TimeSheet tsResults = techDashboard.getTSHeader(userList[0].Id);
        //Map<String,Decimal> tsResultsMap = techDashboard.getTSInfo(userList[0].id);
        //list<TimeSheetEntry> tseResults = techDashboard.getTSList(userList[0].Id);

        Test.stopTest();

        System.assert(results!=null);
        System.assert(opptyResults!=null && opptyResults.size()>0);
        System.assert(saResults!=null && saResults.size()>0);
        System.assert(woResults!=null && woResults.size()>0);
        System.assert(tsResults!=null);
        //System.assert(tsResultsMap!=null && tsResultsMap.size()>0);
        //System.assert(tseResults!=null && tseResults.size()>0);


    }



}