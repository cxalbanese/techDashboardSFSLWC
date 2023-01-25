import { api, LightningElement,track,wire} from 'lwc';
import getTS from '@salesforce/apex/techDashboard.getTSHeader';
import techId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import TIMESHEETNUMBER_FIELD from '@salesforce/schema/TimeSheet.TimeSheetNumber';
import STARTDATE_FIELD from '@salesforce/schema/TimeSheet.StartDate';
import ENDDATE_FIELD from '@salesforce/schema/TimeSheet.EndDate'
import DURATIONINMINUTES_FIELD from '@salesforce/schema/TimeSheetEntry.DurationInMinutes';
import TYPE_FIELD from '@salesforce/schema/TimeSheetEntry.Type';
import STARTTIME_FIELD from '@salesforce/schema/TimeSheetEntry.StartTime';
import ENDTIME_FIELD from '@salesforce/schema/TimeSheetEntry.EndTime';
import TIMESHEETENTRYNUMBER_FIELD from '@salesforce/schema/TimeSheetEntry.TimeSheetEntryNumber';
import customlabelTitle from "@salesforce/label/c.TimeSheetSummaryTitle";
import customlabelSubtitle from "@salesforce/label/c.TimeSheetSummarySubtitle";
import customlabelTotal from "@salesforce/label/c.Total";
import customlabelStraight from "@salesforce/label/c.Straight";
import customlabelBurden from "@salesforce/label/c.Burden";
import customlabelOvertime from "@salesforce/label/c.Overtime";
import customlabelMonday from "@salesforce/label/c.Monday";
import customlabelTuesday from "@salesforce/label/c.Tuesday";
import customlabelWednesday from "@salesforce/label/c.Wednesday";
import customlabelThursday from "@salesforce/label/c.Thursday";
import customlabelFriday from "@salesforce/label/c.Friday";
import customlabelSaturday from "@salesforce/label/c.Saturday";
import customlabelSunday from "@salesforce/label/c.Sunday";

export default class techTimeSheetHeader extends LightningElement {
  debugger;
    @track tsRecordId='elmpo';
    @track records;
    @track dowHours = [];
    @track burden=0;
    @track straight=0;
    @track overtime=0;
    @track total=0;
    @track rows=[];
    labels = {
        customlabelTitle,
        customlabelSubtitle,
        customlabelTotal,
        customlabelBurden,
        customlabelStraight,
        customlabelOvertime
    };
    labelArray=[customlabelMonday,customlabelTuesday,customlabelWednesday,customlabelThursday,customlabelFriday,customlabelSaturday,customlabelSunday];

    @wire(getTS,{userId : techId})
    dataRecord({data, error}){
       if(data){
            this.data = data;
            this.tsRecordId = data.Id;
       }
       else if(error){
           this.errorData = error;
       }
    }
    
    @wire(getRecord, { recordId: '$tsRecordId', fields: [TIMESHEETNUMBER_FIELD, STARTDATE_FIELD,ENDDATE_FIELD] })
    tsData;
    get tsNumber() {
        return getFieldValue(this.tsData.data, TIMESHEETNUMBER_FIELD);
    }
    get tsStartDate() {
        return getFieldValue(this.tsData.data, STARTDATE_FIELD);
    }
    get tsEndDate() {
        return getFieldValue(this.tsData.data, ENDDATE_FIELD);
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$tsRecordId',
        relatedListId: 'TimeSheetEntries',
        fields: [
            TIMESHEETENTRYNUMBER_FIELD.objectApiName+'.'+TIMESHEETENTRYNUMBER_FIELD.fieldApiName,
            STARTTIME_FIELD.objectApiName+'.'+STARTTIME_FIELD.fieldApiName,
            ENDTIME_FIELD.objectApiName+'.'+ENDTIME_FIELD.fieldApiName,
            TYPE_FIELD.objectApiName+'.'+TYPE_FIELD.fieldApiName,
            DURATIONINMINUTES_FIELD.objectApiName+'.'+DURATIONINMINUTES_FIELD.fieldApiName
                ],
        sortBy: [STARTTIME_FIELD.objectApiName+'.'+STARTTIME_FIELD.fieldApiName]
    }) 
    listInfo({ error, data }) {
        if (data) {
            //create totals for each day of week
            //create totals for overtime, burden and straight based on timesheetentry.type field
            this.records = data.records;
            this.error = undefined;
            this.dowHours = this.initializeHours();
            for(const record in this.records) {
                const val=this.records[record];
               let mydate = new Date(val.fields.StartTime.value);
               if(mydate) {
                    let hours = val.fields.DurationInMinutes.value / 60;
                    let dow = mydate.getDay();
                    //Monday is the first day, shift everything by 1 and move Sunday to 6
                    if(dow == 0)
                        dow = 6;
                    else 
                        dow--;
                    this.dowHours[dow] += hours;
                    if(val.fields.Type.value=='Indirect') {
                        this.burden+= hours;
                    }
                    else if (val.fields.Type.value == 'Overtime') {
                        this.overtime+= hours;
                    }
                    else {
                        this.straight+= hours;
                    }
                    this.total+= hours;
               } 
            }
            this.rows = this.buildRows(this.dowHours); 
        } else if (error) {
            //if there is an error, we'll just return zeroes for all days of week
            this.error = error;
            this.records = undefined;
            this.dowHours = this.initializeHours();
            this.rows = this.buildRows(this.dowHours);  
        }
    }
    get tseDataSize() {
        return this.records;
    }
    initializeHours() {
        let initHours=[];
        for(let x=0;x<7;x++)
            initHours[x]=0; 
        return initHours;
    }
    buildRows(brDowHours) {
        let brRows=[];
        let x = 0;
        for (const element of brDowHours) {
            let row={};
            row.id = x;
            row.value = element;
            row.label = this.labelArray[x];
            x++;
            brRows.push(row);
          }
        return brRows;
    }
}