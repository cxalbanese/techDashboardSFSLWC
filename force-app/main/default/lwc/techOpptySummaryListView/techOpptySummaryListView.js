import { api, LightningElement, track, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity'; 
import CLOSED_FIELD from '@salesforce/schema/Opportunity.IsClosed'

import customlabelOpportunitiesOpen from "@salesforce/label/c.OpportunitiesOpen";
import customlabelOpportunitiesWon from "@salesforce/label/c.OpportunitiesWon"; 
import customlabelOpportunityTitle from "@salesforce/label/c.OpportunityTitle"; 
export default class getOppties extends LightningElement {
labels = {
    customlabelOpportunitiesOpen,
    customlabelOpportunitiesWon,
    customlabelOpportunityTitle
};

    @track opptyData = [];
    @track errorData;
    @track opptyDataWon = [];
    @track errorDataWon;
    //following wire returns the list of open opportunities created by the technician
    @wire(getListUi,{
        objectApiName : OPPORTUNITY_OBJECT, 
        listViewApiName: 'My_Open_Opportunities',
        sortBy: CLOSED_FIELD})
    dataRecord({data, error}){
       if(data){
            this.opptyData = data.records.records;
       }
       else if(error){
           this.errorData = error;
           this.opptyData = undefined;
       }
     }

    //following wire returns the list of won opportunities created by the technician
     @wire(getListUi,{
        objectApiName : OPPORTUNITY_OBJECT, 
        listViewApiName: 'My_Won_Opportunities',
        sortBy: CLOSED_FIELD})
    dataRecordWon({data, error}){
       if(data){
            this.opptyDataWon = data.records.records;
       }
       else if(error){
           this.errorDataWon = error;
           this.opptyDataWon = undefined;
       }
     }

    get numOpenOppties() {
        return this.opptyData.length;
    }
    get numWonOppties() {
        return this.opptyDataWon.length;
    } 
}