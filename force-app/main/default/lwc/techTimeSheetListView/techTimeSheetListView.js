import { api, LightningElement, track, wire } from 'lwc';
import getTS from '@salesforce/apex/techDashboard.getTSHeader';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

import techId from '@salesforce/user/Id';
import customlabelTimeSheetEntriesNone from "@salesforce/label/c.TimeSheetEntriesNone";
import customlabelTimeSheetEntryDetailsTitle from "@salesforce/label/c.TimeSheetEntryDetailsTitle";
import customlabelBackTitle from "@salesforce/label/c.Back";
import TIMESHEET_OBJECT from '@salesforce/schema/TimeSheet';
import TIMESHEETENTRY_OBJECT from '@salesforce/schema/TimeSheetEntry';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import TIMESHEETNUMBER_FIELD from '@salesforce/schema/TimeSheet.TimeSheetNumber';
import STARTDATE_FIELD from '@salesforce/schema/TimeSheet.StartDate';
import ENDDATE_FIELD from '@salesforce/schema/TimeSheet.EndDate';
import DURATIONINMINUTES_FIELD from '@salesforce/schema/TimeSheetEntry.DurationInMinutes';
import TYPE_FIELD from '@salesforce/schema/TimeSheetEntry.Type';
import STARTTIME_FIELD from '@salesforce/schema/TimeSheetEntry.StartTime';
import ENDTIME_FIELD from '@salesforce/schema/TimeSheetEntry.EndTime';
import TIMESHEETENTRYNUMBER_FIELD from '@salesforce/schema/TimeSheetEntry.TimeSheetEntryNumber';

export default class techTimeSheetListView extends LightningElement {
    timesheetnumberlabel;
    timesheetentrynumberlabel;
    typelabel;
    starttimelabel;
    endtimelabel;
    labels = {
        customlabelTimeSheetEntryDetailsTitle,
        customlabelTimeSheetEntriesNone,
        customlabelBackTitle
    };
    @track tseData = [];
    @track errorData;

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
            this.tseData = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.tseData = undefined;
        }
    }

    @wire(getObjectInfo, { objectApiName: TIMESHEET_OBJECT })
    tsInfo({ data, error }) {
        if (data) {
            this.timesheetnumberlabel=data.fields.TimeSheetNumber.label;
        }
    }
   @wire(getObjectInfo, { objectApiName: TIMESHEETENTRY_OBJECT })
    tseInfo({ data, error }) {
        if (data) {
            this.timesheetentrynumberlabel=data.fields.TimeSheetEntryNumber.label;
            this.typelabel=data.fields.Type.label;
            this.starttimelabel=data.fields.StartTime.label;
            this.endtimelabel=data.fields.EndTime.label;
        }
    } 
    
     get hasRecords() {
        return this.tseData && this.tseData.length > 0;
     }
}